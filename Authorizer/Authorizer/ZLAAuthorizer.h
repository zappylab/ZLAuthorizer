//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

static NSString *ZLAAuthorizerPerformingRequestKeyPath = @"performingRequest";
static NSString *ZLAAuthorizerSignedInKeyPath = @"signedIn";

/////////////////////////////////////////////////////

@class ZLAUserInfoContainer;

/////////////////////////////////////////////////////

typedef void(^ZLAAuthorizationCompletionBlock)(BOOL success);

/////////////////////////////////////////////////////

@interface ZLAAuthorizer : NSObject

@property (readonly) ZLAUserInfoContainer *userInfo;
@property (readonly) BOOL signedIn;
@property (readonly) BOOL performingRequest;

-(instancetype) initWithBaseURL:(NSURL *) baseURL
                  appIdentifier:(NSString *) appIdentifier;

-(void) performNativeAuthorizationWithUserEmail:(NSString *) email
                                       password:(NSString *) password
                                completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) performTwitterAuthorizationWithAPIKey:(NSString *) APIKey
                                    APISecret:(NSString *) APISecret
                              completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) performFacebookAuthorizationWithCompletionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) performGooglePlusAuthorizationWithClientId:(NSString *) clientId
                                   completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) signOut;

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) updateAccountWithUserName:(NSString *) userName
                         password:(NSString *) password
                   additionalInfo:(NSDictionary *) info
                  completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

@end

/////////////////////////////////////////////////////