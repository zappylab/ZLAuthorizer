//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLATwitterAccountsAccessor.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "UIActionSheet+BlocksKit.h"

/////////////////////////////////////////////////////

@interface ZLATwitterAccountsAccessor ()

@property (strong) ACAccountStore *accountStore;
@property (strong) NSArray *accounts;

@end

/////////////////////////////////////////////////////

@implementation ZLATwitterAccountsAccessor

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
    if ([ZLATwitterAccountsAccessor localTwitterAccountAvailable])
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

#pragma mark -

-(void) askUserToChooseAccountWithCompletionBlock:(void(^)(ACAccount *account)) completionBlock
{
    if ([ZLATwitterAccountsAccessor localTwitterAccountAvailable])
    {
        [self obtainAccessToAccountsWithCompletionBlock:^(BOOL accountsAccessGranted)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (accountsAccessGranted) {
                    [self showAccountsListWithCompletionBlock:completionBlock];
                }
                else {
                    [self showAccessDeniedAlert];

                    if (completionBlock) {
                        completionBlock(nil);
                    }
                }
            });
        }];
    }
    else
    {
        [self showNoAccountsAlert];

        if (completionBlock) {
            completionBlock(nil);
        }
    }
}

-(void) showAccountsListWithCompletionBlock:(void(^)(ACAccount *account)) completionBlock
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an account"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    for (ACAccount *account in self.accounts) {
        [sheet addButtonWithTitle:account.username];
    }

    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet bk_setDidDismissBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
    {
        ACAccount *account = nil;
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            account = self.accounts[buttonIndex];
        }

        if (completionBlock) {
            completionBlock(account);
        }
    }];

    [sheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
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

@end

/////////////////////////////////////////////////////