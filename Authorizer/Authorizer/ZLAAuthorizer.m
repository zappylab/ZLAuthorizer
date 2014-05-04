//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAAuthorizer.h"

#import "ZLACredentialsStorage.h"
#import "ZLARequestsPerformer.h"
#import "ZLATwitterAuthorizer.h"
#import "ZLANativeAuthorizer.h"
#import "ZLAAuthorizationResponseHandler.h"
#import "ZLAUserInfoContainer.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AFHTTPRequestOperation.h"
#import "ZLADefinitions.h"

/////////////////////////////////////////////////////

static NSString* const kGooglePlusClientId = @"17100019704-o162em5ouc56mcel4omjbr9v7b9p10lt.apps.googleusercontent.com";
//static NSString* const kGooglePlusAPIkey = @"AIzaSyDVPAzVk-foSqpd3Mz7IfKbxnTygpLoNYo";
static NSString* const kFacebook = @"Facebook";
static NSString* const kGooglePlus = @"Google+";

/////////////////////////////////////////////////////

@interface ZLAAuthorizer ()

@property (strong) ZLARequestsPerformer *requestsPerformer;
@property (strong) ZLATwitterAuthorizer *twitterAuthorizer;
@property (strong) ZLANativeAuthorizer *nativeAuthorizer;
@property (strong) ZLAAuthorizationResponseHandler *authorizationResponseHandler;
@property (strong) ZLAUserInfoContainer *userInfo;

@property (readwrite) BOOL signedIn;
@property (readwrite) BOOL performingAuthorization;

@property (strong) FBLoginView* fbLoginView;

@property (strong) NSString* facebookAccessToken;
@property (strong) NSString* facebookUserIdentifier;
@property (strong) NSString* facebookEmail;
@property (strong) NSString* facebookFirstName;
@property (strong) NSString* facebookLastName;
@property (strong) NSString* facebookProfilePictureURL;

@property (strong) NSString* googlePlusAccessToken;
@property (strong) NSString* googlePlusUserIdentifier;
@property (strong) NSString* googlePlusEmail;
@property (strong) NSString* googlePlusFirstName;
@property (strong) NSString* googlePlusLastName;
@property (strong) NSString* googlePlusProfilePictureURL;

@end

/////////////////////////////////////////////////////

@implementation ZLAAuthorizer

#pragma mark - Initialization

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        [self setup];
        [self facebookSignInSetup];
        [self googlePlusSignInSetup];
    }

    return self;
}

-(void) setup
{
    self.userInfo = [[ZLAUserInfoContainer alloc] init];
    self.userInfo.identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.authorizationResponseHandler = [[ZLAAuthorizationResponseHandler alloc] initWithUserInfoContainer:self.userInfo];
    self.signedIn = NO;
    self.performingAuthorization = NO;
}

-(void) googlePlusSignInSetup
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = kGooglePlusClientId;
    signIn.scopes = @[ @"profile" ];
    signIn.delegate = self;
    [signIn trySilentAuthentication];
}

-(void) facebookSignInSetup
{
    self.fbLoginView = [[FBLoginView alloc] init];
    self.fbLoginView.delegate = self;
}

#pragma mark - Accessors

-(void) setBaseURL:(NSURL *) baseURL
{
    NSParameterAssert(baseURL);
    self.requestsPerformer = [[ZLARequestsPerformer alloc] initWithBaseURL:baseURL];
    self.requestsPerformer.userIdentifier = self.userInfo.identifier;
}

#pragma mark - Authorization

-(void) performStartupAuthorization
{
    switch ([ZLACredentialsStorage authorizationMethod]) {
        case ZLAAuthorizationMethodNative:
            [self performNativeAuthorizationWithUserEmail:[ZLACredentialsStorage userEmail]
                                                 password:[ZLACredentialsStorage password]
                                          completionBlock:nil];
            break;

        case ZLAAuthorizationMethodTwitter:
            // TODO: perform mlogin with Twitter credentials
            break;

        default:
            break;
    }
}

-(void) performNativeAuthorizationWithUserEmail:(NSString *) email
                                       password:(NSString *) password
                                completionBlock:(void (^)(BOOL success)) completionBlock
{
    if (!self.nativeAuthorizer) {
        self.nativeAuthorizer = [[ZLANativeAuthorizer alloc] initWithRequestsPerformer:self.requestsPerformer];
    }

    self.performingAuthorization = YES;
    [self.nativeAuthorizer performAuthorizationWithUserEmail:email
                                                    password:password
                                             completionBlock:^(BOOL success, NSDictionary *response)
                                             {
                                                 [self.authorizationResponseHandler handleLoginResponse:response];
                                                 self.signedIn = success;

                                                 if (success) {
                                                     [ZLACredentialsStorage setUserEmail:email];
                                                     [ZLACredentialsStorage setPassword:password];
                                                 }

                                                 if (completionBlock) {
                                                     completionBlock(success);
                                                 }

                                                 self.performingAuthorization = NO;
                                             }];
}

-(void) performTwitterAuthorizationWithAPIKey:(NSString *) APIKey
                                    APISecret:(NSString *) APISecret
                              completionBlock:(void (^)(BOOL success)) completionBlock
{
    if (!self.twitterAuthorizer) {
        self.twitterAuthorizer = [[ZLATwitterAuthorizer alloc] initWithRequestsPerformer:self.requestsPerformer];
    }
    self.twitterAuthorizer.consumerKey = APIKey;
    self.twitterAuthorizer.consumerSecret = APISecret;

    self.performingAuthorization = YES;

    [self.twitterAuthorizer performAuthorizationWithCompletionHandler:^(BOOL success, NSDictionary *response) {
        [self.authorizationResponseHandler handleLoginResponse:response];
        self.signedIn = success;

        if (completionBlock) {
            completionBlock(success);
        }

        self.performingAuthorization = NO;
    }];
}

#pragma mark - Facebook login protocol

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    self.facebookAccessToken = FBSession.activeSession.accessTokenData.accessToken;
    self.facebookUserIdentifier = user.id;
    self.facebookEmail = user[@"email"];
    self.facebookFirstName = user[@"first_name"];
    self.facebookLastName = user[@"last_name"];
    self.facebookProfilePictureURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user.id];

    [self performAuthorizationRequestWithParameters:[self buildRequestParametersForSocialNetwork:kFacebook]];
}

#pragma mark - Google+ sign in protocol

-(void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                  error: (NSError *) error
{
    if (!error) {
        self.googlePlusAccessToken = auth.accessToken;
        self.googlePlusEmail = [GPPSignIn sharedInstance].authentication.userEmail;

        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];

        plusService.apiVersion = @"v1";
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket* ticket,
                        GTLPlusPerson* person,
                        NSError* error) {
                    if (!error) {
                        self.googlePlusUserIdentifier = person.identifier;
                        NSURL* urlForProfilePictureRequest = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://picasaweb.google.com/data/entry/api/user/%@?alt=json",person.identifier]];

                        NSURLRequest* request = [NSURLRequest requestWithURL:urlForProfilePictureRequest];
                        AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {

                            self.googlePlusProfilePictureURL = [self getGooglePlusProfilePictureFromJSON:responseObject];

                            [self performAuthorizationRequestWithParameters:[self buildRequestParametersForSocialNetwork:kGooglePlus]];
                        }
                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         }
                        ];
                        [operation start];

                        self.googlePlusFirstName = person.name.givenName;
                        self.googlePlusLastName = person.name.familyName;
                    }
                }];
    }
}

-(NSString *) getGooglePlusProfilePictureFromJSON:(id) responseObject
{
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    return response[@"entry"][@"gphoto$thumbnail"][@"$t"];
}

-(void) showAuthAlertForSocialNetwork:(NSString *) socialNetworkName
{
    NSString* message = nil;
    if (socialNetworkName == kFacebook) {
        message = [NSString stringWithFormat:@"Your name is %@ %@, e-mail: %@, avatar URL: %@, access token: %@",
                                             self.facebookFirstName,
                                             self.facebookLastName,
                                             self.facebookEmail,
                                             self.facebookProfilePictureURL,
                                             self.facebookAccessToken];
    }
    else if (socialNetworkName == kGooglePlus) {
        message = [NSString stringWithFormat:@"Your name is %@ %@, e-mail: %@, avatar URL: %@, access token: %@",
                                             self.googlePlusFirstName,
                                             self.googlePlusLastName,
                                             self.googlePlusEmail,
                                             self.googlePlusProfilePictureURL,
                                             self.googlePlusAccessToken];
    }
    
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You're logged in with %@", socialNetworkName]
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - Google+ sign in delegate

-(BOOL)application: (UIApplication *)application
           openURL: (NSURL *)url
 sourceApplication: (NSString *)sourceApplication
        annotation: (id)annotation
{
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

#pragma mark - authorization request

-(NSDictionary *) buildRequestParametersForSocialNetwork:(NSString *) socialNetwork
{
    NSMutableDictionary* parameters = nil;

    if (socialNetwork == kFacebook) {
        parameters = [@{kZLAFirstNameKey        : self.facebookFirstName,
                        kZLALastNameKey         : self.facebookLastName,
                        kZLAProfilePictureKey   : self.facebookProfilePictureURL,
                        kZLAFacebookUserNameKey : self.facebookUserIdentifier,
                        kZLAUserNameKey         : self.facebookEmail} mutableCopy];
    }
    else if (socialNetwork == kGooglePlus) {
        parameters = [@{kZLAFirstNameKey            : self.googlePlusFirstName,
                        kZLALastNameKey             : self.googlePlusLastName,
                        kZLAProfilePictureKey       : self.googlePlusProfilePictureURL,
                        kZLAGooglePlusUserNameKey   : self.googlePlusUserIdentifier,
                        kZLAUserNameKey             : self.googlePlusEmail} mutableCopy];
    }

    return parameters;
}

-(void) performAuthorizationRequestWithParameters:(NSDictionary *) parameters
{
    [self.requestsPerformer POST:kZLALoginRequestPath
                      parameters:parameters
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {
                   if (success) {
                       if (parameters[kZLAFacebookUserNameKey]) {
                           [self showAuthAlertForSocialNetwork:kFacebook];
                       }
                       else if (parameters[kZLAGooglePlusUserNameKey]) {
                           [self showAuthAlertForSocialNetwork:kGooglePlus];
                       }
                   }
                   else {
                       [[[UIAlertView alloc] initWithTitle:@"Error"
                                                   message:@"You're not signed in"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil] show];
                   }
               }];
}


-(void) signOut
{
    [ZLACredentialsStorage wipeOutExistingCredentials];
    [ZLACredentialsStorage resetAuthorizationMethod];
    self.signedIn = NO;
}

@end

/////////////////////////////////////////////////////