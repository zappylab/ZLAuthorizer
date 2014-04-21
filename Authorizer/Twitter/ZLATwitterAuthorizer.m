//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "ZLATwitterAuthorizer.h"
#import "ZLATwitterRequestsPerformer.h"

/////////////////////////////////////////////////////

static NSString *const kZLATwitterAccessKeyKey = @"oauth_token";
static NSString *const kZLATwitterAccessSecretKey = @"oauth_token_secret";

static NSString *const kZLATwitterProfileImageURLKey = @"profile_image_url";
static NSString *const kZLATwitterUserNameKey = @"name";
static NSString *const kZLATwitterScreenNameKey = @"screen_name";


/////////////////////////////////////////////////////

@interface ZLATwitterAuthorizer () < UIActionSheetDelegate >

@property (strong) ZLATwitterRequestsPerformer *requestsPerformer;
@property (strong) ACAccountStore *accountStore;
@property (strong) NSArray *accounts;
@property (strong) void(^authorizationCompletionBlock)(BOOL success);

@end

/////////////////////////////////////////////////////

@implementation ZLATwitterAuthorizer

#pragma mark - Class methods

+(BOOL) localTwitterAccountAvailable
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

#pragma mark - Object lifecycle

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialization

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }

    return self;
}

-(void) setup
{
    [self setupDependencies];
    [self subscribeForNotifications];
}

-(void) setupDependencies
{
    self.requestsPerformer = [[ZLATwitterRequestsPerformer alloc] init];
    self.accountStore = [[ACAccountStore alloc] init];
}

-(void) subscribeForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTwitterAccounts)
                                                 name:ACAccountStoreDidChangeNotification
                                               object:nil];
}

#pragma mark - Twitter accounts access

-(void) refreshTwitterAccounts
{
    if ([ZLATwitterAuthorizer localTwitterAccountAvailable])
    {
        if ([self shouldRefreshAccounts])
        {
            [self obtainAccessToAccountsWithCompletionBlock:nil];
        }
    }
}

-(BOOL) shouldRefreshAccounts
{
    // "refresh" can be made if we already have list of accounts
    return self.accounts.count > 0;
}

-(void) obtainAccessToAccountsWithCompletionBlock:(void (^)(BOOL accessGranted)) completionBlock
{
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error)
    {
        if (granted)
        {
            self.accounts = [self.accountStore accountsWithAccountType:twitterAccountType];
        }

        if (completionBlock)
        {
            completionBlock(granted);
        }
    };

    [self.accountStore requestAccessToAccountsWithType:twitterAccountType
                                               options:nil
                                            completion:handler];
}

#pragma mark - Authorization

-(void) performReverseAuthorizationWithCompletionBlock:(void (^)(BOOL success)) completionBlock
{
    NSAssert(self.consumerKey, @"no API key to authorize with");
    NSAssert(self.consumerSecret, @"no API secret to authorize with");

    self.authorizationCompletionBlock = completionBlock;

    if ([ZLATwitterAuthorizer localTwitterAccountAvailable])
    {
        [self obtainAccessToAccountsWithCompletionBlock:^(BOOL accountsAccessGranted)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (accountsAccessGranted)
                {
                    [self showAccountsList];
                }
                else
                {
                    [self showAccessDeniedAlert];

                    if (completionBlock)
                    {
                        completionBlock(NO);
                    }
                }
            });
        }];
    }
    else
    {
        [self showNoAccountsAlert];

        if (completionBlock)
        {
            completionBlock(NO);
        }
    }
}

-(void) showNoAccountsAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Accounts not found"
                                message:@"No Twitter accounts are available on this device"
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

-(void) showAccessDeniedAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Access denied"
                                message:@"Application cannot access Twitter accounts"
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

-(void) showAccountsList
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    for (ACAccount *account in self.accounts)
    {
        [sheet addButtonWithTitle:account.username];
    }

    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
}

#pragma mark - UIActionSheetDelegate methods

-(void)  actionSheet:(UIActionSheet *) actionSheet
clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        ACAccount *accountToAuthorizeWith = self.accounts[buttonIndex];
        [self performReverseAuthorizationWithAccount:accountToAuthorizeWith];
    }
}

-(void) performReverseAuthorizationWithAccount:(ACAccount *) accountToAuthorizeWith
{
    void(^completionHandler)(NSData *, NSError *) = ^(NSData *data, NSError *error)
    {
        [self handleAuthorizationResultWithData:data
                                          error:error];
    };

    [self.requestsPerformer performReverseAuthWithAccount:accountToAuthorizeWith
                                              consumerKey:self.consumerKey
                                           consumerSecret:self.consumerSecret
                                        completionHandler:completionHandler];
}

-(void) handleAuthorizationResultWithData:(NSData *) data
                                    error:(NSError *) error
{
    if (data && !error)
    {
        [self handleAuthorizationResponseData:data];
        [self.requestsPerformer verifyCredentialsWithConsumerKey:self.consumerKey
                                                  consumerSecret:self.consumerSecret
                                                       accessKey:self.accessToken
                                                    accessSecret:self.accessTokenSecret
                                               completionHandler:^(NSDictionary *response, NSError *userInfoRequestError)
                                               {
                                                   if (response && !error)
                                                   {
                                                       [self handleUserInfoResponse:response];
                                                   }
                                                   else
                                                   {
                                                       [self executeCompletionBlockWithSuccess:NO];
                                                   }
                                               }];
    }
    else
    {
        [self showLoginFailedAlert];
        [self executeCompletionBlockWithSuccess:NO];
    }
}

-(void) showLoginFailedAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Twitter login"
                                message:@"Error: unable to login with Twitter. "
                                        "Check if credentials of account you chose "
                                        "are valid or try to login with another account"
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

#pragma mark - Response handling

-(void) handleAuthorizationResponseData:(NSData *) responseData
{
    NSString *responseStr = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
    NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
    for (NSString *responsePart in parts)
    {
        [self handleResponsePart:responsePart];
    }
}

-(void) handleResponsePart:(NSString *) responsePart
{
    NSArray *keyAndValue = [responsePart componentsSeparatedByString:@"="];
    NSString *key = [keyAndValue firstObject];
    NSString *value = keyAndValue[1];

    if ([key isEqualToString:kZLATwitterAccessKeyKey])
    {
        self.accessToken = value;
    }
    else if ([key isEqualToString:kZLATwitterAccessSecretKey])
    {
        self.accessTokenSecret = value;
    }
}

-(void) handleUserInfoResponse:(NSDictionary *) response
{
    self.fullUserName = response[kZLATwitterUserNameKey];
    self.twitterUserName = response[kZLATwitterScreenNameKey];
    self.profilePictureAddress = response[kZLATwitterProfileImageURLKey];
    [self executeCompletionBlockWithSuccess:YES];
}

-(void) executeCompletionBlockWithSuccess:(BOOL) success
{
    if (self.authorizationCompletionBlock)
    {
        self.authorizationCompletionBlock(success);
    }

    self.authorizationCompletionBlock = nil;
}

@end

/////////////////////////////////////////////////////