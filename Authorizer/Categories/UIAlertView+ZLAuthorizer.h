//
// Created by Ilya Dyakonov on 25/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface UIAlertView (ZLAuthorizer)

+(void) ZLA_showInvalidEmailAlertForSignin:(NSString *) email;
+(void) ZLA_showInvalidEmailAlertForRegistration:(NSString *) email;

+(void) ZLA_showTooShortPasswordAlertForRegistration;
+(void) ZLA_showTooShortPasswordAlertWithTitle:(NSString *) title;

+(void) ZLA_showTooShowFullNameAlertForRegistration;

@end

/////////////////////////////////////////////////////
