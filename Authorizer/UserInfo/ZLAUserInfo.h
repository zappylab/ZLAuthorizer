//
// Created by Ilya Dyakonov on 17/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface ZLAUserInfo : NSObject

@property (strong) NSString *usedIdentifier;
@property (strong) NSString *fullUserName;
@property (strong) NSString *userAffiliation;
@property (strong) NSURL *profilePictureURL;

@end

/////////////////////////////////////////////////////