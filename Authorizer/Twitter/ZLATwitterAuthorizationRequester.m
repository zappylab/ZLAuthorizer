//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <ZLNetworkRequestsPerformer/ZLNetworkRequestsPerformer.h>

#import "ZLATwitterAuthorizationRequester.h"

#import "ZLAConstants.h"
#import "ZLACredentialsStorage.h"

/////////////////////////////////////////////////////

@interface ZLATwitterAuthorizationRequester ()

@end

/////////////////////////////////////////////////////

@implementation ZLATwitterAuthorizationRequester

#pragma mark - Requests

-(void) validateTwitterAccessToken:(NSString *) accessToken
                   forUserWithName:(NSString *) userName
                   completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSParameterAssert(accessToken);
    NSParameterAssert(userName);

    [self.requestsPerformer POST:ZLAValidateTwitterAccessTokenRequestPath
                      parameters:@{ZLATwitterUserNameKey     : userName,
                                   ZLATwitterAccessTokenKey  : accessToken}
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {
                   if (completionBlock)
                   {
                       completionBlock(success, response);
                   }
               }];
}

-(void) performLoginWithTwitterUserName:(NSString *) userName
                            accessToken:(NSString *) accessToken
                              firstName:(NSString *) firstName
                               lastName:(NSString *) lastName
                  profilePictureAddress:(NSString *) profilePictureAddress
                        completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSMutableDictionary *parameters = [self buildLoginParametersWithTwitterUserName:userName
                                                                        accessToken:accessToken
                                                                          firstName:firstName
                                                                           lastName:lastName
                                                              profilePictureAddress:profilePictureAddress];
    [self.requestsPerformer POST:ZLALoginRequestPath
                      parameters:parameters
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {
                   if (completionBlock)
                   {
                       completionBlock(success, response);
                   }
               }];
}

-(NSMutableDictionary *) buildLoginParametersWithTwitterUserName:(NSString *) userName
                                                     accessToken:(NSString *) accessToken
                                                       firstName:(NSString *) firstName
                                                        lastName:(NSString *) lastName
                                           profilePictureAddress:(NSString *) profilePictureAddress
{
    NSParameterAssert(userName);
    NSParameterAssert(accessToken);
    NSAssert([ZLACredentialsStorage userEmail], @"user email required to complete Twitter authorization");

    NSMutableDictionary *parameters = [@{ZLAUserNameKey            : [ZLACredentialsStorage userEmail],
                                         ZLATwitterUserNameKey     : userName,
                                         ZLATwitterAccessTokenKey  : accessToken} mutableCopy];
    if (firstName)
    {
        parameters[ZLAFirstNameKey] = firstName;
    }

    if (lastName)
    {
        parameters[ZLALastNameKey] = lastName;
    }

    if (profilePictureAddress)
    {
        parameters[ZLAProfilePictureURLKey] = profilePictureAddress;
    }

    return parameters;
}

@end

/////////////////////////////////////////////////////