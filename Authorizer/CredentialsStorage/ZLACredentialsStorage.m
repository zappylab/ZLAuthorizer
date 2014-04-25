//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLACredentialsStorage.h"

#import "Lockbox.h"

/////////////////////////////////////////////////////

static NSString *const kUserNameKey = @"username";
static NSString *const kPasswordKey = @"password";

static NSString *const kTwitterUserNameKey = @"TwitterUserName";
static NSString *const kTwitterAccessTokenKey = @"TwitterAccessToken";

static NSString *const kZLAAuthorizationMethodKey = @"authorizationMethod";

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
    self.userEmail = nil;
    self.password = nil;
}

#pragma mark - Native

+(NSString *) userEmail
{
    return [Lockbox stringForKey:kUserNameKey];
}

+(void) setUserEmail:(NSString *) userName
{
    [Lockbox setString:userName
                forKey:kUserNameKey];
}

+(NSString *) password
{
    return [Lockbox stringForKey:kPasswordKey];
}

+(void) setPassword:(NSString *) password
{
    [Lockbox setString:password
                forKey:kPasswordKey];
}

#pragma mark - Twitter

+(NSString *) twitterUserName
{
    return [Lockbox stringForKey:kTwitterUserNameKey];
}

+(void) setTwitterUserName:(NSString *) twitterUserName
{
    [Lockbox setString:twitterUserName
                forKey:kTwitterUserNameKey];
}

+(NSString *) twitterAccessTokenSecret
{
    return [Lockbox stringForKey:kTwitterAccessTokenKey];
}

+(void) setTwitterAccessToken:(NSString *) twitterAccessTokenSecret
{
    [Lockbox setString:twitterAccessTokenSecret
                forKey:kTwitterAccessTokenKey];
}

#pragma mark - General

+(ZLAAuthorizationMethod) authorizationMethod
{
    return (ZLAAuthorizationMethod) [[Lockbox stringForKey:kZLAAuthorizationMethodKey] integerValue];
}

+(void) setAuthorizationMethod:(ZLAAuthorizationMethod) method
{
    [Lockbox setString:[NSString stringWithFormat:@"%d", method]
                forKey:kZLAAuthorizationMethodKey];
}

@end

/////////////////////////////////////////////////////