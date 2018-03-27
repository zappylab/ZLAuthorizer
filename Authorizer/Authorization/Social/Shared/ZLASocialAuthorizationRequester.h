//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@class ZLNetworkRequestsPerformer;

/////////////////////////////////////////////////////

@interface ZLASocialAuthorizationRequester : NSObject

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer;

-(void) validateTwitterAccessToken:(NSString *) accessToken
                   forUserWithName:(NSString *) userName
                   completionBlock:(ZLARequestCompletionBlock) completionBlock;

-(NSURLSessionDataTask *) performLoginWithSocialNetworkIdentifier:(NSString *) socialNetworkKey
                                                   userIdentifier:(NSString *) userName
                                                      accessToken:(NSString *) accessToken
                                                        firstName:(NSString *) firstName
                                                         lastName:(NSString *) lastName
                                            profilePictureAddress:(NSString *) profilePictureAddress
                                                  completionBlock:(ZLARequestCompletionBlock) completionBlock;
@end

/////////////////////////////////////////////////////
