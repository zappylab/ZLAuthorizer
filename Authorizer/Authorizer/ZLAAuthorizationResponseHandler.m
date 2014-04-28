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
    NSString *responseStatus = response[kZLAResponseStatusKey];
    if ([responseStatus isEqualToString:kZLAResponseStatusSocial]) {
        [self.delegate responseHandlerDidDetectSocialLogin];
    }
    else {
        [self handleSuccessfullResponse:response];
    }
}

-(void) handleSuccessfullResponse:(NSDictionary *) response
{
    NSString *fullUserName = response[kZLAFullUserNameKey];
    if (fullUserName.length > 0) {
        self.userInfoContainer.fullName = fullUserName;
    }
    else {
        self.userInfoContainer.fullName = [ZLACredentialsStorage userEmail];
    }

    self.userInfoContainer.firstName = response[kZLAFirstNameKey];
    self.userInfoContainer.lastName = response[kZLALastNameKey];
    self.userInfoContainer.affiliation = response[kZLAUserAffiliationKey];

    NSString *profilePicture = response[kZLAProfilePictureKey];
    if (profilePicture.length > 0) {
        self.userInfoContainer.profilePictureURL = [NSURL URLWithString:profilePicture];
    }
    else {
        self.userInfoContainer.profilePictureURL = nil;
    }
}

-(void) handleRegistrationResponse:(NSDictionary *) response
{
    NSString *responseStatus = response[kZLAResponseStatusKey];
    if (![responseStatus isEqualToString:kZLAResponseStatusOK]) {
        NSString *responseStatusExplanation = response[kZLAResponseStatusExplanationKey];
        [self.delegate responseHandlerDidDetectErrorMessage:responseStatusExplanation];
    }
}

@end

/////////////////////////////////////////////////////