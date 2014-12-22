//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import "ZLAAuthorizationResponseHandler.h"

#import "ZLAUserInfoContainer.h"
#import "ZLAConstants.h"
#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@interface ZLAAuthorizationResponseHandler ()

@end

/////////////////////////////////////////////////////

@implementation ZLAAuthorizationResponseHandler

#pragma mark - Initialization

-(instancetype) init
{
    self = [self initWithUserInfoContainer:nil];
    if (self)
    {

    }

    return self;
}

-(instancetype) initWithUserInfoContainer:(ZLAUserInfoContainer *) userInfoContainer
{
    self = [super init];
    if (self) {
        self.userInfoContainer = userInfoContainer;
    }

    return self;
}

#pragma mark - Login responses

-(void) handleLoginResponse:(NSDictionary *) response
{
    NSString *responseStatus = response[ZLAResponseStatusKey];
    if ([responseStatus isEqualToString:ZLAResponseStatusSocial]) {
        [self.delegate responseHandlerDidDetectSocialLoginWithNetwork:response[ZLAResponseStatusExplanationKey]];
    }
    else {
        [self.userInfoContainer handleUserInfoData:response];
    }
}

-(NSError *) errorFromResponse:(NSDictionary *) response
{
    NSError *error = nil;

    NSString *responseStatus = response[ZLAResponseStatusExplanationKey];
    if (responseStatus)
    {
        error = [NSError errorWithDomain:ZLAErrorServersideDomain
                                    code:0
                                userInfo:@{ZLAErrorMessageKey : [self humanReadableErrorMessageForResponseStatus:responseStatus]}];
    }

    return error;
}

-(NSString *) humanReadableErrorMessageForResponseStatus:(NSString *) status
{
    NSString *message = nil;
    if ([status isEqualToString:@"not_verified"])
    {
        message = @"You must verify your email address before signing in. Please check your email and click the activation link.";
    }
    else
    {
        // TODO: use statuses as statuses, not messages (later)
        message = status;
    }

    return message;
}

@end

/////////////////////////////////////////////////////