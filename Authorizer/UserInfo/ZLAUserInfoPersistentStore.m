//
// Created by Ilya Dyakonov on 07/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAUserInfoPersistentStore.h"
#import "ZLAUserInfoContainer.h"

/////////////////////////////////////////////////////

static NSString *const ZLAPersistedUserInfoKey = @"ZLAAuthorizerUserInfo";

/////////////////////////////////////////////////////

@interface ZLAUserInfoPersistentStore ()

@end

/////////////////////////////////////////////////////

@implementation ZLAUserInfoPersistentStore

#pragma mark - Initialization

-(instancetype) init
{
    self = [super init];
    if (self)
    {

    }

    return self;
}

#pragma mark - Persistence

-(void) persistUserInfoContainer:(ZLAUserInfoContainer *) userInfoContainer
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:userInfoContainer]
                                              forKey:ZLAPersistedUserInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(ZLAUserInfoContainer *) restorePersistedUserInfoContainer
{
    ZLAUserInfoContainer *userInfoContainer = nil;
    NSData *savedUserInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:ZLAPersistedUserInfoKey];
    if (savedUserInfoData) {
        userInfoContainer = [NSKeyedUnarchiver unarchiveObjectWithData:savedUserInfoData];
    }

    return userInfoContainer;
}

@end

/////////////////////////////////////////////////////