//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

#import "ZLASocialAuthorizationRequester.h"

/////////////////////////////////////////////////////

@interface ZLAGooglePlusAuthorizationRequester : ZLASocialAuthorizationRequester

-(void) getProfilePictureAddressForUserWithIdentifier:(NSString *) userIdentifier
                                  withCompletionBlock:(void (^)(NSString *profilePictureAddress)) completionBlock;

@end

/////////////////////////////////////////////////////