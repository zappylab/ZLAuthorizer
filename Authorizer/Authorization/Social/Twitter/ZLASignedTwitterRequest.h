//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

/////////////////////////////////////////////////////

@interface ZLASignedTwitterRequest : NSMutableURLRequest

-(id) initWithURL:(NSURL *) URL
       parameters:(NSDictionary *) parameters
      consumerKey:(NSString *) APIKey
   consumerSecret:(NSString *) APISecret
           method:(NSString *) method
      accessToken:(NSString *) accessToken
     accessSecret:(NSString *) accessSecret;

@end

/////////////////////////////////////////////////////