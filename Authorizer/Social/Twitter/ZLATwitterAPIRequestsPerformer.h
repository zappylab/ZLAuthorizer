//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ACAccount;

/////////////////////////////////////////////////////

@interface ZLATwitterAPIRequestsPerformer : NSObject

-(void) performReverseAuthWithAccount:(ACAccount *) account
                          consumerKey:(NSString *) consumerKey
                       consumerSecret:(NSString *) consumerSecret
                    completionHandler:(void (^)(NSData *data, NSError *error)) completionHandler;

-(void) verifyCredentialsWithConsumerKey:(NSString *) consumerKey
                          consumerSecret:(NSString *) consumerSecret
                               accessKey:(NSString *) accessKey
                            accessSecret:(NSString *) accessSecret
                       completionHandler:(void (^)(NSDictionary *response, NSError *error)) completionHandler;

@end

/////////////////////////////////////////////////////