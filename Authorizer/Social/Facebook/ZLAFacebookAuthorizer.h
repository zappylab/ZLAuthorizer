//
// Created by Ilya Dyakonov on 05/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@class ZLNetworkRequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLAFacebookAuthorizer : NSObject

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer;

-(void) performAuthorizationWithCompletionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;
-(void) loginWithExistingCredentialsWithCompletionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock;

-(void) signOut;

@end

/////////////////////////////////////////////////////