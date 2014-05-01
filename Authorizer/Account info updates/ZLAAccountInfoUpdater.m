//
// Created by Ilya Dyakonov on 01/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAAccountInfoUpdater.h"
#import "ZLARequestsPerformer.h"

/////////////////////////////////////////////////////

static NSString *const ZLAAccountInfoUpdateRequestPath = @"msaveuserinfo";

/////////////////////////////////////////////////////

@interface ZLAAccountInfoUpdater ()

@property (readonly) ZLARequestsPerformer *requestsPerformer;

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

-(instancetype) initWithRequestsPerformer:(ZLARequestsPerformer *) requestsPerformer
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
              completionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock
{
    NSParameterAssert(accountInfo);

    [self.requestsPerformer POST:ZLAAccountInfoUpdateRequestPath
                      parameters:accountInfo
               completionHandler:^(BOOL success, NSDictionary *response, NSError *error)
               {
                   if (completionBlock)
                   {
                       completionBlock(success, response);
                   }
               }];
}

@end

/////////////////////////////////////////////////////