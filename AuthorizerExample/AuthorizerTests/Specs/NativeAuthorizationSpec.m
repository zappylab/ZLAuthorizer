//
// Created by Ilya Dyakonov on 09/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import "ZLAAuthorizer.h"
#import "ZLAConstants.h"

#import "ZLAUserInfoContainer.h"

/////////////////////////////////////////////////////

SpecBegin(NativeAuthorization)

__block ZLAAuthorizer *authorizer;

beforeEach(^{
    authorizer = [[ZLAAuthorizer alloc] initWithBaseURL:[NSURL URLWithString:@"http://dev.passageo.com/api/v1"]
                                          appIdentifier:@"2"];
});

afterEach(^{
    [OHHTTPStubs removeAllStubs];
});

it(@"should not save email and password if failed to authorize", ^AsyncBlock{
    NSString *response = [NSString stringWithFormat:@"{\"%@\":\"not authorized\"}", ZLAResponseStatusKey];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
    {
        return [[request.URL lastPathComponent] isEqualToString:ZLALoginRequestPath];
    }
                        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
                        {
                            return [OHHTTPStubsResponse responseWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                                                              statusCode:200
                                                                 headers:@{@"Content-Type":@"text/json"}];
                        }];
    [authorizer performNativeAuthorizationWithUserEmail:@"test@test.com"
                                               password:@"password"
                                        completionBlock:^(BOOL success)
                                        {
                                            expect(success).to.beFalsy();
                                            expect(authorizer.userInfo.email).to.beNil();
                                            expect(authorizer.userInfo.password).to.beNil();
                                            done();
                                        }];
});

it(@"should save email and password if authorized", ^AsyncBlock{
    NSString *response = [NSString stringWithFormat:@"{\"%@\":\"%@\"}", ZLAResponseStatusKey, ZLAResponseStatusOK];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
    {
        return [[request.URL lastPathComponent] isEqualToString:ZLALoginRequestPath];
    }
                        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
                        {
                            return [OHHTTPStubsResponse responseWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                                                              statusCode:200
                                                                 headers:@{@"Content-Type":@"text/json"}];
                        }];
    NSString *email = @"test@test.com";
    NSString *password = @"password";
    [authorizer performNativeAuthorizationWithUserEmail:email
                                               password:password
                                        completionBlock:^(BOOL success)
                                        {
                                            expect(success).to.beTruthy();
                                            expect(authorizer.userInfo.email).to.equal(email);
                                            expect(authorizer.userInfo.password).to.equal(password);
                                            done();
                                        }];
});

SpecEnd

/////////////////////////////////////////////////////