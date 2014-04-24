//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, ZLAAuthorizationMethod) {
    ZLAAuthorizationMethodNative,
    ZLAAuthorizationMethodTwitter
};

/////////////////////////////////////////////////////

@interface ZLACredentialsStorage : NSObject

+(NSString *) userName;
+(void) setUserName:(NSString *) userName;

+(NSString *) password;
+(void) setPassword:(NSString *) password;

+(NSString *) twitterUserName;
+(void) setTwitterUserName:(NSString *) twitterUserName;

+(NSString *) twitterAccessTokenSecret;
+(void) setTwitterAccessToken:(NSString *) twitterAccessTokenSecret;

+(ZLAAuthorizationMethod) authorizationMethod;
+(void) setAuthorizationMethod:(ZLAAuthorizationMethod) method;

+(void) wipeOutExistingCredentials;

@end

/////////////////////////////////////////////////////