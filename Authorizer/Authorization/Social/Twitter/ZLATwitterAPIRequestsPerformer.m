//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <AFNetworking/AFNetworking.h>

#import "ZLATwitterAPIRequestsPerformer.h"
#import "ZLASignedTwitterRequest.h"

/////////////////////////////////////////////////////

@interface ZLATwitterAPIRequestsPerformer ()

@property (strong) AFHTTPSessionManager *requestSessionManager;

@end

/////////////////////////////////////////////////////

@implementation ZLATwitterAPIRequestsPerformer

#pragma mark - Initialization

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }

    return self;
}

-(void) setup
{
    self.requestSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com"]];
    self.requestSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

#pragma mark - Requests

-(void) performReverseAuthWithAccount:(ACAccount *) account
                          consumerKey:(NSString *) consumerKey
                       consumerSecret:(NSString *) consumerSecret
                    completionHandler:(void (^)(NSData *data, NSError *error)) completionHandler
{
    NSParameterAssert(account);
    NSParameterAssert(consumerKey);
    NSParameterAssert(consumerSecret);

    [self getRequestTokenWithConsumerKey:consumerKey
                          consumerSecret:consumerSecret
                       completionHandler:^(NSData *data, NSError *error)
                       {
                           if (data)
                           {
                               NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data
                                                                                            encoding:NSUTF8StringEncoding];
                               [self getAccessTokenForAccount:account
                                                    signature:signedReverseAuthSignature
                                                  consumerKey:consumerKey
                                            completionHandler:^(NSData *accessTokenResponseData, NSError *accessTokenRequestError)
                                            {
                                                if (completionHandler)
                                                {
                                                    completionHandler(accessTokenResponseData, accessTokenRequestError);
                                                }
                                            }];
                           }
                           else
                           {
                               if (completionHandler)
                               {
                                   completionHandler(nil, error);
                               }
                           }
                       }];
}

-(void) getRequestTokenWithConsumerKey:(NSString *) consumerKey
                        consumerSecret:(NSString *) consumerSecret
                     completionHandler:(void (^)(NSData *data, NSError *error)) completionHandler
{
    ZLASignedTwitterRequest *request = [[ZLASignedTwitterRequest alloc] initWithURL:[self URLForRequestWithRelativePath:@"oauth/request_token"]
                                                                         parameters:@{@"x_auth_mode" : @"reverse_auth"}
                                                                        consumerKey:consumerKey
                                                                     consumerSecret:consumerSecret
                                                                             method:@"POST"
                                                                        accessToken:nil
                                                                       accessSecret:nil];
    
//    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//    {
//        if (completionHandler)
//        {
//            completionHandler(responseObject, nil);
//        }
//    }
//                                            failure:^(AFHTTPRequestOperation *operation, NSError *error)
//                                            {
//                                                if (completionHandler)
//                                                {
//                                                    completionHandler(nil, error);
//                                                }
//                                            }];
//
//    [self.requestSessionManager.operationQueue addOperation:requestOperation];
}

-(NSURL *) URLForRequestWithRelativePath:(NSString *) requestPath
{
    return [NSURL URLWithString:requestPath
                  relativeToURL:self.requestSessionManager.baseURL];
}

-(void) getAccessTokenForAccount:(ACAccount *) account
                       signature:(NSString *) signedReverseAuthSignature
                     consumerKey:(NSString *) consumerKey
               completionHandler:(void (^)(NSData *data, NSError *error)) completionHandler
{
    NSParameterAssert(account);
    NSParameterAssert(signedReverseAuthSignature);
    NSParameterAssert(consumerKey);

    NSDictionary *accessTokenRequestParameters = @{@"x_reverse_auth_target"     : consumerKey,
                                                   @"x_reverse_auth_parameters" : signedReverseAuthSignature};
    SLRequest *tokenRequest = [self requestWithUrl:[self URLForRequestWithRelativePath:@"/oauth/access_token"]
                                        parameters:accessTokenRequestParameters
                                     requestMethod:SLRequestMethodPOST];
    tokenRequest.account = account;
    [tokenRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            if (completionHandler)
            {
                completionHandler(responseData, error);
            }
        });
    }];
}

-(SLRequest *) requestWithUrl:(NSURL *) URL
                   parameters:(NSDictionary *) parameters
                requestMethod:(SLRequestMethod) requestMethod
{
    NSParameterAssert(URL);
    NSParameterAssert(parameters);

    return [SLRequest requestForServiceType:SLServiceTypeTwitter
                              requestMethod:requestMethod
                                        URL:URL
                                 parameters:parameters];
}

-(void) verifyCredentialsWithConsumerKey:(NSString *) consumerKey
                          consumerSecret:(NSString *) consumerSecret
                               accessKey:(NSString *) accessKey
                            accessSecret:(NSString *) accessSecret
                       completionHandler:(void(^)(NSDictionary *response, NSError *error)) completionHandler
{
    NSParameterAssert(consumerKey);
    NSParameterAssert(consumerSecret);
    NSParameterAssert(accessKey);
    NSParameterAssert(accessSecret);

    ZLASignedTwitterRequest *request = [[ZLASignedTwitterRequest alloc] initWithURL:[self URLForRequestWithRelativePath:@"1.1/account/verify_credentials.json"]
                                                                         parameters:nil
                                                                        consumerKey:consumerKey
                                                                     consumerSecret:consumerSecret
                                                                             method:@"GET"
                                                                        accessToken:accessKey
                                                                       accessSecret:accessSecret];
//    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//    {
//        if (completionHandler) {
//            NSError *responseSerializationError = nil;
//            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject
//                                                                     options:kNilOptions
//                                                                       error:&responseSerializationError];
//            completionHandler(response, responseSerializationError);
//        }
//    }
//                                            failure:^(AFHTTPRequestOperation *operation, NSError *error)
//                                            {
//                                                if (completionHandler) {
//                                                    completionHandler(nil, error);
//                                                }
//                                            }];
//
//    [self.requestSessionManager.operationQueue addOperation:requestOperation];
}

@end

/////////////////////////////////////////////////////
