//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ZLARequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLAGooglePlusAuthorizer : NSObject

-(instancetype) initWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer;

-(void) performAuthorizationWithClientId:(NSString *) clientId
                         completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;

@end

/////////////////////////////////////////////////////