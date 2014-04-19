//
//  ViewController.m
//  AuthorizerExample
//
//  Created by Ilya Dyakonov on 17/04/14.
//  Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import "ViewController.h"

#import "ZLAAuthorizer.h"

@interface ViewController ()

@property (strong) ZLAAuthorizer *authorizer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.authorizer = [[ZLAAuthorizer alloc] init];
    [self.authorizer setBaseURL:[NSURL URLWithString:@"http://dev.treks.io/api/v1/"]];
}

- (IBAction)twitterAuthTapped:(id)sender
{
    [self.authorizer performTwitterAuthorizationWithAPIKey:@"1h01qcIbEElhCwzVpIG2P5w8x"
                                                 APISecret:@"lh2To0hWfD4vgJK60CkXLb0Jow8IS9F6IWLGK7WdtqcaSdE55L"
                                           completionBlock:^(BOOL success)
     {
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
