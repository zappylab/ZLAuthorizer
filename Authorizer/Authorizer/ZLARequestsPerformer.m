//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import <AFNetworking/AFNetworking.h>

#import "ZLARequestsPerformer.h"
#import "ZLADefinitions.h"

/////////////////////////////////////////////////////

@interface ZLARequestsPerformer ()

@property (strong) AFHTTPRequestOperationManager *requestOperationManager;

@end

/////////////////////////////////////////////////////

@implementation ZLARequestsPerformer

#pragma mark - Initialization

-(instancetype) initWithBaseURL:(NSURL *) baseURL
{
    self = [super init];
    if (self)
    {
        [self setupWithBaseURL:baseURL];
    }

    return self;
}

-(void) setupWithBaseURL:(NSURL *) baseURL
{
    self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
}

#pragma mark - Login

-(void) performNativeLoginWithUserName:(NSString *) userName
                              password:(NSString *) password
                        userIdentifier:(NSString *) userIdentifier
                       completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSParameterAssert(userName);
    NSParameterAssert(password);
    NSParameterAssert(userIdentifier);

    [self.requestOperationManager POST:kZLALoginRequestPath
                            parameters:@{kZLAUserNameKey       : userName,
                                         kZLAUserPasswordKey   : password,
                                         kZLAUserIdentifierKey : userIdentifier}
                               success:^(AFHTTPRequestOperation *operation, id responseObject)
                               {
                                   if ([self isResponseOK:responseObject])
                                   {
                                       if (completionBlock)
                                       {
                                           completionBlock(YES, responseObject);
                                       }
                                   }
                                   else
                                   {
                                       if (completionBlock)
                                       {
                                           completionBlock(NO, nil);
                                       }
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
                               {
                                   if (completionBlock)
                                   {
                                       completionBlock(NO, nil);
                                   }
                               }];
}

-(void) showInvalidUserNameAlertWithUserName:(NSString *) userName
{
    [[[UIAlertView alloc] initWithTitle:@"Login"
                                message:[NSString stringWithFormat:@"%@ is not a valid email",
                                                                   userName]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
}

-(void) performLoginWithTwitterUserName:(NSString *) userName
                            accessToken:(NSString *) accessToken
                              firstName:(NSString *) firstName
                               lastName:(NSString *) lastName
                  profilePictureAddress:(NSString *) profilePictureAddress
                        completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSParameterAssert(userName);
    NSParameterAssert(accessToken);

    NSMutableDictionary *parameters = [@{kZLATwitterUserNameKey    : userName,
                                         kZLATwitterAccessTokenKey : accessToken} mutableCopy];
    if (firstName) {
        parameters[kZLAFirstNameKey] = firstName;
    }

    if (lastName) {
        parameters[kZLALastNameKey] = lastName;
    }

    if (profilePictureAddress) {
        parameters[kZLAProfilePictureURLKey] = profilePictureAddress;
    }

    [self.requestOperationManager POST:kZLALoginRequestPath
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject)
                               {
                                   if ([self isResponseOK:responseObject]) {
                                       if (completionBlock) {
                                           completionBlock(YES, responseObject);
                                       }
                                   }
                                   else {
                                       if (completionBlock) {
                                           completionBlock(NO, nil);
                                       }
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
                               {
                                   if (completionBlock) {
                                       completionBlock(NO, nil);
                                   }
                               }];
}

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                  userIdentifier:(NSString *) userIdentifier
                 completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    [self.requestOperationManager POST:kZLARegisterRequestPath
                            parameters:@{kZLAUserFullNameKey   : fullName,
                                         kZLAUserNameKey       : email,
                                         kZLAUserPasswordKey   : password,
                                    //kZLAAppKey            : @"2",
                                         kZLAUserIdentifierKey : userIdentifier}
                               success:^(AFHTTPRequestOperation *operation, id responseObject)
                               {
                                   if ([self isResponseOK:responseObject])
                                   {
                                       if (completionBlock)
                                       {
                                           completionBlock(YES, nil);
                                       }
                                   }
                                   else
                                   {
                                       if (completionBlock)
                                       {
                                           completionBlock(NO, responseObject);
                                       }
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
                               {
                                   if (completionBlock)
                                   {
                                       completionBlock(NO, nil);
                                   }
                               }];
}

-(BOOL) isResponseOK:(NSDictionary *) response
{
    BOOL responseOK = NO;

    NSString *responseStatus = response[kZLAResponseStatusKey];
    if ([responseStatus isEqualToString:kZLAResponseStatusOK])
    {
        responseOK = YES;
    }

    return responseOK;
}

@end

/////////////////////////////////////////////////////