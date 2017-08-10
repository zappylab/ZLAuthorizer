//
// Created by Ilya Dyakonov on 17/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import "ZLAUserInfoContainer.h"

#import "ZLACredentialsStorage.h"
#import "ZLAConstants.h"

/////////////////////////////////////////////////////

@interface ZLAUserInfoContainer ()
{
    __strong NSString *_password;
    __strong NSString *_email;
    __strong NSString *_identifier;
    __strong NSDate *_userDataSynchTimestamp;
    
}

@property (strong, readwrite) NSString *identifier;

@end

/////////////////////////////////////////////////////

@implementation ZLAUserInfoContainer
@synthesize affiliationURL = _affiliationURL;
@synthesize profilePictureURL = _profilePictureURL;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize username = _username;
@synthesize bio = _bio;

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
        [self setup];
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
        [self setup];
        [self unarchiveWithCoder:coder];
    }

    return self;
}

-(void) setup
{
    [ZLACredentialsStorage migrateUserDataIfNeeded];
}

-(void) unarchiveWithCoder:(NSCoder *) coder
{
    self.persistent = YES;
    _fullName = [coder decodeObjectForKey:ZLAUserInfoFullNameKey];
    _firstName = [coder decodeObjectForKey:ZLAUserInfoFirstNameKey];
    _lastName = [coder decodeObjectForKey:ZLAUserInfoLastNameKey];
    _username = [coder decodeObjectForKey:ZLAUsernameKey];
    _affiliation = [coder decodeObjectForKey:ZLAUserInfoAffiliationKey];
    _affiliationURL = [coder decodeObjectForKey:ZLAUserInfoAffiliationURLKey];
    _profilePictureURL = [coder decodeObjectForKey:ZLAUserInfoProfilePictureURLKey];
    _bio = [coder decodeObjectForKey:ZLAUserInfoBioKey];
    _userDataSynchTimestamp = [coder decodeObjectForKey:ZLUserInfoDataSynchTimestampKeyPath];
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

-(NSDate *) userDataSynchTimestamp
{
    return self.persistent ? [ZLACredentialsStorage userDataSynchTimestamp] : _userDataSynchTimestamp;
}

-(void) setUserDataSynchTimestamp:(NSDate *) userDataSynchTimestamp
{
    if (self.persistent)
    {
        [ZLACredentialsStorage setUserDataSynchTimestamp:userDataSynchTimestamp];
    }
    else
    {
        _userDataSynchTimestamp = userDataSynchTimestamp;
    }
}

-(void) setAffiliationURL:(NSURL *) affiliationURL
{
    if ([affiliationURL isKindOfClass:[NSString class]])
    {
        _affiliationURL = [NSURL URLWithString:(NSString *)affiliationURL];
    }
    else
    {
        _affiliationURL = affiliationURL;
    }
}

-(NSURL *) affiliationURL
{
    return _affiliationURL;
}

-(void) setProfilePictureURL:(NSURL *) profilePictureURL
{
    if ([profilePictureURL isKindOfClass:[NSString class]])
    {
        _profilePictureURL = [NSURL URLWithString:(NSString *)profilePictureURL];
    }
    else
    {
        _profilePictureURL = profilePictureURL;
    }
}

-(NSURL *) profilePictureURL
{
    return _profilePictureURL;
}

-(void) setFirstName:(NSString *) firstName
{
    _firstName = firstName;
    [self updateFullName];
}

-(NSString *) firstName
{
    return _firstName;
}

-(void) setLastName:(NSString *) lastName
{
    _lastName = lastName;
    [self updateFullName];
}

-(NSString *) lastName
{
    return _lastName;
}

-(void) updateFullName
{
    self.fullName = [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
}

#pragma mark -

-(void) setIdentifier:(NSString *) identifier
withCompletionHandler:(void (^)(void)) completionHandler
{
    self.identifier = identifier;
    if (completionHandler)
    {
        completionHandler();
    }
}

-(void) handleUserInfoData:(NSDictionary *) data
{
    NSString *fullUserName = [self stringValueOfKey:ZLAFullUserNameKey
                                       ofDictionary:data];
    if (fullUserName.length > 0)
    {
        self.fullName = fullUserName;
    }
    else
    {
        self.fullName = [ZLACredentialsStorage userEmail];
    }

    self.firstName = [self stringValueOfKey:ZLAFirstNameKey
                               ofDictionary:data];
    self.lastName = [self stringValueOfKey:ZLALastNameKey
                              ofDictionary:data];
    self.affiliation = [self stringValueOfKey:ZLAUserAffiliationKey
                                 ofDictionary:data];
    self.bio = [self stringValueOfKey:ZLAUserBioKey
                         ofDictionary:data];
    self.username = [self stringValueOfKey:ZLAUsernameKey
                              ofDictionary:data];
    
    NSString *affiliationURL = [self stringValueOfKey:ZLAUserAffiliationURLKey
                                         ofDictionary:data];
    if (affiliationURL.length > 0)
    {
        self.affiliationURL = [NSURL URLWithString:affiliationURL];
    }
    else
    {
        self.affiliationURL = nil;
    }
    
    NSString *profilePicture = [self stringValueOfKey:ZLAProfilePictureKey
                                         ofDictionary:data];
    if (profilePicture.length > 0)
    {
        self.profilePictureURL = [NSURL URLWithString:profilePicture];
    }
    else
    {
        self.profilePictureURL = nil;
    }
}

-(NSString *) stringValueOfKey:(NSString *) key
                  ofDictionary:(NSDictionary *) dictionary
{
    NSString *value = @"";
    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        if (dictionary[key])
        {
            id valueOfUnknownType = dictionary[key];
            if ([valueOfUnknownType isKindOfClass:[NSString class]])
            {
                value = (NSString *) valueOfUnknownType;
            }
            else if ([valueOfUnknownType isKindOfClass:[NSNumber class]])
            {
                value = [valueOfUnknownType stringValue];
            }
        }
    }
    
    return value;
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
    newContainer.userDataSynchTimestamp = container.userDataSynchTimestamp;
    [newContainer setIdentifier:container.identifier
          withCompletionHandler:nil];

    return newContainer;
}

-(void) reset
{
    self.identifier = nil;
    self.fullName = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.username = nil;
    self.affiliation = nil;
    self.profilePictureURL = nil;
    self.userDataSynchTimestamp = nil;
    self.bio = nil;
    self.affiliationURL = nil;
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
    [coder encodeObject:_affiliationURL
                 forKey:ZLAUserInfoAffiliationURLKey];
    [coder encodeObject:_profilePictureURL
                 forKey:ZLAUserInfoProfilePictureURLKey];
    [coder encodeObject:_userDataSynchTimestamp
                 forKey:ZLUserInfoDataSynchTimestampKeyPath];
    [coder encodeObject:_bio
                 forKey:ZLAUserInfoBioKey];
    [coder encodeObject:_username
                 forKey:ZLAUsernameKey];
}

@end

/////////////////////////////////////////////////////
