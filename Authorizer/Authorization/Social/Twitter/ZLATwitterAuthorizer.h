//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLAConcreteAuthorizer.h"

/////////////////////////////////////////////////////

@interface ZLATwitterAuthorizer : NSObject <ZLAConcreteAuthorizer>

-(void) performAuthorizationWithConsumerKey:(NSString *) consumerKey
                             consumerSecret:(NSString *) consumerSecret
                            completionBlock:(ZLARequestCompletionBlock) completionBlock;

@end

/////////////////////////////////////////////////////