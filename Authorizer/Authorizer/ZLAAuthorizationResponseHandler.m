//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import "ZLAAuthorizationResponseHandler.h"

#import "ZLACredentialsStorage.h"
#import "ZLAUserInfoContainer.h"

#import "ZLAConstants.h"

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
        [self handleSuccessfullResponse:response];
    }
}

-(void) handleSuccessfullResponse:(NSDictionary *) response
{
    NSString *fullUserName = response[ZLAFullUserNameKey];
    if (fullUserName.length > 0) {
        self.userInfoContainer.fullName = fullUserName;
    }
    else {
        self.userInfoContainer.fullName = [ZLACredentialsStorage userEmail];
    }

    self.userInfoContainer.firstName = response[ZLAFirstNameKey];
    self.userInfoContainer.lastName = response[ZLALastNameKey];
    self.userInfoContainer.affiliation = response[ZLAUserAffiliationKey];

    NSString *profilePicture = response[ZLAProfilePictureKey];
    if (profilePicture.length > 0) {
        self.userInfoContainer.profilePictureURL = [NSURL URLWithString:profilePicture];
    }
    else {
        self.userInfoContainer.profilePictureURL = nil;
    }
}

-(void) handleRegistrationResponse:(NSDictionary *) response
{
    NSString *responseStatus = response[ZLAResponseStatusKey];
    if (![responseStatus isEqualToString:ZLAResponseStatusOK]) {
        NSString *responseStatusExplanation = response[ZLAResponseStatusExplanationKey];
        [self.delegate responseHandlerDidDetectErrorMessage:responseStatusExplanation];
    }
}

@end

/////////////////////////////////////////////////////