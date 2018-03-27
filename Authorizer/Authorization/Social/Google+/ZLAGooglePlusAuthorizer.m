//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import <GoogleSignIn/GoogleSignIn.h>

#import "ZLAGooglePlusAuthorizer.h"
#import "ZLAGooglePlusAuthorizationRequester.h"

#import "ZLNetworkRequestsPerformer.h"
#import "ZLACredentialsStorage.h"
#import "ZLAConstants.h"

#import "NSString+ZLAUserNameParser.h"

/////////////////////////////////////////////////////

@interface ZLAGooglePlusAuthorizer ()
         <
         GIDSignInDelegate
         >

@property (strong) ZLAGooglePlusAuthorizationRequester *requester;
@property (strong) NSURLSessionDataTask *loginRequestOperation;

@property (copy) ZLARequestCompletionBlock completionBlock;

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

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    self = [super init];
    if (self)
    {
        [self setupWithRequestsPerformer:requestsPerformer];
    }

    return self;
}

-(void) setupWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    [self setupRequesterWithRequestsPerformer:requestsPerformer];
    [self setupGoogleSignIn];
}

-(void) setupRequesterWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    _requester = [[ZLAGooglePlusAuthorizationRequester alloc] initWithRequestsPerformer:requestsPerformer];
}

-(void) setupGoogleSignIn
{
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.shouldFetchBasicProfile = YES;
    signIn.delegate = self;
    signIn.scopes = @[@"https://www.googleapis.com/auth/plus.login"];
    signIn.delegate = self;
}

#pragma mark - Authorization

-(void) performAuthorizationWithClientId:(NSString *) clientId
                         completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    NSParameterAssert(clientId);

    self.completionBlock = completionBlock;
    [GIDSignIn sharedInstance].clientID = clientId;
    [[GIDSignIn sharedInstance] signIn];
}

#pragma mark - GIDSignInDelegate methods


-(void)   signIn:(GIDSignIn *) signIn
didSignInForUser:(GIDGoogleUser *) user
       withError:(NSError *) error
{
    if (error == nil)
    {
        self.userIdentifier = user.userID;
        self.accessToken = user.authentication.idToken;
        self.email = user.profile.email;
        
        NSString *name = user.profile.name;
        self.firstName = [name zl_firstNameOfFullName];
        self.lastName = [name zl_lastNameOfFullName];
        
        [self getUserInfoAndLogin];
    }
    else
    {
        [self executeCompletionBlockWithSuccess:NO
                                       response:nil];
    }
}

-(void)        signIn:(GIDSignIn *) signIn
didDisconnectWithUser:(GIDGoogleUser *) user
            withError:(NSError *) error
{
    [[GIDSignIn sharedInstance] signOut];
}

-(void) executeCompletionBlockWithSuccess:(BOOL) success
                                 response:(NSDictionary *) response
{
    if (self.completionBlock)
    {
        self.completionBlock(success, response, nil);
    }

    self.completionBlock = nil;
}

-(void) getUserInfoAndLogin
{
    [self.requester getProfilePictureAddressForUserWithIdentifier:self.userIdentifier
                                              withCompletionBlock:^(NSString *profilePictureAddress)
     {
         self.profilePictureAddress = profilePictureAddress;
         [self loginWithGooglePlusCredentials];
     }];
}

-(void) loginWithGooglePlusCredentials
{
    [ZLACredentialsStorage setUserEmail:self.email];
    [ZLACredentialsStorage setSocialUserIdentifier:self.userIdentifier];
    [ZLACredentialsStorage setSocialAccessToken:self.accessToken];

    [self performLoginWithFirstName:self.firstName
                           lastName:self.lastName
              profilePictureAddress:self.profilePictureAddress];
}

-(void) performLoginWithFirstName:(NSString *) firstName
                         lastName:(NSString *) lastName
            profilePictureAddress:(NSString *) profilePictureAddress
{
    self.loginRequestOperation = [self.requester performLoginWithSocialNetworkIdentifier:ZLASocialNetworkGooglePlus
                                                                          userIdentifier:[ZLACredentialsStorage socialUserIdentifier]
                                                                             accessToken:[ZLACredentialsStorage socialAccessToken]
                                                                               firstName:firstName
                                                                                lastName:lastName
                                                                   profilePictureAddress:profilePictureAddress
                                                                         completionBlock:^(BOOL success, NSDictionary *response, NSError *error)
                                                                         {
                                                                             self.loginRequestOperation = nil;

                                                                             if (self.completionBlock)
                                                                             {
                                                                                 self.completionBlock(success, response, error);
                                                                             }

                                                                             self.completionBlock = nil;
                                                                         }];
}

-(void) loginWithExistingCredentialsWithCompletionBlock:(ZLARequestCompletionBlock) completionBlock
{
    [self performLoginWithFirstName:@""
                           lastName:@""
              profilePictureAddress:@""];
}

-(void) stopLoggingInWithExistingCredentials
{
    [self.loginRequestOperation cancel];
    self.loginRequestOperation = nil;
}

-(void) signOut
{
    [[GIDSignIn sharedInstance] signOut];
}

@end

/////////////////////////////////////////////////////
