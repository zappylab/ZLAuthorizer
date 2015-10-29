//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

static NSString *const ZLAAuthorizerPerformingRequestKeyPath = @"performingRequest";
static NSString *const ZLAAuthorizerSignedInKeyPath = @"signedIn";
static NSString *const ZLAAuthorizerUserDataSynchTimestampKeyPath = @"userDataSynchTimestamp";

/////////////////////////////////////////////////////

@class ZLAUserInfoContainer;

/////////////////////////////////////////////////////

typedef void(^ZLAAuthorizationCompletionBlock)(BOOL success);

/////////////////////////////////////////////////////

@interface ZLAAuthorizer : NSObject

@property (readonly) ZLAUserInfoContainer *userInfo;
@property (readonly) BOOL signedIn;
@property (readonly) BOOL performingRequest;
@property (readonly) NSDate *userDataSynchTimestamp;

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

-(void) registerUserWithEmail:(NSString *) email
                     password:(NSString *) password
              completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) updateAccountWithUserName:(NSString *) userName
                         password:(NSString *) password
                   additionalInfo:(NSDictionary *) info
                         silently:(BOOL) silently
                  completionBlock:(ZLAAuthorizationCompletionBlock) completionBlock;

-(void) handleUpdatingUserInfoWithSerializedInfo:(NSDictionary *) serializedInfo
                                    withResponse:(NSDictionary *) response;

-(void) updateUserDataSynchTimestamp;

@end

/////////////////////////////////////////////////////