//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLASocialAuthorizationRequester.h"

#import "ZLNetworkRequestsPerformer.h"
#import "ZLAConstants.h"
#import "ZLACredentialsStorage.h"

/////////////////////////////////////////////////////

@interface ZLASocialAuthorizationRequester ()

@property (strong) ZLNetworkRequestsPerformer *requestsPerformer;

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

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    self = [super init];
    if (self)
    {
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

    [self.requestsPerformer POST:ZLAValidateTwitterAccessTokenRequestPath
                      parameters:@{ZLASocialNetworkTwitter : userName,
                                   ZLAOAuthAccessTokenKey  : accessToken}
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
                                                                             userIdentifier:userName
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

-(NSMutableDictionary *) buildLoginParametersWithSocialNetworkIdentifier:(NSString *) socialNetworkKey
                                                          userIdentifier:(NSString *) userIdentifier
                                                             accessToken:(NSString *) accessToken
                                                               firstName:(NSString *) firstName
                                                                lastName:(NSString *) lastName
                                                   profilePictureAddress:(NSString *) profilePictureAddress
{
    NSParameterAssert(socialNetworkKey);
    NSParameterAssert(userIdentifier);
    NSParameterAssert(accessToken);
    NSAssert([ZLACredentialsStorage userEmail], @"user email required to complete social authorization");

    NSMutableDictionary *parameters = [@{ZLAUserNameKey         : [ZLACredentialsStorage userEmail],
                                         socialNetworkKey       : userIdentifier,
                                         ZLAOAuthAccessTokenKey : accessToken} mutableCopy];
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