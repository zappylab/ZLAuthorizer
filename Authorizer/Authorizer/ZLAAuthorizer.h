//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

static NSString *ZLAAuthorizerPerformingRequestKeyPath = @"performingRequest";

/////////////////////////////////////////////////////

@class ZLAUserInfoContainer;

/////////////////////////////////////////////////////

typedef void(^ZLAAuthorizationCompletionBlock)(BOOL success);

/////////////////////////////////////////////////////

@interface ZLAAuthorizer : NSObject

@property (readonly) ZLAUserInfoContainer *userInfo;
@property (readonly) BOOL signedIn;
@property (readonly) BOOL performingRequest;

-(void) setBaseURL:(NSURL *) baseURL;

-(void) performStartupAuthorization;

-(void) performNativeAuthorizationWithUserEmail:(NSString *) email
                                       password:(NSString *) password
                                completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) performTwitterAuthorizationWithAPIKey:(NSString *) APIKey
                                    APISecret:(NSString *) APISecret
                              completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) signOut;

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

@end

/////////////////////////////////////////////////////