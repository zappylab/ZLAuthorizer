//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZLAConcreteAuthorizer.h"

/////////////////////////////////////////////////////

@interface ZLANativeAuthorizer : NSObject <ZLAConcreteAuthorizer>

-(void) performAuthorizationWithEmail:(NSString *) email
                             password:(NSString *) password
                      completionBlock:(ZLARequestCompletionBlock) completionBlock;

-(BOOL) ableToRegisterUserWithEmail:(NSString *) email
                           password:(NSString *) password;

-(void) registerUserWithEmail:(NSString *) email
                     password:(NSString *) password
              completionBlock:(ZLARequestCompletionBlock) completionBlock;

-(void) resetPassword;

@end

/////////////////////////////////////////////////////