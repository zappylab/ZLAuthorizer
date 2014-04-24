//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ZLAUserInfoContainer;

/////////////////////////////////////////////////////

@interface ZLAAuthorizationResponseHandler : NSObject

@property (strong) ZLAUserInfoContainer *userInfoContainer;

-(instancetype) initWithUserInfoContainer:(ZLAUserInfoContainer *) userInfoContainer;

-(void) handleLoginResponse:(NSDictionary *) response;
-(void) handleTwitterAccessTokenValidationResponse:(NSDictionary *) response;

@end

/////////////////////////////////////////////////////