//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "Authorizer.h"

#import "CredentialsStorage.h"
#import "AuthorizationRequestsPerformer.h"

/////////////////////////////////////////////////////

@interface Authorizer ()

@end

/////////////////////////////////////////////////////

@implementation Authorizer

+(void) performStartupAuthorization
{
    [self performAuthorizationWithCompletionBlock:nil];
}

+(void) performAuthorizationWithCompletionBlock:(void (^)(BOOL success)) completionBlock
{
    if ([self hasEnoughDataToPerformAuthorization])
    {
        [[AuthorizationRequestsPerformer sharedInstance] loginWithCompletionBlock:^(BOOL success) {
            if (!success) {
                [CredentialsStorage sharedInstance].password = nil;
            }

            if (completionBlock) {
                completionBlock(success);
            }
        }];
    }
}

+(BOOL) hasEnoughDataToPerformAuthorization
{
    return [CredentialsStorage sharedInstance].userName.length > kMinCredentialStringLength &&
            [CredentialsStorage sharedInstance].userName.length > kMinCredentialStringLength;
}

@end

/////////////////////////////////////////////////////