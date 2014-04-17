//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "CredentialsStorage.h"

#import "Lockbox.h"
#import "SettingsManager.h"
#import "SRSettingsModel+Deprecated.h"

/////////////////////////////////////////////////////

static NSString *const kUserNameKey = @"username";
static NSString *const kPasswordKey = @"password";

/////////////////////////////////////////////////////

@interface CredentialsStorage ()

@end

/////////////////////////////////////////////////////

@implementation CredentialsStorage

#pragma mark - Instantiation

+(instancetype) sharedInstance
{
    static CredentialsStorage *_sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedStorage = [[CredentialsStorage alloc] init];
    });

    return _sharedStorage;
}

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
    if ([SettingsManager sharedInstance].runningForFirstTime) {
        [self wipeOutExistingCredentials];
    }
    else {
        [self tryMigrateFromExistingSettings];
    }
}

-(void) wipeOutExistingCredentials
{
    self.userName = nil;
    self.password = nil;
}

-(void) tryMigrateFromExistingSettings
{
    if ([SRSettingsModel sharedInstance].username.length > 0) {
        self.userName = [SRSettingsModel sharedInstance].username;
    }

    if ([SRSettingsModel sharedInstance].password.length > 0) {
        self.password = [SRSettingsModel sharedInstance].password;
    }
}

#pragma mark - Accessors

-(NSString *) userName
{
    return [Lockbox stringForKey:kUserNameKey];
}

-(void) setUserName:(NSString *) userName
{
    [Lockbox setString:userName
                forKey:kUserNameKey];
}

-(NSString *) password
{
    return [Lockbox stringForKey:kPasswordKey];
}

-(void) setPassword:(NSString *) password
{
    [Lockbox setString:password
                forKey:kPasswordKey];
}

@end

/////////////////////////////////////////////////////