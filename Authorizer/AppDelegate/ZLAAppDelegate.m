//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import "ZLAAppDelegate.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GIDSignIn.h>
#import <TwitterKit/TWTRTwitter.h>

@implementation ZLAAppDelegate

-(BOOL) application:(UIApplication *) application
            openURL:(NSURL *) url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *) options
{
    BOOL result = NO;
    if ([url.scheme rangeOfString:@"fb"
                          options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        result = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                openURL:url
                                                      sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                             annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    else if ([url.scheme rangeOfString:@"twitter"
                               options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        result = [[TWTRTwitter sharedInstance] application:application
                                                   openURL:url
                                                   options:options];
    }
    else
    {
        result = [[GIDSignIn sharedInstance] handleURL:url
                                     sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                            annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    return result;
}

@end
