//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@class ZLNetworkRequestsPerformer;
@class ZLAUserInfoContainer;

/////////////////////////////////////////////////////

@interface ZLATwitterAuthorizer : NSObject

@property (strong) NSString *consumerKey;
@property (strong) NSString *consumerSecret;

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer;

-(void) performAuthorizationWithCompletionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock;
-(void) loginWithExistingCredentialsWithCompletionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock;

-(void) reset;

@end

/////////////////////////////////////////////////////