//
// Created by Ilya Dyakonov on 07/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ZLAUserInfoContainer;

/////////////////////////////////////////////////////

@interface ZLAUserInfoPersistentStore : NSObject

-(void) persistUserInfoContainer:(ZLAUserInfoContainer *) userInfoContainer;
-(ZLAUserInfoContainer *) restorePersistedUserInfoContainer;

@end

/////////////////////////////////////////////////////