//
// Created by Ilya Dyakonov on 05/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface CredentialsStorage : NSObject

+(instancetype) sharedInstance;

@property (strong) NSString *userName;
@property (strong) NSString *password;

-(void) wipeOutExistingCredentials;

@end

/////////////////////////////////////////////////////