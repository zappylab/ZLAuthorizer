//
// Created by Ilya Dyakonov on 01/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@class ZLARequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLAAccountInfoUpdater : NSObject

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer;

-(void) updateAccountWithInfo:(NSDictionary *) accountInfo
              completionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock;

@end

/////////////////////////////////////////////////////