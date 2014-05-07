//
//  ViewController.m
//  AuthorizerExample
//
//  Created by Ilya Dyakonov on 17/04/14.
//  Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import "ViewController.h"

#import "ZLAAuthorizer.h"

@interface ViewController () <UIAlertViewDelegate>

@property (strong) ZLAAuthorizer *authorizer;

@end

@implementation ViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.authorizer = [[ZLAAuthorizer alloc] initWithBaseURL:[NSURL URLWithString:@"http://dev.passageo.com/api/v1/"]
                                               appIdentifier:@"2"];
}

-(IBAction) twitterAuthTapped:(id) sender
{
    [self.authorizer performTwitterAuthorizationWithAPIKey:@"1h01qcIbEElhCwzVpIG2P5w8x"
                                                 APISecret:@"lh2To0hWfD4vgJK60CkXLb0Jow8IS9F6IWLGK7WdtqcaSdE55L"
                                           completionBlock:^(BOOL success)
                                           {

                                           }];
}

-(IBAction) registrationTapped:(id) sender
{
    [self.authorizer registerUserWithFullName:@"Ilya Dyakonov"
                                        email:@"ilushkadyakonov@zappylab.com"
                                     password:@"123456"
                              completionBlock:^(BOOL success)
                              {

                              }];
}

-(IBAction) registrationBadEmailTapped:(id) sender
{
    [self.authorizer registerUserWithFullName:@"Ilya Dyakonov"
                                        email:@"ilushkadyakonov@zappylab"
                                     password:@"123456"
                              completionBlock:^(BOOL success)
                              {

                              }];
}

-(IBAction) registrationBadFullNameTapped:(id) sender
{
    [self.authorizer registerUserWithFullName:@""
                                        email:@"ilushkadyakonov@zappylab.com"
                                     password:@"123456"
                              completionBlock:^(BOOL success)
                              {

                              }];
}

-(IBAction) registrationBadPasswordTapped:(id) sender
{
    [self.authorizer registerUserWithFullName:@"Ilya Dyakonov"
                                        email:@"ilushkadyakonov@zappylab.com"
                                     password:@"12345"
                              completionBlock:^(BOOL success)
                              {

                              }];
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

-(IBAction) facebookAuthTapped
{
    [self.authorizer performFacebookAuthorizationWithCompletionBlock:^(BOOL success)
    {

    }];;
}

-(IBAction) facebookSignOutTapped
{
    [self.authorizer signOut];
}

-(IBAction) googlePlucAuthTapped:(id) sender
{
    [self.authorizer performGooglePlusAuthorizationWithClientId:@"17100019704-o162em5ouc56mcel4omjbr9v7b9p10lt.apps.googleusercontent.com"
                                                completionBlock:^(BOOL success)
                                                {

                                                }];
}

-(IBAction) googlePlusSignOutTapped
{
    [self.authorizer signOut];
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
