//
// Created by Ilya Dyakonov on 01/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface ZLAUserInfoValidator : NSObject

+(BOOL) isFullNameAcceptable:(NSString *) fullName;
+(BOOL) isPasswordAcceptable:(NSString *) password;

@end

/////////////////////////////////////////////////////