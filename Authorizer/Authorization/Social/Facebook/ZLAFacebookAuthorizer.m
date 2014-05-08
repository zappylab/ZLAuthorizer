//
// Created by Ilya Dyakonov on 05/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import "FacebookSDK.h"

#import "ZLAFacebookAuthorizer.h"
#import "ZLASocialAuthorizationRequester.h"
#import "ZLACredentialsStorage.h"

#import "ZLAConstants.h"
#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@interface ZLAFacebookAuthorizer () <FBLoginViewDelegate>

@property (strong) ZLASocialAuthorizationRequester *requester;
@property (strong) FBLoginView *loginView;
@property (strong) NSOperation *loginRequestOperation;

@property (copy) void(^completionBlock)(BOOL success, NSDictionary *response);

@end

/////////////////////////////////////////////////////

@implementation ZLAFacebookAuthorizer

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
    [self setupLoginView];
}

-(void) setupRequesterWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    _requester = [[ZLASocialAuthorizationRequester alloc] initWithRequestsPerformer:requestsPerformer];
}

-(void) setupLoginView
{
    self.loginView = [[FBLoginView alloc] init];
    self.loginView.delegate = self;
}

#pragma mark - Authorization

-(void) performAuthorizationWithCompletionBlock:(void (^)(BOOL success, NSDictionary *response)) completionBlock
{
    self.completionBlock = completionBlock;

    if (!(FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended))
    {
        FBSession *session = [[FBSession alloc] init];
        [session setStateChangeHandler:^(FBSession *changedSession, FBSessionState status, NSError *error)
        {
            [self sessionStateChanged:changedSession
                                state:status
                                error:error];
        }];

        [FBSession setActiveSession:session];
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
                                              ^(FBSession *openedSession, FBSessionState state, NSError *error)
                                              {
                                                  [self sessionStateChanged:openedSession
                                                                      state:state
                                                                      error:error];
                                              }];
    }
}

-(void) sessionStateChanged:(FBSession *) session
                      state:(FBSessionState) state
                      error:(NSError *) error
{
    switch (state)
    {
        case FBSessionStateOpen:
            break;

        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;

        default:
            break;
    }
}

-(void) loginWithExistingCredentialsWithCompletionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock
{
    self.completionBlock = completionBlock;
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
    [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark - FBLoginViewDelegate methods

-(void) loginViewFetchedUserInfo:(FBLoginView *) loginView
                            user:(id <FBGraphUser>) user
{
    [ZLACredentialsStorage setUserEmail:user[@"email"]];
    [ZLACredentialsStorage setSocialAccessToken:FBSession.activeSession.accessTokenData.accessToken];
    [ZLACredentialsStorage setSocialUserIdentifier:user.id];

    [self performLoginWithFirstName:user[@"first_name"]
                           lastName:user[@"last_name"]
              profilePictureAddress:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",
                                     user.id]];

}

-(void) performLoginWithFirstName:(NSString *) firstName
                         lastName:(NSString *) lastName
            profilePictureAddress:(NSString *) profilePictureAddress
{
    self.loginRequestOperation = [self.requester performLoginWithSocialNetworkIdentifier:ZLASocialNetworkFacebook
                                                                          userIdentifier:[ZLACredentialsStorage socialUserIdentifier]
                                                                             accessToken:[ZLACredentialsStorage socialAccessToken]
                                                                               firstName:firstName
                                                                                lastName:lastName
                                                                   profilePictureAddress:profilePictureAddress
                                                                         completionBlock:^(BOOL success, NSDictionary *response)
                                                                         {
                                                                             self.loginRequestOperation = nil;

                                                                             if (self.completionBlock)
                                                                             {
                                                                                 self.completionBlock(success, response);
                                                                             }

                                                                             self.completionBlock = nil;
                                                                         }];
}
@end

/////////////////////////////////////////////////////