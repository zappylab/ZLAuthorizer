//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLASocialAuthorizationRequester.h"

#import "ZLARequestsPerformer.h"
#import "ZLADefinitions.h"
#import "ZLACredentialsStorage.h"

/////////////////////////////////////////////////////

@interface ZLASocialAuthorizationRequester ()

@property (strong) ZLARequestsPerformer *requestsPerformer;

@end

/////////////////////////////////////////////////////

@implementation ZLASocialAuthorizationRequester

#pragma mark - Initialization

-(instancetype) init
{
    @throw [NSException exceptionWithName:@""
                                   reason:@""
                                 userInfo:nil];
}

-(instancetype) initWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer
{
    self = [super init];
    if (self) {
        _requestsPerformer = requestsPerformer;
    }

    return self;
}

#pragma mark - Requests

-(void) validateTwitterAccessToken:(NSString *) accessToken
                   forUserWithName:(NSString *) userName
                   completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSParameterAssert(accessToken);
    NSParameterAssert(userName);

    [self.requestsPerformer POST:kZLAValidateTwitterAccessTokenRequestPath
                      parameters:@{kZLATwitterUserNameKey  : userName,
                                   kZLAOauthAccessTokenKey : accessToken}
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {
                   if (completionBlock)
                   {
                       completionBlock(success, response);
                   }
               }];
}

-(void) performLoginWithSocialNetworkIdentifier:(NSString *) socialNetworkKey
                                 userIdentifier:(NSString *) userName
                                    accessToken:(NSString *) accessToken
                                      firstName:(NSString *) firstName
                                       lastName:(NSString *) lastName
                          profilePictureAddress:(NSString *) profilePictureAddress
                                completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSMutableDictionary *parameters = [self buildLoginParametersWithSocialNetworkIdentifier:socialNetworkKey
                                                                                   userName:userName
                                                                                accessToken:accessToken
                                                                                  firstName:firstName
                                                                                   lastName:lastName
                                                                      profilePictureAddress:profilePictureAddress];
    [self.requestsPerformer POST:kZLALoginRequestPath
                      parameters:parameters
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {
                   if (completionBlock)
                   {
                       completionBlock(success, response);
                   }
               }];
}

-(NSMutableDictionary *) buildLoginParametersWithSocialNetworkIdentifier:(NSString *) socialNetworkKey
                                                                userName:(NSString *) userName
                                                             accessToken:(NSString *) accessToken
                                                               firstName:(NSString *) firstName
                                                                lastName:(NSString *) lastName
                                                   profilePictureAddress:(NSString *) profilePictureAddress
{
    NSParameterAssert(socialNetworkKey);
    NSParameterAssert(userName);
    NSParameterAssert(accessToken);
    NSAssert([ZLACredentialsStorage userEmail], @"user email required to complete Twitter authorization");

    NSMutableDictionary *parameters = [@{kZLAUserNameKey         : [ZLACredentialsStorage userEmail],
                                         socialNetworkKey        : userName,
                                         kZLAOauthAccessTokenKey : accessToken} mutableCopy];
    if (firstName)
    {
        parameters[kZLAFirstNameKey] = firstName;
    }

    if (lastName)
    {
        parameters[kZLALastNameKey] = lastName;
    }

    if (profilePictureAddress)
    {
        parameters[kZLAProfilePictureURLKey] = profilePictureAddress;
    }

    return parameters;
}

@end

/////////////////////////////////////////////////////