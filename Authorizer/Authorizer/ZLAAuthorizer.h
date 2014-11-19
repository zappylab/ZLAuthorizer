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

extern NSString *const ZLAErrorMessageKey;
extern NSString *const ZLAErrorDataValidationDomain;
extern NSString *const ZLAErrorServersideDomain;

/////////////////////////////////////////////////////

typedef void(^ZLAAuthorizationCompletionBlock)(BOOL success, NSError *error);

/////////////////////////////////////////////////////

@interface ZLAAuthorizer : NSObject

@property (readonly, nonatomic) ZLAUserInfoContainer *userInfo;
@property (readonly, atomic) BOOL signedIn;
@property (readonly, nonatomic) BOOL performingRequest;

-(BOOL) handleOpenURL:(NSURL *) url;
-(BOOL) handleOpenURL:(NSURL *) url
  sourceApplication:(NSString *) sourceApplication
         annotation:(id) annotation;

-(instancetype) init __attribute__((unavailable));

-(instancetype) initWithBaseURL:(NSURL *) baseURL
                  appIdentifier:(NSString *) appIdentifier
         userInfoContainerClass:(Class) userInfoContainerClass;

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
                         silently:(BOOL) silently
                  completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) resetPasswordForUserWithEmail:(NSString *) email
                      completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

@end

/////////////////////////////////////////////////////