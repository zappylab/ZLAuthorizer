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

#import "ZLAFacebookAuthorizer.h"
#import "ZLAGooglePlusAuthorizer.h"

/////////////////////////////////////////////////////

@interface ZLAAuthorizer () {
    __strong ZLAFacebookAuthorizer *_facebookAuthorizer;
    __strong ZLAGooglePlusAuthorizer *_googlePlusAuthorizer;
}

@property (strong) ZLARequestsPerformer *requestsPerformer;
@property (strong) ZLATwitterAuthorizer *twitterAuthorizer;
@property (readonly) ZLAFacebookAuthorizer *facebookAuthorizer;
@property (readonly) ZLAGooglePlusAuthorizer *googlePlusAuthorizer;
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
    if (self) {
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

-(ZLAFacebookAuthorizer *) facebookAuthorizer
{
    if (!_facebookAuthorizer) {
        _facebookAuthorizer = [[ZLAFacebookAuthorizer alloc] initWithRequestsPerformer:self.requestsPerformer];
    }

    return _facebookAuthorizer;
}

-(ZLAGooglePlusAuthorizer *) googlePlusAuthorizer
{
    if (!_googlePlusAuthorizer) {
        _googlePlusAuthorizer = [[ZLAGooglePlusAuthorizer alloc] initWithRequestsPerformer:self.requestsPerformer];
    }

    return _googlePlusAuthorizer;
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

-(void) performFacebookAuthorizationWithCompletionBlock:(void (^)(BOOL success)) completionBlock
{
    [self.facebookAuthorizer performAuthorizationWithCompletionBlock:^(BOOL success, NSDictionary *response)
    {
        [self.authorizationResponseHandler handleLoginResponse:response];
        self.signedIn = success;

        if (completionBlock) {
            completionBlock(success);
        }

        self.performingAuthorization = NO;
    }];
}

-(void) performGooglePlusAuthorizationWithClientId:(NSString *) clientId
                                   completionBlock:(void (^)(BOOL success)) completionBlock
{
    [self.googlePlusAuthorizer performAuthorizationWithClientId:clientId
                                                completionBlock:^(BOOL success, NSDictionary *response)
                                                {
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
    switch ([ZLACredentialsStorage authorizationMethod]) {
        case ZLAAuthorizationMethodFacebook:
            [self.facebookAuthorizer signOut];
            break;

        case ZLAAuthorizationMethodGooglePlus:
            [self.googlePlusAuthorizer signOut];
            break;

        default:
            break;
    }

    [ZLACredentialsStorage wipeOutExistingCredentials];
    [ZLACredentialsStorage resetAuthorizationMethod];
    self.signedIn = NO;
}

@end

/////////////////////////////////////////////////////