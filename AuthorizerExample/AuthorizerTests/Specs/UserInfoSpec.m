//
// Created by Ilya Dyakonov on 09/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//

#import "ZLAAuthorizer.h"
#import "ZLAUserInfoContainer.h"

/////////////////////////////////////////////////////

SpecBegin(UserInfo)

__block ZLAAuthorizer *authorizer;

beforeEach(^{
    authorizer = [[ZLAAuthorizer alloc] initWithBaseURL:[NSURL URLWithString:@"http://dev.passageo.com/api/v1"]
                                          appIdentifier:@"2"
                                 userInfoContainerClass:NULL];
});

it(@"should have user identifier", ^{
    expect(authorizer.userInfo.identifier).notTo.beNil();
});

it(@"should generate valid user identifiers", ^{
    expect(authorizer.userInfo.identifier.length).to.equal(32);
});

it(@"should recreate user identifier", ^{
    NSString *userIdentifier = authorizer.userInfo.identifier;
    [authorizer signOut];
    expect(authorizer.userInfo.identifier).notTo.beNil();
    expect(userIdentifier).notTo.equal(authorizer.userInfo.identifier);
});

SpecEnd

/////////////////////////////////////////////////////
