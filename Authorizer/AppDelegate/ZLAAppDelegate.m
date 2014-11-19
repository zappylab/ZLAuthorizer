//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAAppDelegate.h"
#import "ZLAAuthorizer.h"

/////////////////////////////////////////////////////

@interface ZLAAppDelegate ()

@end

/////////////////////////////////////////////////////

@implementation ZLAAppDelegate

-(BOOL) application:(UIApplication *) application
      handleOpenURL:(NSURL *) url
{
    return [self.authorizer handleOpenURL:url];
}

-(BOOL) application:(UIApplication *) application
            openURL:(NSURL *) url
  sourceApplication:(NSString *) sourceApplication
         annotation:(id) annotation
{
    return [self.authorizer handleOpenURL:url
                        sourceApplication:sourceApplication
                               annotation:annotation];
}

@end

/////////////////////////////////////////////////////