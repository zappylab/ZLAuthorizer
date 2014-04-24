//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAAuthorizer.h"

#import "ZLACredentialsStorage.h"
#import "ZLARequestsPerformer.h"
#import "ZLATwitterAuthorizer.h"
#import "ZLAAuthorizationResponseHandler.h"
#import "ZLAUserInfoContainer.h"

#import "NSString+Validation.h"
#import "UIAlertView+BlocksKit.h"

/////////////////////////////////////////////////////

static NSUInteger const kZLAMinPasswordLength = 6;

/////////////////////////////////////////////////////

@interface ZLAAuthorizer ()

@property (strong) ZLARequestsPerformer *requestsPerformer;
@property (strong) ZLATwitterAuthorizer *twitterAuthorizer;
@property (strong) ZLAAuthorizationResponseHandler *authorizationResponseHandler;
@property (strong) ZLAUserInfoContainer *userInfo;

@property (readwrite) BOOL signedIn;

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
}

#pragma mark - Accessors

-(void) setBaseURL:(NSURL *) baseURL
{
    NSParameterAssert(baseURL);
    self.requestsPerformer = [[ZLARequestsPerformer alloc] initWithBaseURL:baseURL];
    self.requestsPerformer.userIdentifier = self.userInfo.identifier;
}

-(NSString *) userName
{
    return [ZLACredentialsStorage userName];
}

-(void) setUserName:(NSString *) userName
{
    [ZLACredentialsStorage setUserName:userName];
}

-(NSString *) password
{
    return [ZLACredentialsStorage password];
}

-(void) setPassword:(NSString *) password
{
    [ZLACredentialsStorage setPassword:password];
}

#pragma mark - Authorization

-(void) performStartupAuthorization
{
    [self performNativeAuthorizationWithCompletionBlock:nil];
}

-(void) performNativeAuthorizationWithCompletionBlock:(void (^)(BOOL success)) completionBlock
{
    NSAssert(self.requestsPerformer, @"unable to perform authorization - server is undefined");

    if ([self hasEnoughDataToPerformNativeAuthorization])
    {
        [self.requestsPerformer performNativeLoginWithUserName:[ZLACredentialsStorage userName]
                                                      password:[ZLACredentialsStorage password]
                                               completionBlock:^(BOOL success, NSDictionary *response)
                                               {
                                                   if (success)
                                                   {
                                                       [self.authorizationResponseHandler handleLoginResponse:response];
                                                       self.signedIn = YES;
                                                   }
                                                   else
                                                   {
                                                       [ZLACredentialsStorage setPassword:nil];
                                                   }

                                                   if (completionBlock)
                                                   {
                                                       completionBlock(success);
                                                   }
                                               }];
    }
}

-(BOOL) hasEnoughDataToPerformNativeAuthorization
{
    return [[ZLACredentialsStorage userName] isValidEmail] && [ZLACredentialsStorage password].length >= kZLAMinPasswordLength;
}

-(void) performTwitterAuthorizationWithAPIKey:(NSString *) APIKey
                                    APISecret:(NSString *) APISecret
                              completionBlock:(void (^)(BOOL success)) completionBlock
{
    if (!self.twitterAuthorizer)
    {
        self.twitterAuthorizer = [[ZLATwitterAuthorizer alloc] init];
    }

    self.twitterAuthorizer.consumerKey = APIKey;
    self.twitterAuthorizer.consumerSecret = APISecret;

    [self.twitterAuthorizer performReverseAuthorizationWithCompletionBlock:^(BOOL success)
    {
        if (success)
        {
            [self validateTwitterAccessToken:self.twitterAuthorizer.accessToken
                             forUserWithName:self.twitterAuthorizer.twitterUserName
                             completionBlock:^(BOOL validationSuccess, NSDictionary *validationResponse)
                             {
                                 if (validationSuccess)
                                 {
                                     [self.authorizationResponseHandler handleTwitterAccessTokenValidationResponse:validationResponse];

                                     if ([ZLACredentialsStorage userName])
                                     {
                                         [self askUserForEmailWithCompletionBlock:completionBlock];
                                     }
                                     else
                                     {
                                         [self loginWithTwitterCredentialsWithCompletionBlock:completionBlock];
                                     }
                                 }
                             }];
        }
        else
        {
            if (completionBlock)
            {
                completionBlock(NO);
            }
        }
    }];
}

-(void) askUserForEmailWithCompletionBlock:(void (^)(BOOL success)) completionBlock
{
    UIAlertView *emailRequestAlert = [[UIAlertView alloc] initWithTitle:@"Email required"
                                                                message:@"Please provide us with your email to complete authorization"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Done", nil];
    emailRequestAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [emailRequestAlert bk_setDidDismissBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
    {
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            [self cancelTwitterAuthorizationWithCompletionBlock:completionBlock];
        }
        else
        {
            NSString *email = [alertView textFieldAtIndex:0].text;
            if ([email isValidEmail])
            {
                [ZLACredentialsStorage setUserName:email];
                [self loginWithTwitterCredentialsWithCompletionBlock:completionBlock];
            }
            else {
                [self showInvalidEmailAlert:email];
                [self cancelTwitterAuthorizationWithCompletionBlock:completionBlock];
            }
        }
    }];

    [emailRequestAlert show];
}

-(void) showInvalidEmailAlert:(NSString *) email
{
    [[[UIAlertView alloc] initWithTitle:@"Login"
                                message:[NSString stringWithFormat:@"%@ is not a valid email",
                                                                   email]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

-(void) cancelTwitterAuthorizationWithCompletionBlock:(void (^)(BOOL)) completionBlock
{
    [self.twitterAuthorizer reset];

    if (completionBlock) {
        completionBlock(NO);
    }
}

-(void) loginWithTwitterCredentialsWithCompletionBlock:(void (^)(BOOL)) completionBlock
{
    [self performAuthorizationWithTwitterUserName:self.twitterAuthorizer.twitterUserName
                                      accessToken:self.twitterAuthorizer.accessToken
                                        firstName:[ZLAUserInfoContainer firstNameOfFullName:self.twitterAuthorizer.fullUserName]
                                         lastName:[ZLAUserInfoContainer lastNameOfFullName:self.twitterAuthorizer.fullUserName]
                            profilePictureAddress:self.twitterAuthorizer.profilePictureAddress
                                  completionBlock:^(BOOL authorizationSuccess, NSDictionary *authorizationResponse)
                                  {
                                      if (authorizationSuccess)
                                      {
                                          [self handleTwitterAuthorizationSuccessWithResponse:authorizationResponse];
                                          self.signedIn = YES;
                                      }

                                      if (completionBlock)
                                      {
                                          completionBlock(authorizationSuccess);
                                      }
                                  }];
}

-(void) validateTwitterAccessToken:(NSString *) accessToken
                   forUserWithName:(NSString *) userName
                   completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    [self checkIfCanPerformRequests];
    [self.requestsPerformer validateTwitterAccessToken:accessToken
                                       forUserWithName:userName
                                       completionBlock:completionBlock];
}

-(void) checkIfCanPerformRequests
{
    NSAssert(self.requestsPerformer, @"unable to perform authorization - server is undefined");
}

-(void) performAuthorizationWithTwitterUserName:(NSString *) userName
                                    accessToken:(NSString *) accessToken
                                      firstName:(NSString *) firstName
                                       lastName:(NSString *) lastName
                          profilePictureAddress:(NSString *) profilePictureAddress
                                completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    [self checkIfCanPerformRequests];
    [self.requestsPerformer performLoginWithTwitterUserName:userName
                                                accessToken:accessToken
                                                  firstName:firstName
                                                   lastName:lastName
                                      profilePictureAddress:profilePictureAddress
                                            completionBlock:completionBlock];
}

-(void) handleTwitterAuthorizationSuccessWithResponse:(NSDictionary *) response
{
    [ZLACredentialsStorage setTwitterUserName:self.twitterAuthorizer.twitterUserName];
    [ZLACredentialsStorage setTwitterAccessToken:self.twitterAuthorizer.accessToken];

    [self.authorizationResponseHandler handleLoginResponse:response];
}

-(BOOL) ableToRegisterUserWithFullName:(NSString *) fullName
                                 email:(NSString *) email
                              password:(NSString *) password
{
    return [email isValidEmail] && fullName.length > 0 && password.length > kZLAMinPasswordLength;
}

@end

/////////////////////////////////////////////////////