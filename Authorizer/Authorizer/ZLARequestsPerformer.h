//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface ZLARequestsPerformer : NSObject

@property (copy) NSString *userIdentifier;

-(instancetype) initWithBaseURL:(NSURL *) baseURL;

-(NSOperation *) POST:(NSString *) path
           parameters:(NSDictionary *) parameters
    completionHandler:(void (^)(BOOL success, NSDictionary *response, NSError *error)) completionHandler;

@end

/////////////////////////////////////////////////////