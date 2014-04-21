//
//  ZLADefinitions.h
//  AuthorizerExample
//
//  Created by Ilya Dyakonov on 21/04/14.
//  Copyright (c) 2014 ZappyLab. All rights reserved.
//

#ifndef AuthorizerExample_ZLADefinitions_h
#define AuthorizerExample_ZLADefinitions_h

#ifdef __OBJC__
#import <Foundation/Foundation.h>

static NSString *const kZLAProfilePictureKey = @"profile_image";
static NSString *const kZLAProfilePictureURLKey = @"img_url";
static NSString *const kZLAUserAffiliationKey = @"affiliation";

static NSString *const kZLAFullUserNameKey = @"full_name";
static NSString *const kZLAFirstNameKey = @"first_name";
static NSString *const kZLALastNameKey = @"last_name";

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

#endif

#endif
