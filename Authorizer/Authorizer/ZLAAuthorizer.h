//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface ZLAAuthorizer : NSObject

-(void) setBaseURL:(NSURL *) baseURL;

-(void) performStartupAuthorization;
-(void) performNativeAuthorizationWithCompletionBlock:(void (^)(BOOL success)) completionBlock;

-(void) performTwitterAuthorizationWithAPIKey:(NSString *) APIKey
                                    APISecret:(NSString *) APISecret
                              completionBlock:(void (^)(BOOL success)) completionBlock;

@end

/////////////////////////////////////////////////////