//
//  AppDelegate.m
//  AuthorizerExample
//
//  Created by Ilya Dyakonov on 17/04/14.
//  Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import "AppDelegate.h"
#import <GooglePlus/GooglePlus.h>

@interface AppDelegate ()

@property (strong) NSString* accessToken;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

-(void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            break;
        }
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        }
        default:
            break;
    }
}

-(BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL result = false;
    
    if ([url.scheme rangeOfString:@"fb" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [FBSession.activeSession setStateChangeHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             [appDelegate sessionStateChanged:session
                                        state:state
                                        error:error];
         }];
        result = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }
    else {
        result = [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    
    return result;
}

@end
