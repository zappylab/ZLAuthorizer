//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import <ZLNetworkRequestsPerformer/ZLNetworkRequestsPerformer.h>

#import "ZLANativeAuthorizationRequester.h"

#import "ZLAConstants.h"

/////////////////////////////////////////////////////

static NSString *const kZLAResetPasswordRequestPath = @"mresetpassword";

/////////////////////////////////////////////////////

@interface ZLANativeAuthorizationRequester ()

@end

/////////////////////////////////////////////////////

@implementation ZLANativeAuthorizationRequester

#pragma mark - Initialization

-(instancetype) init
{
    self = [super init];
    if (self)
    {

    }

    return self;
}

#pragma mark - Requests

-(NSOperation *) performNativeLoginWithUserName:(NSString *) userName
                                       password:(NSString *) password
                                completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    NSParameterAssert(userName);
    NSParameterAssert(password);

    return [self.requestsPerformer POST:ZLALoginRequestPath
                             parameters:@{ZLAUserNameKey     : userName,
                                          ZLAUserPasswordKey : password}
                      completionHandler:completionBlock];
}

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    NSParameterAssert(email);
    NSParameterAssert(password);
    NSParameterAssert(fullName);

    [self.requestsPerformer POST:ZLARegisterRequestPath
                      parameters:@{ZLAUserFullNameKey : fullName,
                                   ZLAUserNameKey     : email,
                                   ZLAUserPasswordKey : password}
               completionHandler:completionBlock];
}

-(void) resetPassword
{
    [self.requestsPerformer POST:kZLAResetPasswordRequestPath
                      parameters:nil
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {
                   // TODO: ???
               }];
}

-(void) resetPasswordForUserWithEmail:(NSString *) email
                      completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    NSParameterAssert(email);

    [self.requestsPerformer POST:kZLAResetPasswordRequestPath
                      parameters:@{@"email" : email}
               completionHandler:completionBlock];
}

@end

/////////////////////////////////////////////////////