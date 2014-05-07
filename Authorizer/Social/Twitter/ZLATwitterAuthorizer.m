//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Bolts.h"

#import <ZLNetworkRequestsPerformer/ZLNetworkRequestsPerformer.h>

#import "ZLATwitterAuthorizer.h"
#import "ZLATwitterAPIRequestsPerformer.h"
#import "ZLASocialAuthorizationRequester.h"
#import "ZLATwitterAccountsAccessor.h"
#import "ZLACredentialsStorage.h"
#import "ZLAConstants.h"
#import "ZLAUserInfoContainer.h"

#import "NSString+Validation.h"
#import "UIAlertView+BlocksKit.h"
#import "UIAlertView+ZLAuthorizer.h"

/////////////////////////////////////////////////////

static NSString *const ZLATwitterAccessKeyKey = @"oauth_token";
static NSString *const ZLATwitterAccessSecretKey = @"oauth_token_secret";

static NSString *const ZLATwitterProfileImageURLKey = @"profile_image_url";
static NSString *const ZLATwitterScreenNameKey = @"screen_name";

static NSString *const ZLATwitterAuthorizerSuccessKey = @"success";
static NSString *const ZLATwitterAuthorizerResponseKey = @"response";

/////////////////////////////////////////////////////

@interface ZLATwitterAuthorizer () < UIActionSheetDelegate >

@property (strong) ZLATwitterAPIRequestsPerformer *twitterAPIRequester;
@property (strong) ZLASocialAuthorizationRequester *requester;
@property (strong) ZLATwitterAccountsAccessor *accountsAccessor;

@property (strong) NSString *accessToken;
@property (strong) NSString *accessTokenSecret;

@property (strong) NSString *twitterUserName;
@property (strong) NSString *fullUserName;
@property (strong) NSString *profilePictureAddress;

@end

/////////////////////////////////////////////////////

@implementation ZLATwitterAuthorizer

#pragma mark - Initialization

-(instancetype) init
{
    self = [self initWithRequestsPerformer:nil];
    if (self) {
    }

    return self;
}

//
// designated initializer
//

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    self = [super init];
    if (self) {
        [self setupWithRequestsPerformer:requestsPerformer];
    }

    return self;
}

-(void) setupWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    self.twitterAPIRequester = [[ZLATwitterAPIRequestsPerformer alloc] init];
    self.requester = [[ZLASocialAuthorizationRequester alloc] initWithRequestsPerformer:requestsPerformer];
    self.accountsAccessor = [[ZLATwitterAccountsAccessor alloc] init];
}

#pragma mark - State

-(void) reset
{
    self.accessToken = nil;
    self.accessTokenSecret = nil;

    self.twitterUserName = nil;
    self.fullUserName = nil;
    self.profilePictureAddress = nil;
}

#pragma mark - Authorization

-(void) performAuthorizationWithCompletionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock
{
    BFTask *reverseAuthTask = [self performReverseAuthorization];
    BFTask *accessTokenValidationTask = [reverseAuthTask continueWithBlock:^id(BFTask *task)
    {
        BFTask *nextTask = nil;

        if ([task.result boolValue]) {
            nextTask = [self validateAccessToken];;
        }
        else {
            if (completionBlock) {
                completionBlock(NO, nil);
            }
        }

        return nextTask;
    }];

    BFTask *loginTask = [accessTokenValidationTask continueWithBlock:^id(BFTask *task)
             {
                 BFTask *nextTask = nil;

                 if ([task.result boolValue]) {
                     if ([ZLACredentialsStorage userEmail]) {
                         nextTask = [self loginWithTwitterCredentials];
                     }
                     else {
                         nextTask = [self askUserForEmailAndLogin];
                     }
                 }
                 else {
                     if (completionBlock) {
                         completionBlock(NO, nil);
                     }
                 }

                 return nextTask;
             }];

    [loginTask continueWithBlock:^id(BFTask *task)
    {
        if (completionBlock) {
            NSDictionary *result = task.result;
            BOOL success = [result[ZLATwitterAuthorizerSuccessKey] boolValue];
            NSDictionary *response = result[ZLATwitterAuthorizerResponseKey];

            completionBlock(success, response);
        }

        return nil;
    }];
}

-(void) loginWithExistingCredentialsWithCompletionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock
{
    self.twitterUserName = [ZLACredentialsStorage socialUserIdentifier];
    self.accessToken = [ZLACredentialsStorage socialAccessToken];

    [self.requester performLoginWithSocialNetworkIdentifier:ZLASocialNetworkTwitter
                                             userIdentifier:[ZLACredentialsStorage socialUserIdentifier]
                                                accessToken:[ZLACredentialsStorage socialAccessToken]
                                                  firstName:@""
                                                   lastName:@""
                                      profilePictureAddress:@""
                                            completionBlock:^(BOOL authorizationSuccess, NSDictionary *authorizationResponse)
                                            {
                                                if (completionBlock)
                                                {
                                                    completionBlock(authorizationSuccess, authorizationResponse);
                                                }
                                            }];
}

#pragma mark - OAuth

-(BFTask *) performReverseAuthorization
{
    NSAssert(self.consumerKey, @"no API key to authorize with");
    NSAssert(self.consumerSecret, @"no API secret to authorize with");

    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [self.accountsAccessor askUserToChooseAccountWithCompletionBlock:^(ACAccount *account)
    {
        if (account)
        {
            [[self performReverseAuthorizationWithAccount:account] continueWithBlock:^id(BFTask *task)
            {
                [taskCompletionSource setResult:task.result];
                return nil;
            }];
        }
        else
        {
            [taskCompletionSource setResult:@NO];
        }
    }];

    return taskCompletionSource.task;
}

-(BFTask *) performReverseAuthorizationWithAccount:(ACAccount *) account
{
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [self.twitterAPIRequester performReverseAuthWithAccount:account
                                                consumerKey:self.consumerKey
                                             consumerSecret:self.consumerSecret
                                          completionHandler:^(NSData *data, NSError *error)
                                          {
                                              if (data && !error) {
                                                  [self handleAuthorizationResponseData:data];

                                                  [[self getUserInfoFromTwitter] continueWithBlock:^id(BFTask *task)
                                                  {
                                                      [taskCompletionSource setResult:task.result];
                                                      return nil;
                                                  }];
                                              }
                                              else {
                                                  [self showLoginFailedAlert];
                                                  [taskCompletionSource setResult:@NO];
                                              }
                                          }];
    return taskCompletionSource.task;
}

-(void) handleAuthorizationResponseData:(NSData *) responseData
{
    NSString *responseStr = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
    NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
    for (NSString *responsePart in parts)
    {
        [self handleResponsePart:responsePart];
    }
}

-(void) handleResponsePart:(NSString *) responsePart
{
    NSArray *keyAndValue = [responsePart componentsSeparatedByString:@"="];
    NSString *key = [keyAndValue firstObject];
    NSString *value = keyAndValue[1];

    if ([key isEqualToString:ZLATwitterAccessKeyKey])
    {
        self.accessToken = value;
    }
    else if ([key isEqualToString:ZLATwitterAccessSecretKey])
    {
        self.accessTokenSecret = value;
    }
}

-(BFTask *) getUserInfoFromTwitter
{
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [self.twitterAPIRequester verifyCredentialsWithConsumerKey:self.consumerKey
                                                consumerSecret:self.consumerSecret
                                                     accessKey:self.accessToken
                                                  accessSecret:self.accessTokenSecret
                                             completionHandler:^(NSDictionary *response, NSError *userInfoRequestError)
                                             {
                                                 if (response && !userInfoRequestError)
                                                 {
                                                     [self handleUserInfoResponse:response];
                                                     [taskCompletionSource setResult:@YES];
                                                 }
                                                 else
                                                 {
                                                     [taskCompletionSource setResult:@NO];
                                                 }
                                             }];
    return taskCompletionSource.task;
}

-(void) handleUserInfoResponse:(NSDictionary *) response
{
    self.fullUserName = response[ZLAFullUserNameKey];
    self.twitterUserName = response[ZLATwitterScreenNameKey];
    self.profilePictureAddress = response[ZLATwitterProfileImageURLKey];
}

-(void) showLoginFailedAlert
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [[[UIAlertView alloc] initWithTitle:@"Twitter login"
                                    message:@"Unable to login with Twitter. "
                                            "Check if credentials of account you chose "
                                            "are valid or try to login with another account"
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil] show];
    });
}

#pragma mark - Access token validation

-(BFTask *) validateAccessToken
{
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [self.requester validateTwitterAccessToken:self.accessToken
                               forUserWithName:self.twitterUserName
                               completionBlock:^(BOOL success, NSDictionary *response) {
                                   if (success) {
                                       [self handleAccessTokenValidationResponse:response];
                                   }

                                   [taskCompletionSource setResult:@(success)];
                               }];

    return taskCompletionSource.task;
}

-(void) handleAccessTokenValidationResponse:(NSDictionary *) response
{
    NSString *email = response[ZLAUserEmailKey];
    if (email.length > 0) {
        [ZLACredentialsStorage setUserEmail:email];
    }
    else {
        [ZLACredentialsStorage setUserEmail:nil];
    }
}

-(BFTask *) loginWithTwitterCredentials
{
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [self.requester performLoginWithSocialNetworkIdentifier:nil
                                             userIdentifier:self.twitterUserName
                                                accessToken:self.accessToken
                                                  firstName:[ZLAUserInfoContainer firstNameOfFullName:self.fullUserName]
                                                   lastName:[ZLAUserInfoContainer lastNameOfFullName:self.fullUserName]
                                      profilePictureAddress:self.profilePictureAddress
                                            completionBlock:^(BOOL authorizationSuccess, NSDictionary *authorizationResponse)
                                            {
                                                if (authorizationSuccess)
                                                {
                                                    [self handleLoginSuccess];
                                                }

                                                [taskCompletionSource setResult:[self loginResultWithSuccess:authorizationSuccess
                                                                                                    response:authorizationResponse]];
                                            }];

    return taskCompletionSource.task;
}

-(void) handleLoginSuccess
{
    [ZLACredentialsStorage setSocialUserIdentifier:self.twitterUserName];
    [ZLACredentialsStorage setSocialAccessToken:self.accessToken];
}

-(NSDictionary *) loginResultWithSuccess:(BOOL) success
                                response:(NSDictionary *) response
{
    NSMutableDictionary *result = [@{ZLATwitterAuthorizerSuccessKey : @(success)} mutableCopy];
    if (response) {
        result[ZLATwitterAuthorizerResponseKey] = response;
    }

    return result;
}

-(BFTask *) askUserForEmailAndLogin
{
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [[[self askUserForEmail] continueWithBlock:^id(BFTask *task)
    {
        BFTask *nextTask = nil;
        NSString *email = task.result;
        if (email)
        {
            if ([email isValidEmail]) {
                [ZLACredentialsStorage setUserEmail:email];
                nextTask = [self loginWithTwitterCredentials];
            }
            else {
                [UIAlertView ZLA_showInvalidEmailAlertForSignin:email];
            }
        }
        else
        {
            [self reset];
            [taskCompletionSource setResult:[self loginResultWithSuccess:NO
                                                                response:nil]];
        }

        return nextTask;
    }]
            continueWithBlock:^id(BFTask *task)
    {
        [taskCompletionSource setResult:task.result];
        return nil;
    }];

    return taskCompletionSource.task;
}

-(BFTask *) askUserForEmail
{
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    dispatch_async(dispatch_get_main_queue(), ^
    {
        UIAlertView *emailRequestAlert = [[UIAlertView alloc] initWithTitle:@"Email required"
                                                                    message:@"Please provide us with your email to complete authorization"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"Done",
                                                                            nil];
        emailRequestAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [emailRequestAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
        [emailRequestAlert bk_setDidDismissBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
        {
            if (buttonIndex == alertView.cancelButtonIndex) {
                [taskCompletionSource setResult:nil];
            }
            else {
                [taskCompletionSource setResult:[alertView textFieldAtIndex:0].text];
            }
        }];

        [emailRequestAlert show];
    });

    return taskCompletionSource.task;
}

@end

/////////////////////////////////////////////////////
