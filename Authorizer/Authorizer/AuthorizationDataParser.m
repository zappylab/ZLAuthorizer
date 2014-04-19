//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "AuthorizationDataParser.h"

#import "ZLACredentialsStorage.h"

/////////////////////////////////////////////////////

@interface AuthorizationDataParser ()

@end

/////////////////////////////////////////////////////

@implementation AuthorizationDataParser

#pragma mark - Login responses

+(void) handleLoginResponse:(NSDictionary *) response
{
//    NSString *fullUserName = response[@"full_name"];
//    if (fullUserName.length > 0) {
//        [SRSettingsModel sharedInstance].fullUserName = fullUserName;
//    }
//    else {
//        [SRSettingsModel sharedInstance].fullUserName = [ZLACredentialsStorage userName];
//    }
//
//    [SRSettingsModel sharedInstance].userAffiliation = response[kUserAffiliationKey];
//
//    NSString *profilePicture = response[@"profile_image"];
//    if (profilePicture.length > 0) {
//        [SRSettingsModel sharedInstance].profilePictureURL = [NSURL URLWithString:profilePicture];
//    }
//    else {
//        [SRSettingsModel sharedInstance].profilePictureURL = nil;
//    }
//
//    [SRSettingsModel sharedInstance].zappyLoginOK = YES;
}


@end

/////////////////////////////////////////////////////