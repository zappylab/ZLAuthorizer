//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

static const int kMinCredentialStringLength = 2;

@interface Authorizer : NSObject

+(void) performStartupAuthorization;
+(void) performAuthorizationWithCompletionBlock:(void (^)(BOOL success)) completionBlock;

@end

/////////////////////////////////////////////////////