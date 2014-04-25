//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLANativeAuthorizer.h"

#import "ZLANativeAuthorizationRequester.h"
#import "ZLACredentialsStorage.h"

#import "NSString+Validation.h"

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
    if (self) {
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

-(void) performNativeAuthorizationWithCompletionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    if ([self hasEnoughDataToPerformNativeAuthorization])
    {
        [self.requester performNativeLoginWithUserName:[ZLACredentialsStorage userEmail]
                                                      password:[ZLACredentialsStorage password]
                                               completionBlock:^(BOOL success, NSDictionary *response)
                                               {
                                                   if (!success) {
                                                       [ZLACredentialsStorage setPassword:nil];
                                                   }

                                                   if (completionBlock) {
                                                       completionBlock(success, response);
                                                   }
                                               }];
    }
}

-(BOOL) hasEnoughDataToPerformNativeAuthorization
{
    return [[ZLACredentialsStorage userEmail] isValidEmail] && [ZLACredentialsStorage password].length >= kZLAMinPasswordLength;
}


-(BOOL) ableToRegisterUserWithFullName:(NSString *) fullName
                                 email:(NSString *) email
                              password:(NSString *) password
{
    return [email isValidEmail] && fullName.length > 0 && password.length > kZLAMinPasswordLength;
}

@end

/////////////////////////////////////////////////////