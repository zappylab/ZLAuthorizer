//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "NetworkRequestsDispatcher.h"

/////////////////////////////////////////////////////

@interface AuthorizationRequestsPerformer : NetworkRequestsDispatcher

+(instancetype) sharedInstance;

-(void) loginWithCompletionBlock:(void (^)(BOOL success)) completionBlock;

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;
@end

/////////////////////////////////////////////////////