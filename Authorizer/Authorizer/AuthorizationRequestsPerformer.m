//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "AuthorizationRequestsPerformer.h"
#import "NetworkRequestsDispatcher+Protected.h"
#import "AuthorizationDataParser.h"
#import "AppDelegate.h"

#import "NSString+EmailValidation.h"
#import "CredentialsStorage.h"

/////////////////////////////////////////////////////

static NSString *const kRegisterRequestPath = @"mregister";
static NSString *const kLoginRequestPath = @"mlogin";

static NSString *const kUserEmailKey = @"zll";
static NSString *const kUserPasswordKey = @"zlp";
static NSString *const kUserFullNameKey = @"ufn";

/////////////////////////////////////////////////////

static NSString *const kAppKey = @"app";

@interface AuthorizationRequestsPerformer ()

@end

/////////////////////////////////////////////////////

@implementation AuthorizationRequestsPerformer

#pragma mark - Instantiation

+(instancetype) sharedInstance
{
    static AuthorizationRequestsPerformer *_sharedPerformer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _sharedPerformer = [[AuthorizationRequestsPerformer alloc] init];
    });

    return _sharedPerformer;
}

#pragma mark - Initialization

-(instancetype) initWithBaseURL:(NSURL *) baseURL
{
    self = [super initWithBaseURL:baseURL];
    if (self) {

    }

    return self;
}

#pragma mark - Login

-(void) loginWithCompletionBlock:(void (^)(BOOL success)) completionBlock
{
    if ([CredentialsStorage sharedInstance].userName &&
        [[CredentialsStorage sharedInstance].userName isValidEmail] &&
        [CredentialsStorage sharedInstance].password)
    {
        [self POST:kLoginRequestPath
        parameters:@{kUserEmailKey    : [CredentialsStorage sharedInstance].userName,
                     kUserPasswordKey : [CredentialsStorage sharedInstance].password}
           success:^(AFHTTPRequestOperation *operation, id responseObject)
           {
               if ([self isResponseOK:responseObject])
               {
                   [AuthorizationDataParser handleLoginResponse:responseObject];

                   if (completionBlock)
                   {
                       completionBlock(YES);

                       AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                       [appDelegate syncJournalToServerWithGiveAll:YES];
                   }
               }
               else
               {
                   [self showLoginFailureAlert];

                   if (completionBlock)
                   {
                       completionBlock(NO);
                   }
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
           {
               if (completionBlock)
               {
                   completionBlock(NO);
               }
           }];
    }
    else {
        [self showInvalidEmailAlertWithEmail:[CredentialsStorage sharedInstance].userName];
    }
}

-(void) showInvalidEmailAlertWithEmail:(NSString *) email
{
    [[[UIAlertView alloc] initWithTitle:@"Login"
                                message:[NSString stringWithFormat:@"%@ is not a valid email",
                                                                   email]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

-(void) showLoginFailureAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Login Error"
                                message:@"Invalid username or password"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    if ([email isValidEmail]) {
        [self POST:kRegisterRequestPath
        parameters:@{kUserFullNameKey : fullName,
                     kUserEmailKey    : email,
                     kUserPasswordKey : password,
                     kAppKey          : @"2",
                     kUserId          : [SettingsManager sharedInstance].userID}
           success:^(AFHTTPRequestOperation *operation, id responseObject)
           {
               if ([self isResponseOK:responseObject])
               {
                   if (completionBlock)
                   {
                       completionBlock(YES, nil);
                   }
               }
               else
               {
                   if (completionBlock)
                   {
                       completionBlock(NO, (NSDictionary *) responseObject);
                   }
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error)
           {
               if (completionBlock)
               {
                   completionBlock(NO, nil);
               }
           }];
    }
    else {
        [self showInvalidEmailAlertWithEmail:email];
    }
}

@end

/////////////////////////////////////////////////////