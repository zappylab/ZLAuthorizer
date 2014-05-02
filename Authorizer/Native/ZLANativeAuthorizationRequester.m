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
    if (self) {

    }

    return self;
}

#pragma mark - Requests

-(void) performNativeLoginWithUserName:(NSString *) userName
                              password:(NSString *) password
                       completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSParameterAssert(userName);
    NSParameterAssert(password);

    [self.requestsPerformer POST:kZLALoginRequestPath
                      parameters:@{kZLAUserNameKey     : userName,
                                   kZLAUserPasswordKey : password}
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {
                   if (completionBlock)
                   {
                       completionBlock(success, response);
                   }
               }];
}

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSParameterAssert(email);
    NSParameterAssert(password);
    NSParameterAssert(fullName);

    [self.requestsPerformer POST:kZLARegisterRequestPath
                      parameters:@{kZLAUserFullNameKey : fullName,
                                   kZLAUserNameKey     : email,
                                   kZLAUserPasswordKey : password}
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {
                   if (completionBlock)
                   {
                       completionBlock(success, response);
                   }
               }];
}

-(void) resetPassword
{
    [self.requestsPerformer POST:kZLAResetPasswordRequestPath
                      parameters:nil
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {

               }];
}

@end

/////////////////////////////////////////////////////