//
// Created by Ilya Dyakonov on 17/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@interface ZLAUserInfoContainer : NSObject <NSCoding>

+(NSString *) firstNameOfFullName:(NSString *) fullName;
+(NSString *) lastNameOfFullName:(NSString *) fullName;

//
// using id instead of instancetype because this method may return
// any of ZLAUserInfoContainer's children
//
+(id) containerWithContainer:(ZLAUserInfoContainer *) container
                  persistent:(BOOL) persistent;

// turned on by default
@property (readwrite) BOOL persistent;

-(void) setIdentifier:(NSString *) identifier
withCompletionHandler:(void (^)(void)) completionHandler;

@property (strong, readonly) NSString *identifier;

@property (strong) NSString *fullName;
@property (strong) NSString *firstName;
@property (strong) NSString *lastName;
@property (strong) NSString *affiliation;
@property (strong) NSURL *profilePictureURL;

@property (strong) NSString *email;
@property (strong) NSString *password;

-(void) handleUserInfoData:(NSDictionary *) data;

-(void) reset;

@end

/////////////////////////////////////////////////////