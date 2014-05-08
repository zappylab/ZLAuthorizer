//
// Created by Ilya Dyakonov on 08/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAAutoAuthorizationPerformer.h"

#import "ZLNetworkReachabilityObserver.h"
#import "ZLAConcreteAuthorizer.h"


/////////////////////////////////////////////////////

static NSTimeInterval const ZLAAutoAuthDefaultTimeBetweenAttempts = 2;

/////////////////////////////////////////////////////

@interface ZLAAutoAuthorizationPerformer ()

@property (strong) id<ZLAConcreteAuthorizer> authorizer;
@property (strong) ZLNetworkReachabilityObserver *reachabilityObserver;

@property (strong) NSTimer *authorizationRetryTimer;
@property (readwrite) NSTimeInterval timeBetweenAuthorizationAttempts;

@property (copy) ZLAAuthorizationRequestCompletionBlock completionBlock;

@end

/////////////////////////////////////////////////////

@implementation ZLAAutoAuthorizationPerformer

#pragma mark - Initialization

-(instancetype) init
{
    @throw [NSException exceptionWithName:@""
                                   reason:@""
                                 userInfo:nil];
}

-(instancetype) initWithReachabilityObserver:(ZLNetworkReachabilityObserver *) observer
{
    self = [super init];
    if (self) {
        [self setupWithReachabilityObserver:observer];
    }

    return self;
}

-(void) setupWithReachabilityObserver:(ZLNetworkReachabilityObserver *) observer
{
    _reachabilityObserver = observer;
    _timeBetweenAuthorizationAttempts = ZLAAutoAuthDefaultTimeBetweenAttempts;

    [self subscribeForReachabilityNotifications];
}

-(void) subscribeForReachabilityNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkReachabilityStatus)
                                                 name:ZLNNetworkReachabilityStatusChangeNotification
                                               object:self.reachabilityObserver];
}

-(void) checkReachabilityStatus
{
    if (self.reachabilityObserver.networkReachable) {
        [self tryToAuthorize];
    }
    else {
        [self resetAuthorizationAttemptsTimer];
    }
}

-(void) tryToAuthorize
{
    if (self.authorizer && !self.authorizationRetryTimer)
    {
        [self.authorizer loginWithExistingCredentialsWithCompletionBlock:^(BOOL success, NSDictionary *response)
        {
            if (success) {
                self.authorizer = nil;

                if (self.completionBlock) {
                    self.completionBlock(success, response);
                }

                self.completionBlock = nil;
            }
        }];
    }
}

-(void) resetAuthorizationAttemptsTimer
{
    [self stopWaitingForNextAuthorizationAttempt];
    [self resetTimeBetweenAuthorizationAttempts];
}

-(void) stopWaitingForNextAuthorizationAttempt
{
    [self.authorizationRetryTimer invalidate];
    self.authorizationRetryTimer = nil;
}

-(void) resetTimeBetweenAuthorizationAttempts
{
    self.timeBetweenAuthorizationAttempts = ZLAAutoAuthDefaultTimeBetweenAttempts;
}

#pragma mark - Auto auth

-(void) performAutoAuthorizationWithAuthorizer:(id <ZLAConcreteAuthorizer>) authorizer
                               completionBlock:(ZLAAuthorizationRequestCompletionBlock) completionBlock
{
    [self resetAuthorizationAttemptsTimer];

    self.authorizer = authorizer;
    self.completionBlock = completionBlock;

    if (self.reachabilityObserver.networkReachable) {
        [self tryToAuthorize];
    }
}

-(void) stopAutoAuthorization
{
    [self resetAuthorizationAttemptsTimer];

    [self.authorizer stopLoggingInWithExistingCredentials];
    self.authorizer = nil;
    self.completionBlock = nil;
}

@end

/////////////////////////////////////////////////////