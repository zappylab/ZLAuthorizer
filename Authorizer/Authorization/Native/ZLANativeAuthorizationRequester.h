//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ZLNetworkRequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLANativeAuthorizationRequester : NSObject

@property (strong) ZLNetworkRequestsPerformer *requestsPerformer;

-(void) performNativeLoginWithUserName:(NSString *) userName
                              password:(NSString *) password
                       completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;

-(void) resetPassword;

@end

/////////////////////////////////////////////////////