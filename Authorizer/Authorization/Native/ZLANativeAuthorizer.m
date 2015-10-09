//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import "ZLANativeAuthorizer.h"

#import "ZLANativeAuthorizationRequester.h"
#import "ZLACredentialsStorage.h"

#import "NSString+Validation.h"
#import "UIAlertView+ZLAuthorizer.h"
#import "ZLAUserInfoValidator.h"

/////////////////////////////////////////////////////

@interface ZLANativeAuthorizer ()

@property (strong) ZLANativeAuthorizationRequester *requester;
@property (strong) NSOperation *loginRequestOperation;

@end

/////////////////////////////////////////////////////

@implementation ZLANativeAuthorizer

#pragma mark - Initialization

-(instancetype) init
{
    self = [super init];
    
    if (self)
    {

    }

    return self;
}

//
// designated initializer
//

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    self = [super init];
    
    if (self)
    {
        [self setupWithRequestsPerformer:requestsPerformer];
    }

    return self;
}

-(void) setupWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    self.requester = [[ZLANativeAuthorizationRequester alloc] init];
    self.requester.requestsPerformer = requestsPerformer;
}

#pragma mark - Requests

-(void) performAuthorizationWithEmail:(NSString *) email
                             password:(NSString *) password
                      completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    if ([self checkUserEmail:email
                 andPassword:password])
    {
        self.loginRequestOperation = [self.requester performNativeLoginWithUserName:email
                                                                           password:password
                                                                    completionBlock:^(BOOL success, NSDictionary *response, NSError *error)
                                                                    {
                                                                        self.loginRequestOperation = nil;

                                                                        if (success)
                                                                        {
                                                                            [ZLACredentialsStorage setUserEmail:email];
                                                                            [ZLACredentialsStorage setPassword:password];
                                                                        }

                                                                        if (completionBlock)
                                                                        {
                                                                            completionBlock(success, response, error);
                                                                        }
                                                                    }];
    }
    else
    {
        if (completionBlock)
        {
            completionBlock(NO, nil, nil);
        }
    }
}

-(BOOL) checkUserEmail:(NSString *) email
           andPassword:(NSString *) password
{
    return [email isValidEmail] && [ZLAUserInfoValidator isPasswordAcceptable:password];
}

-(void) registerUserWithEmail:(NSString *) email
                     password:(NSString *) password
              completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    [self.requester registerUserWithEmail:email
                                 password:password
                          completionBlock:completionBlock];
}

-(BOOL) ableToRegisterUserWithEmail:(NSString *) email
                           password:(NSString *) password
{
    if (![email isValidEmail])
    {
        [UIAlertView ZLA_showInvalidEmailAlertForRegistration:email];
        return NO;
    }

    if (![ZLAUserInfoValidator isPasswordAcceptable:password])
    {
        [UIAlertView ZLA_showTooShortPasswordAlertForRegistration];
        return NO;
    }

    return YES;
}

-(void) resetPassword
{
    [self.requester resetPassword];
}

-(void) loginWithExistingCredentialsWithCompletionBlock:(ZLARequestCompletionBlock) completionBlock
{
    [self performAuthorizationWithEmail:[ZLACredentialsStorage userEmail]
                               password:[ZLACredentialsStorage password]
                        completionBlock:completionBlock];
}

-(void) stopLoggingInWithExistingCredentials
{
    [self.loginRequestOperation cancel];
    self.loginRequestOperation = nil;
}

-(void) signOut
{
    // Do nothing?
}

@end

/////////////////////////////////////////////////////