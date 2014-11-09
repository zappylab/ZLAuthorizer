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

    NSString *responseStatusExplanation = response[ZLAResponseStatusExplanationKey];
    if (responseStatusExplanation)
    {
        error = [NSError errorWithDomain:ZLAErrorServersideDomain
                                    code:0
                                userInfo:@{ZLAErrorMessageKey : responseStatusExplanation}];
    }

    return error;
}

@end

/////////////////////////////////////////////////////