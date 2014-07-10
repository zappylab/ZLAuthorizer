//
// Created by Ilya Dyakonov on 17/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAUserInfoContainer.h"

#import "ZLACredentialsStorage.h"
#import "ZLAConstants.h"

/////////////////////////////////////////////////////

static NSString *const ZLAUserInfoIdentifierKey = @"identifier";
static NSString *const ZLAUserInfoFullNameKey = @"fullName";
static NSString *const ZLAUserInfoFirstNameKey = @"firstName";
static NSString *const ZLAUserInfoLastNameKey = @"lastName";
static NSString *const ZLAUserInfoAffiliationKey = @"affiliation";
static NSString *const ZLAUserInfoProfilePictureURLKey = @"profilePictureURL";

/////////////////////////////////////////////////////

@interface ZLAUserInfoContainer ()
{
    __strong NSString *_password;
    __strong NSString *_email;
    __strong NSString *_identifier;
}

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
    if (self)
    {

    }

    return self;
}

//
// designated initializer
//

-(id) initWithCoder:(NSCoder *) coder
{
    self = [super init];
    if (self)
    {
        [self unarchiveWithCoder:coder];
    }

    return self;
}

-(void) unarchiveWithCoder:(NSCoder *) coder
{
    self.persistent = YES;
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
    return self.persistent ? [ZLACredentialsStorage userEmail] : _email;
}

-(void) setEmail:(NSString *) email
{
    if (self.persistent)
    {
        [ZLACredentialsStorage setUserEmail:email];
    }
    else
    {
        _email = email;
    }
}

-(NSString *) password
{
    return self.persistent ? [ZLACredentialsStorage password] : _password;
}

-(void) setPassword:(NSString *) password
{
    if (self.persistent)
    {
        [ZLACredentialsStorage setPassword:password];
    }
    else
    {
        _password = password;
    }
}

-(NSString *) identifier
{
    return self.persistent ? [ZLACredentialsStorage userIdentifier] : _identifier;
}

-(void) setIdentifier:(NSString *) identifier
{
    if (self.persistent)
    {
        [ZLACredentialsStorage setUserIdentifier:identifier];
    }
    else
    {
        _identifier = identifier;
    }
}

#pragma mark -

-(void) handleUserInfoData:(NSDictionary *) data
{
    NSString *fullUserName = data[ZLAFullUserNameKey];
    if (fullUserName.length > 0)
    {
        self.fullName = fullUserName;
    }
    else
    {
        self.fullName = [ZLACredentialsStorage userEmail];
    }

    self.firstName = data[ZLAFirstNameKey];
    self.lastName = data[ZLALastNameKey];
    self.affiliation = data[ZLAUserAffiliationKey];

    NSString *profilePicture = data[ZLAProfilePictureKey];
    if (profilePicture.length > 0)
    {
        self.profilePictureURL = [NSURL URLWithString:profilePicture];
    }
    else
    {
        self.profilePictureURL = nil;
    }
}

+(id) containerWithContainer:(ZLAUserInfoContainer *) container
                  persistent:(BOOL) persistent
{
    // subclasses have no need to override this method
    // unless you decide not to save any critical piece of state with encodeWithCoder:,
    // like this class does with email, identifier and password (look a few lines below)
    //
    NSData *archivedSourceContainer = [NSKeyedArchiver archivedDataWithRootObject:container];
    ZLAUserInfoContainer *newContainer = [NSKeyedUnarchiver unarchiveObjectWithData:archivedSourceContainer];

    // user email, identifier and password are not transferred through encodeWithCoder:
    newContainer.persistent = persistent;
    newContainer.email = container.email;
    newContainer.password = container.password;
    newContainer.identifier = container.identifier;

    return newContainer;
}

-(void) reset
{
    self.identifier = nil;
    self.fullName = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.affiliation = nil;
    self.profilePictureURL = nil;
}

#pragma mark - NSCoding encoding

-(void) encodeWithCoder:(NSCoder *) coder
{
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