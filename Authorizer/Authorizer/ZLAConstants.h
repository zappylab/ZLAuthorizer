//
//  ZLAConstants.h
//  ZLAuthorizer
//
//  Created by Ilya Dyakonov on 21/04/14.
//  Copyright (c) 2014 ZappyLab. All rights reserved.
//

#ifndef AuthorizerExample_ZLAConstants_h
#define AuthorizerExample_ZLAConstants_h

#ifdef __OBJC__
#import <Foundation/Foundation.h>

static NSString *const ZLAProfilePictureKey = @"profile_image";
static NSString *const ZLAProfilePictureURLKey = @"img_url";
static NSString *const ZLAUserAffiliationKey = @"affiliation";
static NSString *const ZLAUserAffiliationURLKey = @"affiliation_url";

static NSString *const ZLAUserBioKey = @"bio";

static NSString *const ZLAFullUserNameKey = @"full_name";
static NSString *const ZLAFirstNameKey = @"first_name";
static NSString *const ZLALastNameKey = @"last_name";
static NSString *const ZLAUsernameKey = @"username";

static NSString *const ZLARegisterRequestPath = @"mregister";
static NSString *const ZLALoginRequestPath = @"mlogin";
static NSString *const ZLAValidateTwitterAccessTokenRequestPath = @"mvalidate_twitter";

static NSString *const ZLAUserNameKey = @"zll";
static NSString *const ZLAUserPasswordKey = @"zlp";
static NSString *const ZLAUserFullNameKey = @"ufn";
static NSString *const ZLAUserEmailKey = @"email";
static NSString *const ZLAUserPasswordOnUpdateKey = @"password";

static NSString *const ZLASocialNetworkTwitter = @"twitter";
static NSString *const ZLASocialNetworkFacebook = @"facebook";
static NSString *const ZLASocialNetworkGooglePlus = @"googleplus";

static NSString *const ZLAOAuthAccessTokenKey = @"token";

static NSString *const ZLAResponseStatusKey = @"request";
static NSString *const ZLAResponseStatusOK = @"OK";
static NSString *const ZLAResponseStatusSocial = @"SOCIAL";
static NSString *const ZLAResponseStatusErrorMessage = @"error_message";

static NSString *const ZLAResponseStatusExplanationKey = @"status";

#endif /* __OBJC__ */

#endif /* AuthorizerExample_ZLAConstants_h */
