//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
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
    NSError *emailAndPasswordCheckError = nil;
    BOOL bothEmailAndPasswordAreValid = [self checkUserEmail:email
                                                 andPassword:password
                                                       error:&emailAndPasswordCheckError];
    if (bothEmailAndPasswordAreValid)
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
            completionBlock(NO, nil, emailAndPasswordCheckError);
        }
    }
}

-(void) resetPasswordForUserWithEmail:(NSString *) email
                      completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    if ([email isValidEmail])
    {
        [self.requester resetPasswordForUserWithEmail:email
                                      completionBlock:completionBlock];
    }
    else
    {
        NSString *message = [NSString stringWithFormat:@"%@ is not a valid email",
                                                       email.length > 0 ? email : @"Empty email"];
        NSError *error = [NSError errorWithDomain:ZLAErrorDomain
                                     code:ZLAErrorCodeInvalidEmail
                                 userInfo:@{ZLAErrorMessageKey : message}];
        if (completionBlock)
        {
            completionBlock(NO, nil, error);
        }
    }
}

-(BOOL) checkUserEmail:(NSString *) email
           andPassword:(NSString *) password
                 error:(NSError **) error
{
    BOOL bothEmailAndPasswordAreValid = YES;
    if (![email isValidEmail])
    {
        NSString *message = [NSString stringWithFormat:@"%@ is not a valid email",
                                                       email.length > 0 ? email : @"Empty email"];
        *error = [NSError errorWithDomain:ZLAErrorDomain
                                     code:ZLAErrorCodeInvalidEmail
                                 userInfo:@{ZLAErrorMessageKey : message}];
        bothEmailAndPasswordAreValid = NO;
    }

    if (![ZLAUserInfoValidator isPasswordAcceptable:password])
    {
        bothEmailAndPasswordAreValid = NO;
    }

    return bothEmailAndPasswordAreValid;
}

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    if ([self ableToRegisterUserWithFullName:fullName
                                       email:email
                                    password:password])
    {
        [self.requester registerUserWithFullName:fullName
                                           email:email
                                        password:password
                                 completionBlock:completionBlock];
    }
    else
    {
        if (completionBlock)
        {
            completionBlock(NO, nil, nil);
        }
    }
}

-(BOOL) ableToRegisterUserWithFullName:(NSString *) fullName
                                 email:(NSString *) email
                              password:(NSString *) password
{
    if (![email isValidEmail])
    {
        [UIAlertView ZLA_showInvalidEmailAlertForRegistration:email];
        return NO;
    }

    if (![ZLAUserInfoValidator isFullNameAcceptable:fullName])
    {
        [UIAlertView ZLA_showTooShowFullNameAlertForRegistration];
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