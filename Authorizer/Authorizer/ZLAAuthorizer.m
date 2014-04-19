//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAAuthorizer.h"

#import "ZLACredentialsStorage.h"
#import "ZLARequestsPerformer.h"
#import "ZLATwitterAuthorizer.h"
#import "ZLAUserInfo.h"

#import "NSString+Validation.h"

/////////////////////////////////////////////////////

static NSUInteger const kZLAMinPasswordLength = 6;

/////////////////////////////////////////////////////

@interface ZLAAuthorizer ()

@property (strong) ZLARequestsPerformer *requestsPerformer;
@property (strong) ZLATwitterAuthorizer *twitterAuthorizer;
@property (strong) ZLAUserInfo *userInfo;

@end

/////////////////////////////////////////////////////

@implementation ZLAAuthorizer

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {

    }

    return self;
}

-(void)setBaseURL:(NSURL *)baseURL
{
    NSParameterAssert(baseURL);

    self.requestsPerformer = [[ZLARequestsPerformer alloc] initWithBaseURL:baseURL];
}

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
                                                userIdentifier:self.userInfo.usedIdentifier
                                               completionBlock:^(BOOL success)
                                               {
                                                   if (!success) {
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
    return [[ZLACredentialsStorage userName] isValidEmail] && [ZLACredentialsStorage password].length > kZLAMinPasswordLength;
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

    [self.twitterAuthorizer performReverseAuthorizationWithCompletionBlock:^(BOOL success,
            NSString *login,
            NSString *firstName,
            NSString *lastName,
            NSString *profilePictureAddress)
    {
        if (success) {
            [self performAuthorizationWithTwitterUserName:login
                                              accessToken:self.twitterAuthorizer.accessTokenSecret
                                                firstName:firstName
                                                 lastName:lastName
                                    profilePictureAddress:profilePictureAddress
                                          completionBlock:^(BOOL authorizationSuccess)
                                          {
                                              if (completionBlock)
                                              {
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
                                completionBlock:(void (^)(BOOL success)) completionBlock
{
    NSAssert(self.requestsPerformer, @"unable to perform authorization - server is undefined");

    [self.requestsPerformer performLoginWithTwitterUserName:userName
                                                accessToken:accessToken
                                            completionBlock:completionBlock
                                                  firstName:firstName
                                                   lastName:lastName
                                      profilePictureAddress:profilePictureAddress];
}

-(BOOL) ableToRegisterUserWithFullName:(NSString *) fullName
                                 email:(NSString *) email
                              password:(NSString *) password
{
    return [email isValidEmail] && fullName.length > 0 && password.length > kZLAMinPasswordLength;
}

@end

/////////////////////////////////////////////////////