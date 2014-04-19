//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import <AFNetworking/AFNetworking.h>

#import "ZLARequestsPerformer.h"
#import "AuthorizationDataParser.h"

/////////////////////////////////////////////////////

static NSString *const kZLARegisterRequestPath = @"mregister";
static NSString *const kZLALoginRequestPath = @"mlogin";

static NSString *const kZLAUserNameKey = @"zll";
static NSString *const kZLAUserPasswordKey = @"zlp";
static NSString *const kZLAUserFullNameKey = @"ufn";
static NSString *const kZLAUserIdentifierKey = @"uid";

static NSString *const kZLATwitterUserNameKey = @"twitter";
static NSString *const kZLATwitterAccessTokenKey = @"token";

static NSString *const kZLAAppKey = @"app";

static NSString *const kZLAResponseStatusKey = @"request";
static NSString *const kZLAResponseStatusOK = @"OK";

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
                       completionBlock:(void (^)(BOOL success)) completionBlock
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
                                       [AuthorizationDataParser handleLoginResponse:responseObject];

                                       if (completionBlock)
                                       {
                                           completionBlock(YES);
                                       }
                                   }
                                   else
                                   {
                                       if (completionBlock)
                                       {
                                           completionBlock(NO);
                                       }
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
                               {
                                   if (completionBlock)
                                   {
                                       completionBlock(NO);
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
                        completionBlock:(void (^)(BOOL success)) completionBlock
                              firstName:(NSString *) firstName
                               lastName:(NSString *) lastName
                  profilePictureAddress:(NSString *) profilePictureAddress
{
    NSParameterAssert(userName);
    NSParameterAssert(accessToken);

    NSMutableDictionary *parameters = [@{kZLATwitterUserNameKey    : userName,
                                         kZLATwitterAccessTokenKey : accessToken} mutableCopy];
    if (firstName) {
        parameters[@"first_name"] = firstName;
    }

    if (lastName) {
        parameters[@"last_name"] = lastName;
    }

    if (profilePictureAddress) {
        parameters[@"img_url"] = profilePictureAddress;
    }

    [self.requestOperationManager POST:kZLALoginRequestPath
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject)
                               {
                                   if (completionBlock) {
                                       completionBlock(YES);
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
                               {
                                   if (completionBlock) {
                                       completionBlock(NO);
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
                                           completionBlock(NO, (NSDictionary *) responseObject);
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