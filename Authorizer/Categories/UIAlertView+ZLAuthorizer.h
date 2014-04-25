//
// Created by Ilya Dyakonov on 25/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface UIAlertView (ZLAuthorizer)

+(void) showInvalidEmailAlert:(NSString *) email;
+(void) showTooShortPasswordAlert;

@end

/////////////////////////////////////////////////////
