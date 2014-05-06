//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

#import "ZLAGooglePlusAuthorizer.h"
#import "ZLAGooglePlusAuthorizationRequester.h"

#import "ZLADefinitions.h"
#import "ZLARequestsPerformer.h"
#import "ZLACredentialsStorage.h"

/////////////////////////////////////////////////////

@interface ZLAGooglePlusAuthorizer () <GPPSignInDelegate>

@property (strong) ZLAGooglePlusAuthorizationRequester *requester;

@property (copy) void(^completionBlock)(BOOL success, NSDictionary *response);

@property (strong) NSString *accessToken;
@property (strong) NSString *userIdentifier;
@property (strong) NSString *email;
@property (strong) NSString *firstName;
@property (strong) NSString *lastName;
@property (strong) NSString *profilePictureAddress;

@end

/////////////////////////////////////////////////////

@implementation ZLAGooglePlusAuthorizer

#pragma mark - Initialization

-(instancetype) init
{
    @throw [NSException exceptionWithName:@""
                                   reason:@""
                                 userInfo:nil];
}

-(instancetype) initWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer
{
    self = [super init];
    if (self)
    {
        [self setupWithRequestsPerformer:requestsPerformer];
    }

    return self;
}

-(void) setupWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer
{
    [self setupRequesterWithRequestsPerformer:requestsPerformer];
    [self setupGoogleSignIn];
}

-(void) setupRequesterWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer
{
    _requester = [[ZLAGooglePlusAuthorizationRequester alloc] initWithRequestsPerformer:requestsPerformer];
}

-(void) setupGoogleSignIn
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.scopes = @[ @"profile" ];
    signIn.delegate = self;
}

#pragma mark - Authorization

-(void) performAuthorizationWithClientId:(NSString *) clientId
                         completionBlock:(void(^)(BOOL success, NSDictionary *response)) completionBlock
{
    NSParameterAssert(clientId);

    self.completionBlock = completionBlock;
    [GPPSignIn sharedInstance].clientID = clientId;
    [[GPPSignIn sharedInstance] authenticate];
}

-(void) signOut
{
    [[GPPSignIn sharedInstance] signOut];
}

#pragma mark - GPPSignInDelegate methods

-(void) finishedWithAuth:(GTMOAuth2Authentication *) auth
                   error:(NSError *) error
{
    if (auth)
    {
        self.accessToken = auth.accessToken;
        self.email = [GPPSignIn sharedInstance].authentication.userEmail;

        [self getUserInfoAndLogin];

    }
    else
    {
        [self executeCompletionBlockWithSuccess:NO
                                       response:nil];
    }
}

-(void) executeCompletionBlockWithSuccess:(BOOL) success
                                 response:(NSDictionary *) response
{
    if (self.completionBlock) {
        self.completionBlock(success, response);
    }

    self.completionBlock = nil;
}

-(void) getUserInfoAndLogin
{
    GTLServicePlus *plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];

    plusService.apiVersion = @"v1";
    [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket, GTLPlusPerson *person, NSError *error)
                {
                    if (person)
                    {
                        [self saveUserInfoFromPerson:person];
                        [self.requester getProfilePictureAddressForUserWithIdentifier:self.userIdentifier
                                                                  withCompletionBlock:^(NSString *profilePictureAddress)
                                                                  {
                                                                      self.profilePictureAddress = profilePictureAddress;
                                                                      [self loginWithGooglePlusCredentials];
                                                                  }];
                    }
                    else
                    {
                        [self executeCompletionBlockWithSuccess:NO
                                                       response:nil];
                    }
                }];
}

-(void) saveUserInfoFromPerson:(GTLPlusPerson *) person
{
    self.userIdentifier = person.identifier;
    self.firstName = person.name.givenName;
    self.lastName = person.name.familyName;
}

-(void) loginWithGooglePlusCredentials
{
    [ZLACredentialsStorage setUserEmail:self.email];

    [self.requester performLoginWithSocialNetworkIdentifier:kZLASocialNetworkGooglePlus
                                             userIdentifier:self.userIdentifier
                                                accessToken:self.accessToken
                                                  firstName:self.firstName
                                                   lastName:self.lastName
                                      profilePictureAddress:self.profilePictureAddress
                                            completionBlock:^(BOOL success, NSDictionary *response)
                                            {
                                                [self executeCompletionBlockWithSuccess:success
                                                                               response:response];
                                            }];
}

@end

/////////////////////////////////////////////////////