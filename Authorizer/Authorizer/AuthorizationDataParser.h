//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface AuthorizationDataParser : NSObject

+(void) handleLoginResponse:(NSDictionary *) response;

@end

/////////////////////////////////////////////////////