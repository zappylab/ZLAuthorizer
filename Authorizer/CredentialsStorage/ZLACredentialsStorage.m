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
    self.userName = nil;
    self.password = nil;
}

+(NSString *) userName
{
    return [Lockbox stringForKey:kUserNameKey];
}

+(void) setUserName:(NSString *) userName
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

@end

/////////////////////////////////////////////////////