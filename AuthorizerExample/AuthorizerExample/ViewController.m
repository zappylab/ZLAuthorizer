//
//  ViewController.m
//  AuthorizerExample
//
//  Created by Ilya Dyakonov on 17/04/14.
//  Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import "ZLAAuthorizer.h"

@interface ViewController () < UIAlertViewDelegate >

@property (strong) ZLAAuthorizer *authorizer;

@end

@implementation ViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.authorizer = [[ZLAAuthorizer alloc] init];
    [self.authorizer setBaseURL:[NSURL URLWithString:@"http://dev.passageo.com/api/v1/"]];
}

-(IBAction) nativeLoginTapped:(id) sender
{
    UIAlertView *credentialsAlertView = [[UIAlertView alloc] initWithTitle:@"Password required"
                                                                   message:nil
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Cancel"
                                                         otherButtonTitles:@"Go",
                                         nil];
    credentialsAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    credentialsAlertView.delegate = self;
    [credentialsAlertView show];
}

-(IBAction) twitterAuthTapped:(id) sender
{
    [self.authorizer performTwitterAuthorizationWithAPIKey:@"1h01qcIbEElhCwzVpIG2P5w8x"
                                                 APISecret:@"lh2To0hWfD4vgJK60CkXLb0Jow8IS9F6IWLGK7WdtqcaSdE55L"
                                           completionBlock:^(BOOL success)
                                           {

                                           }];
}

- (IBAction)facebookAuthTapped
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    }
    else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        FBSession *session = [[FBSession alloc] init];
        [FBSession setActiveSession:session];
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session
                                        state:state
                                        error:error];
         }];
    }
}

#pragma mark - UIAlertViewDelegate methods

-(void)    alertView:(UIAlertView *) alertView
clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSString *userName = [alertView textFieldAtIndex:0].text;
        NSString *password = [alertView textFieldAtIndex:1].text;

        [self.authorizer performNativeAuthorizationWithUserEmail:userName
                                                        password:password
                                                 completionBlock:^(BOOL success)
                                                 {

                                                 }];
    }
}

@end
