//
// Created by Ilya Dyakonov on 06/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import <AFNetworking/AFNetworking.h>

#import "ZLAGooglePlusAuthorizationRequester.h"

/////////////////////////////////////////////////////

@interface ZLAGooglePlusAuthorizationRequester ()

@end

/////////////////////////////////////////////////////

@implementation ZLAGooglePlusAuthorizationRequester

#pragma mark - Initialization

-(instancetype) initWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer
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
    NSURLRequest *request = [NSURLRequest requestWithURL:profilePictureRequestURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *requestOperation, id responseObject)
    {
        NSString *profilePictureAddress = [self getGooglePlusProfilePictureFromJSON:responseObject];
        if (completionBlock) {
            completionBlock(profilePictureAddress);
        }
    }
                                     failure:^(AFHTTPRequestOperation *requestOperation, NSError *error)
                                     {
                                         if (completionBlock) {
                                             completionBlock(nil);
                                         }
                                     }
    ];

    [operation start];
}

-(NSString *) getGooglePlusProfilePictureFromJSON:(id) responseObject
{
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    return response[@"entry"][@"gphoto$thumbnail"][@"$t"];
}

@end

/////////////////////////////////////////////////////