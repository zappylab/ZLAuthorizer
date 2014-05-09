//
// Created by Ilya Dyakonov on 09/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import "ZLAAuthorizer.h"

/////////////////////////////////////////////////////

SpecBegin(State)

__block ZLAAuthorizer *authorizer;

beforeEach(^{
    authorizer = [[ZLAAuthorizer alloc] initWithBaseURL:[NSURL URLWithString:@"http://dev.passageo.com/api/v1"]
                                          appIdentifier:@"2"];
});

//it(@"should be non signed in by default", ^{
//    expect(authorizer.signedIn).to.beFalsy();
//});

it(@"should should not perform any requests by default", ^{
    expect(authorizer.performingRequest).to.beFalsy();
});

SpecEnd

/////////////////////////////////////////////////////
