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

-(void) performNativeLoginWithUserName:(NSString *) userName
                              password:(NSString *) password
                       completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;

-(void) validateTwitterAccessToken:(NSString *) accessToken
                   forUserWithName:(NSString *) userName
                   completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;

-(void) performLoginWithTwitterUserName:(NSString *) userName
                            accessToken:(NSString *) accessToken
                              firstName:(NSString *) firstName
                               lastName:(NSString *) lastName
                  profilePictureAddress:(NSString *) profilePictureAddress
                        completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;

-(void) registerUserWithFullName:(NSString *) fullName
                           email:(NSString *) email
                        password:(NSString *) password
                 completionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock;
@end

/////////////////////////////////////////////////////