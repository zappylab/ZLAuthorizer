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

/////////////////////////////////////////////////////

static NSString * const kGooglePlusClientId = @"17100019704-o162em5ouc56mcel4omjbr9v7b9p10lt.apps.googleusercontent.com";
static NSString * const kGooglePlusAPIkey = @"AIzaSyDVPAzVk-foSqpd3Mz7IfKbxnTygpLoNYo";

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
@property (strong) NSString* googlePlusAccessToken;
@property (strong) NSString* googlePlusEmail;
@property (strong) NSString* googlePlusFullName;

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

    self.fbLoginView = [[FBLoginView alloc] init];
    self.fbLoginView.delegate = self;

    [self googlePlusSignInSetup];
}

-(void) googlePlusSignInSetup
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = kGooglePlusClientId;
    signIn.scopes = @[ @"profile" ];
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
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

-(void) performFacebookAuthorizationWithAppIdKey:(NSString *) appId
                                 completionBlock:(void (^)(BOOL success)) completionBlock
{

}

#pragma mark - Facebook login protocol

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    NSString* accessToken = FBSession.activeSession.accessTokenData.accessToken;
    NSString* avatarURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user.id];
    [[[UIAlertView alloc] initWithTitle:@"You're logged in"
                                message:[NSString stringWithFormat:@"Your name is %@, e-mail: %@, avatar URL: %@, access token: %@", user.name, user[@"email"], avatarURL, accessToken]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}


#pragma mark - Google+ sign in protocol

-(void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                  error: (NSError *) error
{
    if (error) {
        NSLog(@"Received error %@ and auth object %@",error, auth);
    }
    else {
        self.googlePlusAccessToken = auth.accessToken;
        
        self.googlePlusEmail = [GPPSignIn sharedInstance].authentication.userEmail;
        
        // 1. Create a |GTLServicePlus| instance to send a request to Google+.
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        
        // 2. Set a valid |GTMOAuth2Authentication| object as the authorizer.
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        // *4. Use the "v1" version of the Google+ API.*
        plusService.apiVersion = @"v1";
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        //Handle Error
                    }
                    else {
                        
/*
 NSURL *urlForProfilePictureRequest = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://www.googleapis.com/plus/v1/people/%@?fields=image&key=%@",person.identifier,kGooglePlusAPIkey]];
                        
                        NSURLRequest *request = [NSURLRequest requestWithURL:urlForProfilePictureRequest];
                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                                             initWithRequest:request];
                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation
                                                                   , id responseObject) {
                            // code
                        }
                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             // code
                                                         }
                         ];
                        [operation start];*/
                        
                        self.googlePlusFullName = [person.name.givenName stringByAppendingFormat:@" %@",person.name.familyName];
                        [self showGooglePlusAuthAlert];
                    }
                }];
    }
}

-(void) showGooglePlusAuthAlert
{
    [[[UIAlertView alloc] initWithTitle:@"You're logged in"
                                message:[NSString stringWithFormat:@"Your name is %@, e-mail: %@, avatar URL: %@, access token: %@", self.googlePlusFullName, self.googlePlusEmail, nil, self.googlePlusAccessToken]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - Google+ sign in delegate

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation
{
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

-(void) signOut
{
    [ZLACredentialsStorage wipeOutExistingCredentials];
    [ZLACredentialsStorage resetAuthorizationMethod];
    self.signedIn = NO;
}

@end

/////////////////////////////////////////////////////