//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ZLNetworkRequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLAGooglePlusAuthorizer : NSObject

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer;

-(void) performAuthorizationWithClientId:(NSString *) clientId
                         completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;

-(void) signOut;

@end

/////////////////////////////////////////////////////