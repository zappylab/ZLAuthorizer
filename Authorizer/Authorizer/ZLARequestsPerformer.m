//
// Created by Ilya Dyakonov on 10/03/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import <AFNetworking/AFNetworking.h>

#import "ZLARequestsPerformer.h"
#import "ZLADefinitions.h"
#import "ZLACredentialsStorage.h"

/////////////////////////////////////////////////////

@interface ZLARequestsPerformer ()

@property (strong) AFHTTPRequestOperationManager *requestOperationManager;

@end

/////////////////////////////////////////////////////

@implementation ZLARequestsPerformer

#pragma mark - Initialization

-(instancetype) initWithBaseURL:(NSURL *) baseURL
{
    self = [super init];
    if (self)
    {
        [self setupWithBaseURL:baseURL];
    }

    return self;
}

-(void) setupWithBaseURL:(NSURL *) baseURL
{
    self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
}

#pragma mark - Login

-(NSOperation *) POST:(NSString *) path
           parameters:(NSDictionary *) parameters
    completionHandler:(void (^)(BOOL success, NSDictionary *response, NSError *error)) completionHandler
{
    NSAssert(self.userIdentifier, @"unable to perform authorization requests without user identifier");

    return [self.requestOperationManager POST:path
                                   parameters:[self completeParameters:parameters]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject)
                                      {
                                          if ([self isResponseOK:responseObject])
                                          {
                                              if (completionHandler)
                                              {
                                                  completionHandler(YES, responseObject, nil);
                                              }
                                          }
                                          else
                                          {
                                              if (completionHandler)
                                              {
                                                  completionHandler(NO, responseObject, nil);
                                              }
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                      {
                                          if (completionHandler)
                                          {
                                              completionHandler(NO, nil, error);
                                          }
                                      }];
}

-(NSDictionary *) completeParameters:(NSDictionary *) parameters
{
    NSMutableDictionary *mutableParameters = [parameters mutableCopy];
    mutableParameters[kZLAUserIdentifierKey] = self.userIdentifier;
    return mutableParameters;
}

-(BOOL) isResponseOK:(NSDictionary *) response
{
    BOOL responseOK = NO;

    NSString *responseStatus = response[kZLAResponseStatusKey];
    if ([responseStatus isEqualToString:kZLAResponseStatusOK])
    {
        responseOK = YES;
    }

    return responseOK;
}

@end

/////////////////////////////////////////////////////