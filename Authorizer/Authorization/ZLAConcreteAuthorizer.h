//
// Created by Ilya Dyakonov on 07/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@class ZLNetworkRequestsPerformer;

/////////////////////////////////////////////////////

@protocol ZLAConcreteAuthorizer <NSObject>

-(id) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer;

-(void) loginWithExistingCredentialsWithCompletionBlock:(ZLARequestCompletionBlock) completionBlock;
-(void) stopLoggingInWithExistingCredentials;
-(void) signOut;

@end

/////////////////////////////////////////////////////
