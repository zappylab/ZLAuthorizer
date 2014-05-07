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

+(NSString *) userIdentifier;
+(void) setUserIdentifier:(NSString *) userIdentifier;

+(NSString *) userEmail;
+(void) setUserEmail:(NSString *) userName;

+(NSString *) password;
+(void) setPassword:(NSString *) password;

+(NSString *) twitterUserName;
+(void) setTwitterUserName:(NSString *) twitterUserName;

+(NSString *) twitterAccessToken;
+(void) setTwitterAccessToken:(NSString *) twitterAccessTokenSecret;

+(ZLAAuthorizationMethod) authorizationMethod;
+(void) setAuthorizationMethod:(ZLAAuthorizationMethod) method;
+(void) resetAuthorizationMethod;

+(void) wipeOutExistingCredentials;

@end

/////////////////////////////////////////////////////