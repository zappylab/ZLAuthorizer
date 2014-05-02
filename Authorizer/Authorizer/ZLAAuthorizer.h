//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>
#import <FacebookSDK/FacebookSDK.h>

/////////////////////////////////////////////////////

@class ZLAUserInfoContainer;
@class GPPSignInButton;

/////////////////////////////////////////////////////

@interface ZLAAuthorizer : NSObject <GPPSignInDelegate, FBLoginViewDelegate>

@property (readonly) ZLAUserInfoContainer *userInfo;
@property (readonly) BOOL signedIn;
@property (readonly) BOOL performingAuthorization;

-(void) setBaseURL:(NSURL *) baseURL;

-(void) performStartupAuthorization;

-(void) performNativeAuthorizationWithUserEmail:(NSString *) email
                                       password:(NSString *) password
                                completionBlock:(void (^)(BOOL success)) completionBlock;

-(void) performTwitterAuthorizationWithAPIKey:(NSString *) APIKey
                                    APISecret:(NSString *) APISecret
                              completionBlock:(void (^)(BOOL success)) completionBlock;

-(void) signOut;

@end

/////////////////////////////////////////////////////