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

/////////////////////////////////////////////////////

static NSUInteger const kZLAMinPasswordLength = 6;

/////////////////////////////////////////////////////

@interface ZLANativeAuthorizer ()

@property (strong) ZLANativeAuthorizationRequester *requester;

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

-(instancetype) initWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer
{
    self = [super init];
    if (self)
    {
        [self setupWithRequestsPerformer:requestsPerformer];
    }

    return self;
}

-(void) setupWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer
{
    self.requester = [[ZLANativeAuthorizationRequester alloc] init];
    self.requester.requestsPerformer = requestsPerformer;
}

#pragma mark - Requests

-(void) performAuthorizationWithUserEmail:(NSString *) userEmail
                                 password:(NSString *) password
                          completionBlock:(ZLASigninRequestCompletionBlock) completionBlock
{
    if ([self checkUserEmail:userEmail
                 andPassword:password])
    {
        [self.requester performNativeLoginWithUserName:userEmail
                                              password:password
                                       completionBlock:completionBlock];
    }
}

-(BOOL) checkUserEmail:(NSString *) email
           andPassword:(NSString *) password
{
    if (![email isValidEmail])
    {
        [UIAlertView ZLA_showInvalidEmailAlertForSignin:email];
        return NO;
    }

    if (password.length < kZLAMinPasswordLength)
    {
        [UIAlertView ZLA_showTooShortPasswordAlertForSignin];
        return NO;
    }

    return YES;
}

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(ZLASigninRequestCompletionBlock) completionBlock
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
}

-(BOOL) ableToRegisterUserWithFullName:(NSString *) fullName
                                 email:(NSString *) email
                              password:(NSString *) password
{
    if (![email isValidEmail]) {
        [UIAlertView ZLA_showInvalidEmailAlertForRegistration:email];
        return NO;
    }

    if (fullName.length == 0) {
        [UIAlertView ZLA_showTooShowFullNameAlertForRegistration];
        return NO;
    }

    if (password.length < kZLAMinPasswordLength) {
        [UIAlertView ZLA_showTooShortPasswordAlertForRegistration];
        return NO;
    }

    return YES;
}

-(void) resetPassword
{
    [self.requester resetPassword];
}

@end

/////////////////////////////////////////////////////