//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface ZLATwitterAuthorizer : NSObject

@property (strong) NSString *consumerKey;
@property (strong) NSString *consumerSecret;
@property (strong) NSString *accessToken;
@property (strong) NSString *accessTokenSecret;

@property (strong) NSString *twitterUserName;
@property (strong) NSString *fullUserName;
@property (strong) NSString *profilePictureAddress;

-(void) performReverseAuthorizationWithCompletionBlock:(void (^)(BOOL success)) completionBlock;

@end

/////////////////////////////////////////////////////