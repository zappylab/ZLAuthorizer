//
// Created by Ilya Dyakonov on 18/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLASignedTwitterRequest.h"

#import "OAuthCore.h"

/////////////////////////////////////////////////////

static NSTimeInterval const kZLATwitterRequestTimeout = 5;

/////////////////////////////////////////////////////

static NSString *const kZLATwitterAuthorizationRequestHeader = @"Authorization";

@interface ZLASignedTwitterRequest ()

@end

/////////////////////////////////////////////////////

@implementation ZLASignedTwitterRequest

#pragma mark - Initialization

-(id) initWithURL:(NSURL *) URL
       parameters:(NSDictionary *) parameters
      consumerKey:(NSString *) APIKey
   consumerSecret:(NSString *) APISecret
           method:(NSString *) method
      accessToken:(NSString *) accessToken
     accessSecret:(NSString *) accessSecret
{
    self = [super initWithURL:URL
                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
              timeoutInterval:kZLATwitterRequestTimeout];
    if (self)
    {
        [self setupWithParameters:parameters
                           APIKey:APIKey
                        APISecret:APISecret
                           method:method
                      accessToken:accessToken
                     accessSecret:accessSecret];
    }

    return self;
}

-(void) setupWithParameters:(NSDictionary *) parameters
                     APIKey:(NSString *) APIKey
                  APISecret:(NSString *) APISecret
                     method:(NSString *) method
                accessToken:(NSString *) accessToken
               accessSecret:(NSString *) accessSecret
{
    self.HTTPMethod = method;

    NSString *paramString = [self paramStringWithParameters:parameters];
    NSData *bodyData = [self setBodyWithString:paramString];
    [self setAuthorizationHeaderWithData:bodyData
                                  APIKey:APIKey
                               APISecret:APISecret
                             accessToken:accessToken
                            accessSecret:accessSecret];
}

-(NSString *) paramStringWithParameters:(NSDictionary *) parameters
{
    //  Build our parameter string
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [parameters enumerateKeysAndObjectsUsingBlock:
                        ^(id key, id obj, BOOL *stop)
                        {
                            [paramsAsString appendFormat:@"%@=%@&",
                                                         key,
                                                         obj];
                        }];
    return paramsAsString;
}

-(void) setAuthorizationHeaderWithData:(NSData *) bodyData
                                APIKey:(NSString *) APIKey
                             APISecret:(NSString *) APISecret
                           accessToken:(NSString *) accessToken
                          accessSecret:(NSString *) accessSecret
{
    NSString *authorizationHeader = OAuthorizationHeader(self.URL,
                                                         self.HTTPMethod,
                                                         bodyData,
                                                         APIKey,
                                                         APISecret,
                                                         accessToken,
                                                         accessSecret);
    [self setValue:authorizationHeader
forHTTPHeaderField:kZLATwitterAuthorizationRequestHeader];
}

-(NSData *) setBodyWithString:(NSString *) paramString
{
    NSData *bodyData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    self.HTTPBody = bodyData;
    return bodyData;
}

@end

/////////////////////////////////////////////////////