//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ZLARequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLANativeAuthorizer : NSObject

-(instancetype) initWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer;

-(void) performNativeAuthorizationWithCompletionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;

@end

/////////////////////////////////////////////////////