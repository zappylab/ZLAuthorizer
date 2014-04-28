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

#import <UIAlertView+BlocksKit.h>

/////////////////////////////////////////////////////

@interface ZLAAuthorizer () <ZLAAuthorizationResponseHandlerDelegate>
{
    __strong ZLANativeAuthorizer *_nativeAuthorizer;
    __strong ZLATwitterAuthorizer *_twitterAuthorizer;
}

@property (strong) ZLARequestsPerformer *requestsPerformer;
@property (readonly) ZLATwitterAuthorizer *twitterAuthorizer;
@property (readonly) ZLANativeAuthorizer *nativeAuthorizer;
@property (strong) ZLAAuthorizationResponseHandler *authorizationResponseHandler;
@property (strong) ZLAUserInfoContainer *userInfo;

@property (readwrite) BOOL signedIn;
@property (readwrite) BOOL performingRequest;

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
    self.authorizationResponseHandler.delegate = self;
    self.signedIn = NO;
    self.performingRequest = NO;
}

#pragma mark - Accessors

-(void) setBaseURL:(NSURL *) baseURL
{
    NSParameterAssert(baseURL);
    self.requestsPerformer = [[ZLARequestsPerformer alloc] initWithBaseURL:baseURL];
    self.requestsPerformer.userIdentifier = self.userInfo.identifier;
}

-(ZLANativeAuthorizer *) nativeAuthorizer
{
    if (!_nativeAuthorizer)
    {
        _nativeAuthorizer = [[ZLANativeAuthorizer alloc] initWithRequestsPerformer:self.requestsPerformer];
    }

    return _nativeAuthorizer;
}

-(ZLATwitterAuthorizer *) twitterAuthorizer
{
    if (!_twitterAuthorizer)
    {
        _twitterAuthorizer = [[ZLATwitterAuthorizer alloc] initWithRequestsPerformer:self.requestsPerformer];
    }

    return _twitterAuthorizer;
}

#pragma mark - Authorization

-(void) performStartupAuthorization
{
    switch ([ZLACredentialsStorage authorizationMethod])
    {
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
                                completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    self.performingRequest = YES;
    [self.nativeAuthorizer performAuthorizationWithUserEmail:email
                                                    password:password
                                             completionBlock:^(BOOL success, NSDictionary *response)
                                             {
                                                 if (success)
                                                 {
                                                     [ZLACredentialsStorage setUserEmail:email];
                                                     [ZLACredentialsStorage setPassword:password];
                                                 }

                                                 [self handleAuthorizationResponse:response
                                                                           success:success
                                                                   completionBlock:completionBlock];
                                             }];
}

-(void) performTwitterAuthorizationWithAPIKey:(NSString *) APIKey
                                    APISecret:(NSString *) APISecret
                              completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    self.performingRequest = YES;

    self.twitterAuthorizer.consumerKey = APIKey;
    self.twitterAuthorizer.consumerSecret = APISecret;

    [self.twitterAuthorizer performAuthorizationWithCompletionHandler:^(BOOL success, NSDictionary *response)
    {
        [self handleAuthorizationResponse:response
                                  success:success
                          completionBlock:completionBlock];
    }];
}

-(void) handleAuthorizationResponse:(NSDictionary *) response
                            success:(BOOL) success
                    completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    if (response) {
        [self.authorizationResponseHandler handleLoginResponse:response];
    }

    if (completionBlock) {
        completionBlock(success);
    }

    self.performingRequest = NO;
    self.signedIn = success;
}

-(void) signOut
{
    [ZLACredentialsStorage wipeOutExistingCredentials];
    [ZLACredentialsStorage resetAuthorizationMethod];
    self.signedIn = NO;
}

#pragma mark -

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    self.performingRequest = YES;
    [self.nativeAuthorizer registerUserWithFullName:fullName
                                              email:email
                                           password:password
                                    completionBlock:^(BOOL success, NSDictionary *response)
                                    {
                                        if (response)
                                        {
                                            [self.authorizationResponseHandler handleRegistrationResponse:response];
                                        }

                                        if (completionBlock)
                                        {
                                            completionBlock(success);
                                        }

                                        self.performingRequest = NO;
                                    }];
}

#pragma mark - ZLAAuthorizationResponseHandlerDelegate methods

-(void) responseHandlerDidDetectSocialLogin
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [UIAlertView bk_showAlertViewWithTitle:@"Sign in"
                                       message:@"You used Twitter to create your account, please use Twitter to login or reset your password to login with ZappyLab account."
                             cancelButtonTitle:@"Close"
                             otherButtonTitles:@[@"Reset password"]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                                       {
                                           if (buttonIndex != alertView.cancelButtonIndex)
                                           {
                                               [self resetPassword];
                                           }
                                       }];
    });
}

-(void) resetPassword
{
    [self.nativeAuthorizer resetPassword];
}

-(void) responseHandlerDidDetectErrorMessage:(NSString *) message
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [[[UIAlertView alloc] initWithTitle:@"Registration"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil] show];
    });
}

@end

/////////////////////////////////////////////////////