//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, ZLAAuthorizationMethod) {
    ZLAAuthorizationMethodNone = 0,
    ZLAAuthorizationMethodNative,
    ZLAAuthorizationMethodTwitter,
    ZLAAuthorizationMethodFacebook,
    ZLAAuthorizationMethodGooglePlus
};

/////////////////////////////////////////////////////

@interface ZLACredentialsStorage : NSObject

+(void) migrateUserDataIfNeeded;

+(NSString *) userIdentifier;
+(void) setUserIdentifier:(NSString *) userIdentifier;

+(NSString *) userEmail;
+(void) setUserEmail:(NSString *) userName;

+(NSString *) password;
+(void) setPassword:(NSString *) password;

+(NSString *) socialUserIdentifier;
+(void) setSocialUserIdentifier:(NSString *) socialUserIdentifier;

+(NSString *) socialAccessToken;
+(void) setSocialAccessToken:(NSString *) socialAccessToken;

+(NSDate *) userDataSynchTimestamp;
+(void) setUserDataSynchTimestamp:(NSDate *) userDataSynchTimestamp;

+(ZLAAuthorizationMethod) authorizationMethod;
+(void) setAuthorizationMethod:(ZLAAuthorizationMethod) method;
+(void) resetAuthorizationMethod;

+(void) wipeOutExistingCredentials;

@end

/////////////////////////////////////////////////////