//
// Created by Ilya Dyakonov on 05/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "ZLAFacebookAuthorizer.h"
#import "ZLASocialAuthorizationRequester.h"
#import "ZLACredentialsStorage.h"

#import "ZLAConstants.h"
#import "ZLASharedTypes.h"

/////////////////////////////////////////////////////

@interface ZLAFacebookAuthorizer () <FBSDKLoginTooltipViewDelegate>

@property (strong) ZLASocialAuthorizationRequester *requester;
@property (strong) FBSDKLoginManager *loginManager;
@property (strong) NSURLSessionDataTask *loginRequestOperation;

@property (copy) ZLARequestCompletionBlock completionBlock;

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
    self.loginManager = [[FBSDKLoginManager alloc] init];
}

-(void) setupRequesterWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    _requester = [[ZLASocialAuthorizationRequester alloc] initWithRequestsPerformer:requestsPerformer];
}

#pragma mark - Authorization

-(void) performAuthorizationFrom:(UIViewController *) viewController
             withCompletionBlock:(ZLARequestCompletionBlock) completionBlock
{
    self.completionBlock = completionBlock;
    [self.loginManager logInWithReadPermissions: @[@"public_profile", @"email"]
                             fromViewController:viewController
                                        handler:^(FBSDKLoginManagerLoginResult *result,
                                                  NSError *error)
     {
         if (error || result.isCancelled)
         {
             [self.loginManager logOut];
         }
         else
         {
             [self updateCredentials];
         }
     }];
}

-(void) updateCredentials
{
    id token = [FBSDKAccessToken currentAccessToken];
    if (token != nil)
    {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                       parameters:@{@"fields": @"id, first_name, last_name, email"}];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error)
         {
             if (error == nil)
             {
                 [ZLACredentialsStorage setUserEmail:result[@"email"]];
                 [ZLACredentialsStorage setSocialAccessToken:token];
                 [ZLACredentialsStorage setSocialUserIdentifier:result[@"id"]];
                 [self performLoginWithFirstName:result[@"first_name"]
                                        lastName:result[@"last_name"]
                           profilePictureAddress:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",
                                                  result[@"id"]]];
             }
             else
             {
                 self.completionBlock(NO, result, error);
             }
         }];
    }
}

-(void) loginWithExistingCredentialsWithCompletionBlock:(ZLARequestCompletionBlock) completionBlock
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
    [self.loginManager logOut];
}

#pragma mark - FBLoginViewDelegate methods

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

@end

/////////////////////////////////////////////////////
