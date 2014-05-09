//
// Created by Ilya Dyakonov on 01/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import <ZLNetworkRequestsPerformer/ZLNetworkRequestsPerformer.h>

#import "ZLAAccountInfoUpdater.h"

/////////////////////////////////////////////////////

static NSString *const ZLAAccountInfoUpdateRequestPath = @"msaveuserinfo";

/////////////////////////////////////////////////////

@interface ZLAAccountInfoUpdater ()

@property (readonly) ZLNetworkRequestsPerformer *requestsPerformer;

@end

/////////////////////////////////////////////////////

@implementation ZLAAccountInfoUpdater

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
        _requestsPerformer = requestsPerformer;
    }

    return self;
}

#pragma mark - Requests

-(void) updateAccountWithInfo:(NSDictionary *) accountInfo
              completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    NSParameterAssert(accountInfo);

    [self.requestsPerformer POST:ZLAAccountInfoUpdateRequestPath
                      parameters:accountInfo
               completionHandler:completionBlock];
}

@end

/////////////////////////////////////////////////////