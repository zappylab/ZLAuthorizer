//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "ZLAGooglePlusAuthorizationRequester.h"
#import "ZLNetworkRequestsPerformer.h"

/////////////////////////////////////////////////////

@interface ZLAGooglePlusAuthorizationRequester ()

@end

/////////////////////////////////////////////////////

@implementation ZLAGooglePlusAuthorizationRequester

#pragma mark - Initialization

-(instancetype) initWithRequestsPerformer:(ZLNetworkRequestsPerformer *) requestsPerformer
{
    self = [super initWithRequestsPerformer:requestsPerformer];
    if (self)
    {

    }

    return self;
}

-(void) getProfilePictureAddressForUserWithIdentifier:(NSString *) userIdentifier
                                  withCompletionBlock:(void (^)(NSString *profilePictureAddress)) completionBlock
{
    NSParameterAssert(userIdentifier);

    NSURL *profilePictureRequestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://picasaweb.google.com/data/entry/api/user/%@?alt=json",
                                                                                         userIdentifier]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:profilePictureRequestURL.absoluteString
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask *task, id responseObject)
    {
        NSString *profilePictureAddress = [self getGooglePlusProfilePictureFromJSON:responseObject];
        if (completionBlock) {
            completionBlock(profilePictureAddress);
        }
    }
         failure:^(NSURLSessionTask *operation, NSError *error)
    {
        if (completionBlock)
        {
            completionBlock(nil);
        }
    }];
}

-(NSString *) getGooglePlusProfilePictureFromJSON:(id) responseObject
{
    return responseObject[@"entry"][@"gphoto$thumbnail"][@"$t"];
}

@end

/////////////////////////////////////////////////////
