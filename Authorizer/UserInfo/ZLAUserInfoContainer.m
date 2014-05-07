//
// Created by Ilya Dyakonov on 17/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAUserInfoContainer.h"

#import "ZLACredentialsStorage.h"

/////////////////////////////////////////////////////

static NSString *const ZLAUserInfoIdentifierKey = @"identifier";
static NSString *const ZLAUserInfoFullNameKey = @"fullName";
static NSString *const ZLAUserInfoFirstNameKey = @"firstName";
static NSString *const ZLAUserInfoLastNameKey = @"lastName";
static NSString *const ZLAUserInfoAffiliationKey = @"affiliation";
static NSString *const ZLAUserInfoProfilePictureURLKey = @"profilePictureURL";

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
    self = [self initWithCoder:nil];
    if (self) {

    }

    return self;
}

//
// designated initializer
//

-(id) initWithCoder:(NSCoder *) coder
{
    self = [super init];
    if (self) {
        [self unarchiveWithCoder:coder];
    }

    return self;
}

-(void) unarchiveWithCoder:(NSCoder *) coder
{
    _identifier = [coder decodeObjectForKey:ZLAUserInfoIdentifierKey];
    _fullName = [coder decodeObjectForKey:ZLAUserInfoFullNameKey];
    _firstName = [coder decodeObjectForKey:ZLAUserInfoFirstNameKey];
    _lastName = [coder decodeObjectForKey:ZLAUserInfoLastNameKey];
    _affiliation = [coder decodeObjectForKey:ZLAUserInfoAffiliationKey];
    _profilePictureURL = [coder decodeObjectForKey:ZLAUserInfoProfilePictureURLKey];
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

#pragma mark - Accessors

-(NSString *) email
{
    return [ZLACredentialsStorage userEmail];
}

-(void) setEmail:(NSString *) email
{
    [ZLACredentialsStorage setUserEmail:email];
}

-(NSString *) password
{
    return [ZLACredentialsStorage password];
}

-(void) setPassword:(NSString *) password
{
    [ZLACredentialsStorage setPassword:password];
}

#pragma mark - NSCoding encoding

-(void) encodeWithCoder:(NSCoder *) coder
{
    [coder encodeObject:_identifier
                 forKey:ZLAUserInfoIdentifierKey];
    [coder encodeObject:_fullName
                 forKey:ZLAUserInfoFullNameKey];
    [coder encodeObject:_firstName
                 forKey:ZLAUserInfoFirstNameKey];
    [coder encodeObject:_lastName
                 forKey:ZLAUserInfoLastNameKey];
    [coder encodeObject:_affiliation
                 forKey:ZLAUserInfoAffiliationKey];
    [coder encodeObject:_profilePictureURL
                 forKey:ZLAUserInfoProfilePictureURLKey];
}

@end

/////////////////////////////////////////////////////