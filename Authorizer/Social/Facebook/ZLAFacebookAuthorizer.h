//
// Created by Ilya Dyakonov on 05/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ZLARequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLAFacebookAuthorizer : NSObject

-(instancetype) initWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer;

-(void) performAuthorizationWithCompletionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;
-(void) signOut;

@end

/////////////////////////////////////////////////////