//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@class ZLNetworkRequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLANativeAuthorizationRequester : NSObject

@property (strong) ZLNetworkRequestsPerformer *requestsPerformer;

-(NSOperation *) performNativeLoginWithUserName:(NSString *) userName
                                       password:(NSString *) password
                                completionBlock:(ZLARequestCompletionBlock) completionBlock;

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(ZLARequestCompletionBlock) completionBlock;

-(void) resetPassword;

@end

/////////////////////////////////////////////////////