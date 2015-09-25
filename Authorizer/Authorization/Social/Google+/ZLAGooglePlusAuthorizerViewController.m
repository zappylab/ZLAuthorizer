//
//  Created by Yulia Kurnosova on 25/09/15.
//  Copyright © 2015 ZappyLab. All rights reserved.
//

#import "ZLAGooglePlusAuthorizerViewController.h"

#import <GoogleSignIn/GoogleSignIn.h>

/////////////////////////////////////////////////////

@interface ZLAGooglePlusAuthorizerViewController ()
         <
         GIDSignInUIDelegate
         >
@end

/////////////////////////////////////////////////////

@implementation ZLAGooglePlusAuthorizerViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
}

@end

/////////////////////////////////////////////////////