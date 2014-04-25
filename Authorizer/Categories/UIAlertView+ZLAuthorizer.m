//
// Created by Ilya Dyakonov on 25/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "UIAlertView+ZLAuthorizer.h"

/////////////////////////////////////////////////////

@implementation UIAlertView (ZLAuthorizer)

+(void) showInvalidEmailAlert:(NSString *) email
{
    [[[UIAlertView alloc] initWithTitle:@"Login"
                                message:[NSString stringWithFormat:@"%@ is not a valid email",
                                                                   email]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

+(void) showTooShortPasswordAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Login"
                                message:@"Too short password"
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

@end

/////////////////////////////////////////////////////