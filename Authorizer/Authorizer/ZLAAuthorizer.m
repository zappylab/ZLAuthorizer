//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import <ZLNetworkRequestsPerformer/ZLNetworkRequestsPerformer.h>
#import <ZLNetworkRequestsPerformer/ZLNetworkReachabilityObserver.h>

#import "ZLAAuthorizer.h"

#import "ZLACredentialsStorage.h"

#import "ZLANativeAuthorizer.h"
#import "ZLATwitterAuthorizer.h"
#import "ZLAFacebookAuthorizer.h"
#import "ZLAGooglePlusAuthorizer.h"
#import "ZLAAutoAuthorizationPerformer.h"

#import "ZLAAuthorizationResponseHandler.h"
#import "ZLAUserInfoContainer.h"
#import "ZLAAccountInfoUpdater.h"
#import "ZLAUserInfoPersistentStore.h"
#import "ZLAConstants.h"

#import "NSString+Validation.h"
#import "UIDevice+IdentifierAddition.h"
#import <UIAlertView+BlocksKit.h>

/////////////////////////////////////////////////////

@interface ZLAAuthorizer () <ZLAAuthorizationResponseHandlerDelegate>
{
    __strong ZLAAccountInfoUpdater *_accountInfoUpdater;

    __strong ZLANativeAuthorizer *_nativeAuthorizer;
    __strong ZLATwitterAuthorizer *_twitterAuthorizer;
    __strong ZLAFacebookAuthorizer *_facebookAuthorizer;
    __strong ZLAGooglePlusAuthorizer *_googlePlusAuthorizer;
}

@property (strong) ZLNetworkRequestsPerformer *requestsPerformer;

@property (readonly) ZLANativeAuthorizer *nativeAuthorizer;
@property (readonly) ZLATwitterAuthorizer *twitterAuthorizer;
@property (readonly) ZLAFacebookAuthorizer *facebookAuthorizer;
@property (readonly) ZLAGooglePlusAuthorizer *googlePlusAuthorizer;
@property (strong) ZLAAutoAuthorizationPerformer *autoAuthorizationPerformer;

@property (readonly) ZLAAccountInfoUpdater *accountInfoUpdater;
@property (strong) ZLAAuthorizationResponseHandler *authorizationResponseHandler;
@property (strong) ZLAUserInfoContainer *userInfo;
@property (strong) ZLAUserInfoPersistentStore *userInfoPersistentStore;

@property (readwrite, atomic) BOOL signedIn;
@property (readwrite, atomic) BOOL performingRequest;

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
    [self tryToPerformAutomaticAuthorizationWithURL:baseURL];
}

-(void) setupUserInfoContainer
{
    self.userInfoPersistentStore = [[ZLAUserInfoPersistentStore alloc] init];
    self.userInfo = [self.userInfoPersistentStore restorePersistedUserInfoContainer];
    if (!self.userInfo)
    {
        self.userInfo = [[ZLAUserInfoContainer alloc] init];
        [self generateUserIdentifier];
        [self.userInfoPersistentStore persistUserInfoContainer:self.userInfo];
    }
}

-(void) generateUserIdentifier
{
    self.userInfo.identifier = [[UIDevice currentDevice] uniqueDeviceIdentifier];
}

-(void) setupRequestsPerformerWithBaseURL:(NSURL *) baseURL
                            appIdentifier:(NSString *) appIdentifier
{
    self.requestsPerformer = [[ZLNetworkRequestsPerformer alloc] initWithBaseURL:baseURL
                                                                   appIdentifier:appIdentifier];
    self.requestsPerformer.userIdentifier = self.userInfo.identifier;
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

-(ZLAFacebookAuthorizer *) facebookAuthorizer
{
    if (!_facebookAuthorizer)
    {
        _facebookAuthorizer = [[ZLAFacebookAuthorizer alloc] initWithRequestsPerformer:self.requestsPerformer];
    }

    return _facebookAuthorizer;
}

-(ZLAGooglePlusAuthorizer *) googlePlusAuthorizer
{
    if (!_googlePlusAuthorizer)
    {
        _googlePlusAuthorizer = [[ZLAGooglePlusAuthorizer alloc] initWithRequestsPerformer:self.requestsPerformer];
    }

    return _googlePlusAuthorizer;
}

#pragma mark - Authorization

-(id <ZLAConcreteAuthorizer>) activeAuthorizer
{
    id <ZLAConcreteAuthorizer> activeAuthorizer = nil;

    switch ([ZLACredentialsStorage authorizationMethod])
    {
        case ZLAAuthorizationMethodNative:
            activeAuthorizer = self.nativeAuthorizer;
            break;

        case ZLAAuthorizationMethodTwitter:
            activeAuthorizer = self.twitterAuthorizer;
            break;

        case ZLAAuthorizationMethodFacebook:
            activeAuthorizer = self.facebookAuthorizer;
            break;

        case ZLAAuthorizationMethodGooglePlus:
            activeAuthorizer = self.googlePlusAuthorizer;
            break;

        default:
            break;
    }

    return activeAuthorizer;
}

-(void) tryToPerformAutomaticAuthorizationWithURL:(NSURL *) URL
{
    id <ZLAConcreteAuthorizer> activeAuthorizer = [self activeAuthorizer];
    if (activeAuthorizer)
    {
        self.signedIn = YES;
        ZLNetworkReachabilityObserver *reachabilityObserver = [[ZLNetworkReachabilityObserver alloc] initWithURL:URL];
        self.autoAuthorizationPerformer = [[ZLAAutoAuthorizationPerformer alloc] initWithReachabilityObserver:reachabilityObserver];
        [self.autoAuthorizationPerformer performAutoAuthorizationWithAuthorizer:activeAuthorizer
                                                                completionBlock:^(BOOL success, NSDictionary *response)
                                                                {
                                                                    if (response)
                                                                    {
                                                                        [self.authorizationResponseHandler handleLoginResponse:response];
                                                                        [self.userInfoPersistentStore persistUserInfoContainer:self.userInfo];
                                                                    }
                                                                }];
    }
}

-(void) performNativeAuthorizationWithUserEmail:(NSString *) email
                                       password:(NSString *) password
                                completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    if (self.performingRequest)
    {
        if (completionBlock)
        {
            completionBlock(NO);
        }

        return;
    }

    self.performingRequest = YES;
    [self.nativeAuthorizer performAuthorizationWithEmail:email
                                                password:password
                                         completionBlock:^(BOOL success, NSDictionary *response)
                                         {
                                             if (success)
                                             {
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
    if (self.performingRequest)
    {
        if (completionBlock)
        {
            completionBlock(NO);
        }

        return;
    }

    self.performingRequest = YES;

    [self.twitterAuthorizer performAuthorizationWithConsumerKey:APIKey
                                                 consumerSecret:APISecret
                                                completionBlock:^(BOOL success, NSDictionary *response)
                                                {
                                                    if (success)
                                                    {
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
    if (!success)
    {
        [ZLACredentialsStorage wipeOutExistingCredentials];
    }

    if (response)
    {
        [self.authorizationResponseHandler handleLoginResponse:response];
        [self.userInfoPersistentStore persistUserInfoContainer:self.userInfo];
    }

    if (completionBlock)
    {
        completionBlock(success);
    }

    self.signedIn = success;
    self.performingRequest = NO;
}

-(void) performFacebookAuthorizationWithCompletionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    [self.facebookAuthorizer performAuthorizationWithCompletionBlock:^(BOOL success, NSDictionary *response)
    {
        if (success)
        {
            [ZLACredentialsStorage setAuthorizationMethod:ZLAAuthorizationMethodFacebook];
        }

        [self handleAuthorizationResponse:response
                                  success:success
                          completionBlock:completionBlock];
    }];
}

-(void) performGooglePlusAuthorizationWithClientId:(NSString *) clientId
                                   completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock
{
    [self.googlePlusAuthorizer performAuthorizationWithClientId:clientId
                                                completionBlock:^(BOOL success, NSDictionary *response)
                                                {
                                                    if (success)
                                                    {
                                                        [ZLACredentialsStorage setAuthorizationMethod:ZLAAuthorizationMethodGooglePlus];
                                                    }

                                                    [self handleAuthorizationResponse:response
                                                                              success:success
                                                                      completionBlock:completionBlock];
                                                }];
}

-(void) signOut
{
    switch ([ZLACredentialsStorage authorizationMethod])
    {
        case ZLAAuthorizationMethodFacebook:
            [self.facebookAuthorizer signOut];
            break;

        case ZLAAuthorizationMethodGooglePlus:
            [self.googlePlusAuthorizer signOut];
            break;

        default:
            break;
    }

    [self.autoAuthorizationPerformer stopAutoAuthorization];
    [self.userInfoPersistentStore removePersistedUserInfo];
    [ZLACredentialsStorage wipeOutExistingCredentials];
    [ZLACredentialsStorage resetAuthorizationMethod];
    [self.userInfo reset];
    [self.userInfoPersistentStore persistUserInfoContainer:self.userInfo];
    self.signedIn = NO;

    [self generateUserIdentifier];
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
                                       [self.userInfoPersistentStore persistUserInfoContainer:self.userInfo];

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

    return @{ZLAFirstNameKey            : [ZLAUserInfoContainer firstNameOfFullName:fullName],
             ZLALastNameKey             : [ZLAUserInfoContainer lastNameOfFullName:fullName],
             ZLAUserEmailKey            : emptyIfNil(self.userInfo.email),
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