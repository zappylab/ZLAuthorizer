//
// Created by Ilya Dyakonov on 25/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "UIAlertView+ZLAuthorizer.h"

/////////////////////////////////////////////////////

@implementation UIAlertView (ZLAuthorizer)

+(void) ZLA_showInvalidEmailAlertForSignin:(NSString *) email
{
    [self ZLA_showInvalidEmailAlert:email
                          withTitle:@"Sign in"];
}

+(void) ZLA_showInvalidEmailAlertForRegistration:(NSString *) email
{
    [self ZLA_showInvalidEmailAlert:email
                          withTitle:@"Registration"];
}

+(void) ZLA_showInvalidEmailAlert:(NSString *) email
                        withTitle:(NSString *) title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:[NSString stringWithFormat:@"%@ is not a valid email",
                                                                   email]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

+(void) ZLA_showTooShortPasswordAlertForSignin
{
    [self ZLA_showTooShortPasswordAlertWithTitle:@"Sign in"];
}

+(void) ZLA_showTooShortPasswordAlertForRegistration
{
    [self ZLA_showTooShortPasswordAlertWithTitle:@"Registration"];
}

+(void) ZLA_showTooShortPasswordAlertWithTitle:(NSString *) title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:@"Too short password"
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

+(void) ZLA_showTooShowFullNameAlertForRegistration
{
    [[[UIAlertView alloc] initWithTitle:@"Registration"
                               message:@"Please, provide your full name to register"
                              delegate:nil
                     cancelButtonTitle:@"Close"
                     otherButtonTitles:nil] show];
}

@end

/////////////////////////////////////////////////////