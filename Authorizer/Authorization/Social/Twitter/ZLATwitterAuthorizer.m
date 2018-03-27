//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import <ZLNetworkRequestsPerformer/ZLNetworkRequestsPerformer.h>

#import "ZLATwitterAuthorizer.h"
#import "ZLASocialAuthorizationRequester.h"
#import "ZLACredentialsStorage.h"
#import "ZLAConstants.h"
#import "ZLAUserInfoContainer.h"
#import <TwitterKit/TWTRTwitter.h>

#import "NSString+Validation.h"
#import "UIAlertView+ZLAuthorizer.h"

/////////////////////////////////////////////////////

@interface ZLATwitterAuthorizer ()

@property (strong) ZLASocialAuthorizationRequester *requester;

@property (strong, nonatomic) TWTRSession *session;
@property (strong) NSURLSessionDataTask *loginRequestOperation;

@property (strong) NSString *consumerKey;
@property (strong) NSString *consumerSecret;

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
    if (self)
    {
        
    }

    return self;
}

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    self = [super init];
    if (self)
    {
        [self setupWithRequestsPerformer:requestsPerformer];
    }

    return self;
}

-(void) setupWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    self.requester = [[ZLASocialAuthorizationRequester alloc] initWithRequestsPerformer:requestsPerformer];
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

-(void) performAuthorizationWithConsumerKey:(NSString *) consumerKey
                             consumerSecret:(NSString *) consumerSecret
                     performingRequestBlock:(void(^)(BOOL success)) performRequest
                            completionBlock:(ZLARequestCompletionBlock) completionBlock;
{
    NSParameterAssert(consumerKey);
    NSParameterAssert(consumerSecret);
    
    [[TWTRTwitter sharedInstance] startWithConsumerKey:consumerKey
                                    consumerSecret:consumerSecret];
    self.consumerKey = consumerKey;
    self.consumerSecret = consumerSecret;
    
    [[TWTRTwitter sharedInstance] logInWithCompletion:^(TWTRSession * _Nullable session,
                                                        NSError * _Nullable error)
     {
         if (session)
         {
             self.accessToken = session.authToken;
             self.accessTokenSecret = session.authTokenSecret;
             self.twitterUserName = session.userName;
             if ([ZLACredentialsStorage userEmail])
             {
                 [self loginWithTwitterCredentialsWithCompletion:completionBlock];
             }
             else
             {
                 [self askUserForEmailAndLoginWithCompletion:completionBlock];
             }
         }
         else
         {
             [self stopLoggingInWithExistingCredentials];
             completionBlock(NO, nil, error);
         }
     }];
}

-(void) loginWithExistingCredentialsWithCompletionBlock:(ZLARequestCompletionBlock) completionBlock
{
    self.twitterUserName = [ZLACredentialsStorage socialUserIdentifier];
    self.accessToken = [ZLACredentialsStorage socialAccessToken];
    [self.requester performLoginWithSocialNetworkIdentifier:ZLASocialNetworkTwitter
                                             userIdentifier:[ZLACredentialsStorage socialUserIdentifier]
                                                accessToken:[ZLACredentialsStorage socialAccessToken]
                                                  firstName:@""
                                                   lastName:@""
                                      profilePictureAddress:@""
                                            completionBlock:completionBlock];
}

-(void) loginWithTwitterCredentialsWithCompletion:(ZLARequestCompletionBlock) completionBlock
{
    self.loginRequestOperation = [self.requester performLoginWithSocialNetworkIdentifier:ZLASocialNetworkTwitter
                                                                          userIdentifier:self.twitterUserName
                                                                             accessToken:self.accessToken
                                                                               firstName:[ZLAUserInfoContainer firstNameOfFullName:self.fullUserName]
                                                                                lastName:[ZLAUserInfoContainer lastNameOfFullName:self.fullUserName]
                                                                   profilePictureAddress:self.profilePictureAddress
                                                                         completionBlock:^(BOOL authorizationSuccess, NSDictionary *authorizationResponse, NSError *error)
                                  {
                                      self.loginRequestOperation = nil;

                                      if (authorizationSuccess)
                                      {
                                          [self handleLoginSuccess];
                                      }

                                      completionBlock(authorizationSuccess, authorizationResponse, error);
                                  }];
}

-(void) handleLoginSuccess
{
    [ZLACredentialsStorage setSocialUserIdentifier:self.twitterUserName];
    [ZLACredentialsStorage setSocialAccessToken:self.accessToken];
}

-(NSDictionary *) loginResultWithSuccess:(BOOL) success
                                response:(NSDictionary *) response
{
    NSMutableDictionary *result = [@{@"success" : @(success)} mutableCopy];
    if (response)
    {
        result[@"response"] = response;
    }

    return result;
}

-(void) askUserForEmailAndLoginWithCompletion:(ZLARequestCompletionBlock) completionBlock
{
    TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];
    [client requestEmailForCurrentUser:^(NSString *email,
                                         NSError *error)
     {
         if (email)
         {
             if ([email isValidEmail])
             {
             [ZLACredentialsStorage setUserEmail:email];
                 [self loginWithTwitterCredentialsWithCompletion:completionBlock];
             }
             else
             {
                 [UIAlertView ZLA_showInvalidEmailAlertForSignin:email];
                 completionBlock(NO, nil, error);
             }
         }
         else
         {
             [self reset];
             completionBlock(NO, nil, error);
         }
     }];
}

-(void) stopLoggingInWithExistingCredentials
{
    [self.loginRequestOperation cancel];
    self.loginRequestOperation = nil;
    [self signOut];
}

-(void) signOut
{
    [ZLACredentialsStorage wipeOutExistingCredentials];
}

@end

/////////////////////////////////////////////////////
