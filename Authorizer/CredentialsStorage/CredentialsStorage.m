//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "CredentialsStorage.h"

#import "Lockbox.h"

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

    }

    return self;
}

-(void) wipeOutExistingCredentials
{
    self.userName = nil;
    self.password = nil;
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