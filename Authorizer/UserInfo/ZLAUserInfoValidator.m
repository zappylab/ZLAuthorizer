//
// Created by Ilya Dyakonov on 01/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAUserInfoValidator.h"

/////////////////////////////////////////////////////

static NSUInteger const ZLAMinPasswordLength = 6;

/////////////////////////////////////////////////////

@interface ZLAUserInfoValidator ()

@end

/////////////////////////////////////////////////////

@implementation ZLAUserInfoValidator

+(BOOL) isFullNameAcceptable:(NSString *) fullName
{
    return fullName.length > 0;
}

+(BOOL) isPasswordAcceptable:(NSString *) password
{
    return password.length >= ZLAMinPasswordLength;
}

@end

/////////////////////////////////////////////////////