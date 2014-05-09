//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@protocol ZLAAuthorizationResponseHandlerDelegate

-(void) responseHandlerDidDetectSocialLoginWithNetwork:(NSString *) socialNetworkName;
-(void) responseHandlerDidDetectErrorMessage:(NSString *) message;

@end

/////////////////////////////////////////////////////

@class ZLAUserInfoContainer;

/////////////////////////////////////////////////////

@interface ZLAAuthorizationResponseHandler : NSObject

@property (weak) id<ZLAAuthorizationResponseHandlerDelegate> delegate;

@property (strong) ZLAUserInfoContainer *userInfoContainer;

-(instancetype) initWithUserInfoContainer:(ZLAUserInfoContainer *) userInfoContainer;

-(void) handleLoginResponse:(NSDictionary *) response;
-(void) handleRegistrationResponse:(NSDictionary *) response;

@end

/////////////////////////////////////////////////////