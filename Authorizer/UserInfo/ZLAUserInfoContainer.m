//
// Created by Ilya Dyakonov on 17/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAUserInfoContainer.h"

/////////////////////////////////////////////////////

@interface ZLAUserInfoContainer ()

@end

/////////////////////////////////////////////////////

@implementation ZLAUserInfoContainer

#pragma mark - Class methods

+(NSString *) firstNameOfFullName:(NSString *) fullName
{
    NSArray *userNames = [fullName componentsSeparatedByString:@" "];
    return [userNames firstObject];
}

+(NSString *) lastNameOfFullName:(NSString *) fullName
{
    NSArray *userNames = [fullName componentsSeparatedByString:@" "];
    NSString *lastName = nil;
    if (userNames.count > 1)
    {
        lastName = userNames[1];
    }

    return lastName;
}

#pragma mark - Initialization

-(instancetype) init
{
    self = [super init];
    if (self)
    {

    }

    return self;
}

#pragma mark - Helpers

-(NSString *) description
{
    return [NSString stringWithFormat:@"user identifier: %@\n"
                                              "full name:%@\nfirst name: %@, last name:%@\n"
                                              "affiliation: %@\n"
                                              " profile picture URL: %@",
                                      self.identifier,
                                      self.fullName,
                                      self.firstName,
                                      self.lastName,
                                      self.affiliation,
                                      self.profilePictureURL];
}

@end

/////////////////////////////////////////////////////