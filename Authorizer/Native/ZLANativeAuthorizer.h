//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@class ZLARequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLANativeAuthorizer : NSObject

-(instancetype) initWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer;

-(void) performAuthorizationWithUserEmail:(NSString *) userEmail
                                 password:(NSString *) password
                          completionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock;

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock;

-(void) resetPassword;

@end

/////////////////////////////////////////////////////