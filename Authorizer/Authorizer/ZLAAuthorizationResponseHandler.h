//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@protocol ZLAAuthorizationResponseHandlerDelegate

-(void) responseHandlerDidDetectSocialLoginWithNetwork:(NSString *) socialNetworkName;

@end

/////////////////////////////////////////////////////

@class ZLAUserInfoContainer;

/////////////////////////////////////////////////////

@interface ZLAAuthorizationResponseHandler : NSObject

@property (weak) id<ZLAAuthorizationResponseHandlerDelegate> delegate;

@property (strong) ZLAUserInfoContainer *userInfoContainer;

-(instancetype) initWithUserInfoContainer:(ZLAUserInfoContainer *) userInfoContainer;

-(void) handleLoginResponse:(NSDictionary *) response;
-(NSError *) errorFromResponse:(NSDictionary *) response;

@end

/////////////////////////////////////////////////////