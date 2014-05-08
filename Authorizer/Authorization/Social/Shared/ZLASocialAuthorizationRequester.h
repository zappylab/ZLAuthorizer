//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ZLNetworkRequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLASocialAuthorizationRequester : NSObject

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer;

-(void) validateTwitterAccessToken:(NSString *) accessToken
                   forUserWithName:(NSString *) userName
                   completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;

-(NSOperation *) performLoginWithSocialNetworkIdentifier:(NSString *) socialNetworkKey
                                          userIdentifier:(NSString *) userName
                                             accessToken:(NSString *) accessToken
                                               firstName:(NSString *) firstName
                                                lastName:(NSString *) lastName
                                   profilePictureAddress:(NSString *) profilePictureAddress
                                         completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;
@end

/////////////////////////////////////////////////////