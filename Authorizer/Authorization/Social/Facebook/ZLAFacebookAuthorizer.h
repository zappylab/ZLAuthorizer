//
// Created by Ilya Dyakonov on 05/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZLAConcreteAuthorizer.h"

/////////////////////////////////////////////////////

@interface ZLAFacebookAuthorizer : NSObject <ZLAConcreteAuthorizer>

-(void) performAuthorizationFrom:(UIViewController *) viewController
             withCompletionBlock:(ZLARequestCompletionBlock) completionBlock;
@end

/////////////////////////////////////////////////////
