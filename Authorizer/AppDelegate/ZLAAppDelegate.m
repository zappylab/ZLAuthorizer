//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import "ZLAAppDelegate.h"

#import "FacebookSDK.h"
#import <Google/SignIn.h>

/////////////////////////////////////////////////////

@implementation ZLAAppDelegate

-(BOOL) application:(UIApplication *) application
      handleOpenURL:(NSURL *) url
{
    return [FBSession.activeSession handleOpenURL:url];
}

-(BOOL) application:(UIApplication *) application
            openURL:(NSURL *) url
  sourceApplication:(NSString *) sourceApplication
         annotation:(id) annotation
{
    BOOL result = NO;
    
    if ([url.scheme rangeOfString:@"fb"
                          options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        result = [FBAppCall handleOpenURL:url
                        sourceApplication:sourceApplication];
    }
    else
    {
        result = [[GIDSignIn sharedInstance] handleURL:url
                                     sourceApplication:sourceApplication
                                            annotation:annotation];
    }
    
    return result;
}

@end

/////////////////////////////////////////////////////