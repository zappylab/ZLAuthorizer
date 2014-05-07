//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLACredentialsStorage.h"

#import "Lockbox.h"

/////////////////////////////////////////////////////

static NSString *const ZLAKeychainUserIdentifierKey = @"identifier";
static NSString *const ZLAKeychainUserNameKey = @"username";
static NSString *const ZLAKeychainPasswordKey = @"password";

static NSString *const ZLAKeychainSocialUserIdentifierKey = @"SocialUserIdentifier";
static NSString *const ZLAKeychainSocialAccessTokenKey = @"SocialAccessToken";

static NSString *const ZLAKeychainAuthorizationMethodKey = @"authorizationMethod";

/////////////////////////////////////////////////////

@interface ZLACredentialsStorage ()

@end

/////////////////////////////////////////////////////

@implementation ZLACredentialsStorage

#pragma mark - Initialization

-(instancetype) init
{
    self = [super init];
    if (self) {

    }

    return self;
}

#pragma mark - Data access

+(void) wipeOutExistingCredentials
{
    [self setUserEmail:nil];
    [self setPassword:nil];
    [self setSocialUserIdentifier:nil];
    [self setSocialAccessToken:nil];
    [self resetAuthorizationMethod];
}

#pragma mark - Native

+(NSString *) userIdentifier
{
    return [Lockbox stringForKey:ZLAKeychainUserIdentifierKey];
}

+(void) setUserIdentifier:(NSString *) userIdentifier
{
    [Lockbox setString:userIdentifier
                forKey:ZLAKeychainUserIdentifierKey];
}

+(NSString *) userEmail
{
    return [Lockbox stringForKey:ZLAKeychainUserNameKey];
}

+(void) setUserEmail:(NSString *) userName
{
    [Lockbox setString:userName
                forKey:ZLAKeychainUserNameKey];
}

+(NSString *) password
{
    return [Lockbox stringForKey:ZLAKeychainPasswordKey];
}

+(void) setPassword:(NSString *) password
{
    [Lockbox setString:password
                forKey:ZLAKeychainPasswordKey];
}

#pragma mark - Social OAuth

+(NSString *) socialUserIdentifier
{
    return [Lockbox stringForKey:ZLAKeychainSocialUserIdentifierKey];
}

+(void) setSocialUserIdentifier:(NSString *) socialUserIdentifier
{
    [Lockbox setString:socialUserIdentifier
                forKey:ZLAKeychainSocialUserIdentifierKey];
}

+(NSString *) socialAccessToken
{
    return [Lockbox stringForKey:ZLAKeychainSocialAccessTokenKey];
}

+(void) setSocialAccessToken:(NSString *) socialAccessToken
{
    [Lockbox setString:socialAccessToken
                forKey:ZLAKeychainSocialAccessTokenKey];
}

#pragma mark - General

+(ZLAAuthorizationMethod) authorizationMethod
{
    return (ZLAAuthorizationMethod) [[Lockbox stringForKey:ZLAKeychainAuthorizationMethodKey] integerValue];
}

+(void) setAuthorizationMethod:(ZLAAuthorizationMethod) method
{
    [Lockbox setString:[NSString stringWithFormat:@"%d",
                                                  method]
                forKey:ZLAKeychainAuthorizationMethodKey];
}

+(void) resetAuthorizationMethod
{
    [Lockbox setString:nil
                forKey:ZLAKeychainAuthorizationMethodKey];
}

@end

/////////////////////////////////////////////////////