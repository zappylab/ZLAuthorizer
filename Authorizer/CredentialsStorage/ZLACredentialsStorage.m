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
static NSString *const ZLAKeychainUserDataSynchTimestampKey = @"userDataSynchTimestamp";

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
    
    if (self)
    {
        [[self class] migrateUserDataIfNeeded];
    }
    
    return self;
}

+(void) migrateUserDataIfNeeded
{
    if ([[self class] needToMigrateUserData])
    {
        [[self class] migrateDataForKey:ZLAKeychainUserIdentifierKey];
        [[self class] migrateDataForKey:ZLAKeychainUserNameKey];
        [[self class] migrateDataForKey:ZLAKeychainPasswordKey];
        [[self class] migrateDataForKey:ZLAKeychainSocialUserIdentifierKey];
        [[self class] migrateDataForKey:ZLAKeychainSocialAccessTokenKey];
        [[self class] migrateDataForKey:ZLAKeychainAuthorizationMethodKey];
        [[self class] migrateUserDataSynchTimestamp];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

+(BOOL) needToMigrateUserData
{
    if (![Lockbox respondsToSelector:@selector(stringForKey:)])
        return NO;
    
    NSString *userIdentifierBeforeMigration = [Lockbox stringForKey:ZLAKeychainUserIdentifierKey];
    NSString *userIdentifierAfterMigration = [Lockbox unarchiveObjectForKey:ZLAKeychainUserIdentifierKey];
    return userIdentifierBeforeMigration.length > 0
           && userIdentifierAfterMigration == nil;
}

+(void) migrateDataForKey:(NSString *) key
{
    id valueBeforeMigration = [Lockbox stringForKey:key];
    [Lockbox archiveObject:valueBeforeMigration
                    forKey:key];
}

+(void) migrateUserDataSynchTimestamp
{
    NSDate *dataSynchTimestampBeforeMigration = [Lockbox dateForKey:ZLAKeychainUserDataSynchTimestampKey];
    [Lockbox archiveObject:dataSynchTimestampBeforeMigration
                    forKey:ZLAKeychainUserDataSynchTimestampKey];
}
#pragma clang diagnostic pop

#pragma mark - Data access

+(void) wipeOutExistingCredentials
{
    [self setUserIdentifier:nil];
    [self setUserEmail:nil];
    [self setPassword:nil];
    [self setSocialUserIdentifier:nil];
    [self setSocialAccessToken:nil];
    [self resetAuthorizationMethod];
}

#pragma mark - Native

+(NSString *) userIdentifier
{
    return [Lockbox unarchiveObjectForKey:ZLAKeychainUserIdentifierKey];
}

+(void) setUserIdentifier:(NSString *) userIdentifier
{
    [Lockbox archiveObject:userIdentifier
                    forKey:ZLAKeychainUserIdentifierKey];
}

+(NSString *) userEmail
{
    return [Lockbox unarchiveObjectForKey:ZLAKeychainUserNameKey];
}

+(void) setUserEmail:(NSString *) userName
{
    [Lockbox archiveObject:userName
                    forKey:ZLAKeychainUserNameKey];
}

+(NSString *) password
{
    return [Lockbox unarchiveObjectForKey:ZLAKeychainPasswordKey];
}

+(void) setPassword:(NSString *) password
{
    [Lockbox archiveObject:password
                    forKey:ZLAKeychainPasswordKey];
}

#pragma mark - Social OAuth

+(NSString *) socialUserIdentifier
{
    return [Lockbox unarchiveObjectForKey:ZLAKeychainSocialUserIdentifierKey];
}

+(void) setSocialUserIdentifier:(NSString *) socialUserIdentifier
{
    [Lockbox archiveObject:socialUserIdentifier
                    forKey:ZLAKeychainSocialUserIdentifierKey];
}

+(NSString *) socialAccessToken
{
    return [Lockbox unarchiveObjectForKey:ZLAKeychainSocialAccessTokenKey];
}

+(void) setSocialAccessToken:(NSString *) socialAccessToken
{
    [Lockbox archiveObject:socialAccessToken
                    forKey:ZLAKeychainSocialAccessTokenKey];
}

#pragma mark - General

+(ZLAAuthorizationMethod) authorizationMethod
{
    return (ZLAAuthorizationMethod)[[Lockbox unarchiveObjectForKey:ZLAKeychainAuthorizationMethodKey] integerValue];
}

+(void) setAuthorizationMethod:(ZLAAuthorizationMethod) method
{
    [Lockbox archiveObject:[NSString stringWithFormat:@"%lu",
                            (long unsigned) method]
                    forKey:ZLAKeychainAuthorizationMethodKey];
}

+(void) resetAuthorizationMethod
{
    [Lockbox archiveObject:nil
                    forKey:ZLAKeychainAuthorizationMethodKey];
}

+(NSDate *) userDataSynchTimestamp
{
    return [Lockbox unarchiveObjectForKey:ZLAKeychainUserDataSynchTimestampKey];
}

+(void) setUserDataSynchTimestamp:(NSDate *) userDataSynchTimestamp
{
    [Lockbox archiveObject:userDataSynchTimestamp
                    forKey:ZLAKeychainUserDataSynchTimestampKey];
}

@end

/////////////////////////////////////////////////////