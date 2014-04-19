//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface ZLACredentialsStorage : NSObject

+(NSString *) userName;
+(void) setUserName:(NSString *) userName;

+(NSString *) password;
+(void) setPassword:(NSString *) password;

+(void) wipeOutExistingCredentials;

@end

/////////////////////////////////////////////////////