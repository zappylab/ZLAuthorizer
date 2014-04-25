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

/////////////////////////////////////////////////////

@interface ZLAAuthorizer ()

@property (strong) ZLARequestsPerformer *requestsPerformer;
@property (strong) ZLATwitterAuthorizer *twitterAuthorizer;
@property (strong) ZLANativeAuthorizer *nativeAuthorizer;
@property (strong) ZLAAuthorizationResponseHandler *authorizationResponseHandler;
@property (strong) ZLAUserInfoContainer *userInfo;

@property (readwrite) BOOL signedIn;
@property (readwrite) BOOL performingAuthorization;

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

-(void) signOut
{
    [ZLACredentialsStorage wipeOutExistingCredentials];
    [ZLACredentialsStorage resetAuthorizationMethod];
    self.signedIn = NO;
}

@end

/////////////////////////////////////////////////////