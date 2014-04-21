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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }

    return self;
}

-(void) setup
{
    self.userInfo = [[ZLAUserInfoContainer alloc] init];
    self.authorizationResponseHandler = [[ZLAAuthorizationResponseHandler alloc] initWithUserInfoContainer:self.userInfo];
    self.userInfo.identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

#pragma mark - Accessors

-(void)setBaseURL:(NSURL *)baseURL
{
    NSParameterAssert(baseURL);
    self.requestsPerformer = [[ZLARequestsPerformer alloc] initWithBaseURL:baseURL];
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
                                                userIdentifier:self.userInfo.identifier
                                               completionBlock:^(BOOL success, NSDictionary *response)
                                               {
                                                   if (success) {
                                                       [self.authorizationResponseHandler handleLoginResponse:response];
                                                       self.signedIn = YES;
                                                   }
                                                   else {
                                                       [ZLACredentialsStorage setPassword:nil];
                                                   }

                                                   if (completionBlock) {
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
    if (!self.twitterAuthorizer) {
        self.twitterAuthorizer = [[ZLATwitterAuthorizer alloc] init];
    }

    self.twitterAuthorizer.consumerKey = APIKey;
    self.twitterAuthorizer.consumerSecret = APISecret;

    [self.twitterAuthorizer performReverseAuthorizationWithCompletionBlock:^(BOOL success)
    {
        if (success) {
            [self performAuthorizationWithTwitterUserName:self.twitterAuthorizer.twitterUserName
                                              accessToken:self.twitterAuthorizer.accessTokenSecret
                                                firstName:[ZLAUserInfoContainer firstNameOfFullName:self.twitterAuthorizer.fullUserName]
                                                 lastName:[ZLAUserInfoContainer lastNameOfFullName:self.twitterAuthorizer.fullUserName]
                                    profilePictureAddress:self.twitterAuthorizer.profilePictureAddress
                                          completionBlock:^(BOOL authorizationSuccess, NSDictionary *response)
                                          {
                                              if (authorizationSuccess) {
                                                  [self handleTwitterAuthorizationSuccessWithResponse:response];
                                                  self.signedIn = YES;
                                              }

                                              if (completionBlock) {
                                                  completionBlock(authorizationSuccess);
                                              }
                                          }];
        }
        else {
            if (completionBlock) {
                completionBlock(NO);
            }
        }
    }];
}

-(void) performAuthorizationWithTwitterUserName:(NSString *) userName
                                    accessToken:(NSString *) accessToken
                                      firstName:(NSString *) firstName
                                       lastName:(NSString *) lastName
                          profilePictureAddress:(NSString *) profilePictureAddress
                                completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSAssert(self.requestsPerformer, @"unable to perform authorization - server is undefined");

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
    [ZLACredentialsStorage setTwitterAccessTokenSecret:self.twitterAuthorizer.accessTokenSecret];

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