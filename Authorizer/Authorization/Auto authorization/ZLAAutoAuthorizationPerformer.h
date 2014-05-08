//
// Created by Ilya Dyakonov on 08/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@protocol ZLAConcreteAuthorizer;

@class ZLNetworkReachabilityObserver;

/////////////////////////////////////////////////////

@interface ZLAAutoAuthorizationPerformer : NSObject

-(instancetype) initWithReachabilityObserver:(ZLNetworkReachabilityObserver *) observer;

-(void) performAutoAuthorizationWithAuthorizer:(id<ZLAConcreteAuthorizer>) authorizer
                               completionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock;
-(void) stopAutoAuthorization;

@end

/////////////////////////////////////////////////////