//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLAConcreteAuthorizer.h"
#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@interface ZLAGooglePlusAuthorizer : NSObject <ZLAConcreteAuthorizer>

-(void) performAuthorizationWithClientId:(NSString *) clientId
                         completionBlock:(ZLARequestCompletionBlock) completionBlock;

@end

/////////////////////////////////////////////////////