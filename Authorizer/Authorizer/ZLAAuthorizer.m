//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import <ZLNetworkRequestsPerformer/ZLNetworkRequestsPerformer.h>
#import <ZLNetworkRequestsPerformer/ZLNetworkReachabilityObserver.h>

#import "ZLAAuthorizer.h"

#import "ZLACredentialsStorage.h"
#import "ZLATwitterAuthorizer.h"
#import "ZLANativeAuthorizer.h"
#import "ZLAAuthorizationResponseHandler.h"
#import "ZLAUserInfoContainer.h"
#import "ZLAAccountInfoUpdater.h"
#import "ZLAConstants.h"

#import "NSString+Validation.h"
#import "UIDevice+IdentifierAddition.h"

#import <UIAlertView+BlocksKit.h>

/////////////////////////////////////////////////////

@interface ZLAAuthorizer () <ZLAAuthorizationResponseHandlerDelegate>
{
    __strong ZLANativeAuthorizer *_nativeAuthorizer;
    __strong ZLATwitterAuthorizer *_twitterAuthorizer;
    __strong ZLAAccountInfoUpdater *_accountInfoUpdater;
}

@property (strong) ZLNetworkRequestsPerformer *requestsPerformer;
@property (strong) ZLNetworkReachabilityObserver *reachabilityObserver;

@property (readonly) ZLATwitterAuthorizer *twitterAuthorizer;
@property (readonly) ZLANativeAuthorizer *nativeAuthorizer;
@property (readonly) ZLAAccountInfoUpdater *accountInfoUpdater;

@property (strong) ZLAAuthorizationResponseHandler *authorizationResponseHandler;
@property (strong) ZLAUserInfoContainer *userInfo;

@property (readwrite) BOOL signedIn;
@property (readwrite) BOOL performingRequest;
@property (readwrite, atomic) BOOL shouldTryAuthorizeAutomatically;

@end

/////////////////////////////////////////////////////

@implementation ZLAAuthorizer

#pragma mark - Initialization

-(instancetype) init
{
    @throw [NSException exceptionWithName:@"NoInitMethod"
                                   reason:@"User initWithBaseURL:appIdentifier: for initialization purposes"
                                 userInfo:nil];
}

-(instancetype) initWithBaseURL:(NSURL *) baseURL
                  appIdentifier:(NSString *) appIdentifier
{
    self = [super init];
    if (self)
    {
        [self setupWithBaseURL:baseURL
                 appIdentifier:appIdentifier];
    }

    return self;
}

-(void) setupWithBaseURL:(NSURL *) baseURL
           appIdentifier:(NSString *) appIdentifier
{
    [self setupUserInfoContainer];
    [self setupRequestsPerformerWithBaseURL:baseURL
                              appIdentifier:appIdentifier];
    [self setupAuthResponseHandler];
    [self resetState];
    [self setupReachabilityObserverWithURL:baseURL];
}

-(void) setupUserInfoContainer
{
    self.userInfo = [[ZLAUserInfoContainer alloc] init];
    if (!self.userInfo.identifier)
    {
        self.userInfo.identifier = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    }
}

-(void) setupRequestsPerformerWithBaseURL:(NSURL *) baseURL
                            appIdentifier:(NSString *) appIdentifier
{
    self.requestsPerformer = [[ZLNetworkRequestsPerformer alloc] initWithBaseURL:baseURL
                                                                   appIdentifier:appIdentifier];
    self.requestsPerformer.userIdentifier = self.userInfo.identifier;
}

-(void) setupReachabilityObserverWithURL:(NSURL *) URL
{
    self.reachabilityObserver = [[ZLNetworkReachabilityObserver alloc] initWithURL:URL];
    [self tryToAuthorizeAutomatically];
    [self subscribeForReachabilityNotifications];
}

-(void) tryToAuthorizeAutomatically
{
    if (self.reachabilityObserver.networkReachable) {
        [self performAutomaticAuthorization];
    }
}

-(void) subscribeForReachabilityNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tryToAuthorizeAutomatically)
                                                 name:ZLNNetworkReachabilityStatusChangeNotification
                                               object:self.reachabilityObserver];
}

-(void) setupAuthResponseHandler
{
    self.authorizationResponseHandler = [[ZLAAuthorizationResponseHandler alloc] initWithUserInfoContainer:self.userInfo];
    self.authorizationResponseHandler.delegate = self;
}

-(void) resetState
{
    self.signedIn = NO;
    self.performingRequest = NO;
    self.shouldTryAuthorizeAutomatically = YES;
}

#pragma mark - Accessors

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

-(ZLAAccountInfoUpdater *) accountInfoUpdater
{
    if (!_accountInfoUpdater)
    {
        _accountInfoUpdater = [[ZLAAccountInfoUpdater alloc] initWithRequestsPerformer:self.requestsPerformer];
    }

    return _accountInfoUpdater;
}

#pragma mark - Authorization

-(void) performAutomaticAuthorization
{
    if (self.signedIn || self.performingRequest || !self.shouldTryAuthorizeAutomatically) {
        return;
    }

    switch ([ZLACredentialsStorage authorizationMethod])
    {
        case ZLAAuthorizationMethodNative:
        {
            self.performingRequest = YES;
            [self.nativeAuthorizer performAuthorizationWithEmail:[ZLACredentialsStorage userEmail]
                                                        password:[ZLACredentialsStorage password]
                                                 completionBlock:^(BOOL success, NSDictionary *response)
                                                 {
                                                     [self handleAuthorizationResponse:response
                                                                               success:success
                                                                       completionBlock:nil];
                                                     self.performingRequest = NO;
                                                 }];
            break;
        }

        case ZLAAuthorizationMethodTwitter:
        {
            self.performingRequest = YES;
            [self.twitterAuthorizer loginWithExistingCredentialsWithCompletionBlock:^(BOOL success, NSDictionary *response)
            {
                [self handleAuthorizationResponse:response
                                          success:success
                                  completionBlock:nil];
                self.performingRequest = NO;
            }];
            break;
        }

        default:
            break;
    }
}

-(void) performNativeAuthorizationWithUserEmail:(NSString *) email
                                       password:(NSString *) password
                                completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    if (self.performingRequest) {
        return;
    }

    self.shouldTryAuthorizeAutomatically = NO;
    self.performingRequest = YES;
    [self.nativeAuthorizer performAuthorizationWithEmail:email
                                                password:password
                                         completionBlock:^(BOOL success, NSDictionary *response)
                                         {
                                             if (success) {
                                                 [ZLACredentialsStorage setAuthorizationMethod:ZLAAuthorizationMethodNative];
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
    if (self.performingRequest) {
        return;
    }

    self.shouldTryAuthorizeAutomatically = NO;
    self.performingRequest = YES;

    self.twitterAuthorizer.consumerKey = APIKey;
    self.twitterAuthorizer.consumerSecret = APISecret;

    [self.twitterAuthorizer performAuthorizationWithCompletionBlock:^(BOOL success, NSDictionary *response)
    {
        if (success) {
            [ZLACredentialsStorage setAuthorizationMethod:ZLAAuthorizationMethodTwitter];
        }

        [self handleAuthorizationResponse:response
                                  success:success
                          completionBlock:completionBlock];
    }];
}

-(void) handleAuthorizationResponse:(NSDictionary *) response
                            success:(BOOL) success
                    completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    if (!success) {
        [ZLACredentialsStorage wipeOutExistingCredentials];
    }

    if (response) {
        [self.authorizationResponseHandler handleLoginResponse:response];
    }

    if (completionBlock) {
        completionBlock(success);
    }

    self.signedIn = success;
    self.performingRequest = NO;
}

-(void) signOut
{
    [ZLACredentialsStorage wipeOutExistingCredentials];
    [ZLACredentialsStorage resetAuthorizationMethod];
    self.userInfo.identifier = [[UIDevice currentDevice] uniqueDeviceIdentifier];
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

#pragma mark - Account info

-(void) updateAccountWithUserName:(NSString *) userName
                         password:(NSString *) password
                   additionalInfo:(NSDictionary *) info
                  completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    NSMutableDictionary *completeInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    [completeInfo addEntriesFromDictionary:[self accountInfoWithFullName:userName
                                                                password:password]];
    self.performingRequest = YES;
    [self.accountInfoUpdater updateAccountWithInfo:completeInfo
                                   completionBlock:^(BOOL success, NSDictionary *response)
                                   {
                                       self.performingRequest = NO;
                                       [self updateUserInfoWithInfo:completeInfo
                                                accordingToResponse:response];

                                       if (completionBlock)
                                       {
                                           completionBlock(success);
                                       }
                                   }];
}

-(NSDictionary *) accountInfoWithFullName:(NSString *) fullName
                                 password:(NSString *) password
{
    NSParameterAssert(fullName);
    NSParameterAssert(password);

    return @{kZLAFirstNameKey           : [ZLAUserInfoContainer firstNameOfFullName:fullName],
             kZLALastNameKey            : [ZLAUserInfoContainer lastNameOfFullName:fullName],
             kZLAUserEmailKey           : emptyIfNil(self.userInfo.email),
             ZLAUserPasswordOnUpdateKey : password};
}

-(void) updateUserInfoWithInfo:(NSDictionary *) info
           accordingToResponse:(NSDictionary *) response
{
    NSArray *keys = response.allKeys;
    for (NSString *key in keys)
    {
        BOOL shouldUpdateValue = [response[key] boolValue];
        if (shouldUpdateValue)
        {
            @try
            {
                [self.userInfo setValue:info[key]
                                 forKey:key];
            }
            @catch (NSException *exception)
            {
                // no such value in user info!
            }
        }
    }
}

@end

/////////////////////////////////////////////////////