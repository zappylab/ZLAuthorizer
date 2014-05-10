//
// Created by Ilya Dyakonov on 08/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLAAutoAuthorizationPerformer.h"

#import "ZLNetworkReachabilityObserver.h"
#import "ZLAConcreteAuthorizer.h"


/////////////////////////////////////////////////////

static const int ZLAAutoAuthTimeBetweenAttemptsMultiplier = 2;
static NSTimeInterval const ZLAAutoAuthDefaultTimeBetweenAttempts = ZLAAutoAuthTimeBetweenAttemptsMultiplier;

/////////////////////////////////////////////////////

static const int ZLAAutoAuthMaxTimeBetweenAttempts = 120;

@interface ZLAAutoAuthorizationPerformer ()

@property (strong) id<ZLAConcreteAuthorizer> authorizer;
@property (strong) ZLNetworkReachabilityObserver *reachabilityObserver;

@property (strong) NSTimer *authorizationRetryTimer;
@property (readwrite) NSTimeInterval timeBetweenAuthorizationAttempts;

@property (copy) ZLARequestCompletionBlock completionBlock;

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

-(void) resetAuthorizationAttemptsTimer
{
    [self invalidateNextAttemptTimer];
    [self resetTimeBetweenAuthorizationAttempts];
}

-(void) invalidateNextAttemptTimer
{
    [self.authorizationRetryTimer invalidate];
    self.authorizationRetryTimer = nil;
}

-(void) resetTimeBetweenAuthorizationAttempts
{
    self.timeBetweenAuthorizationAttempts = ZLAAutoAuthDefaultTimeBetweenAttempts;
}

-(void) tryToAuthorize
{
    if (self.authorizer && !self.authorizationRetryTimer)
    {
        [self.authorizer loginWithExistingCredentialsWithCompletionBlock:^(BOOL success, NSDictionary *response, NSError *error)
        {
            if (success || !error) {
                // authorized successfully or
                // failed to authorize not because of network issues
                self.authorizer = nil;

                if (self.completionBlock) {
                    self.completionBlock(success, response, error);
                }

                self.completionBlock = nil;
            }
            else {
                // network issues, retry later
                [self startWaitingForNextAttempt];
            }
        }];
    }
}

-(void) startWaitingForNextAttempt
{
    self.authorizationRetryTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeBetweenAuthorizationAttempts
                                                                    target:self
                                                                  selector:@selector(makeAnotherAuthorizationAttempt)
                                                                  userInfo:nil
                                                                   repeats:NO];
    [self updateTimeBetweenAttempts];
}

-(void) makeAnotherAuthorizationAttempt
{
    [self invalidateNextAttemptTimer];
    [self tryToAuthorize];
}

-(void) updateTimeBetweenAttempts
{
    self.timeBetweenAuthorizationAttempts *= ZLAAutoAuthTimeBetweenAttemptsMultiplier;
    if (self.timeBetweenAuthorizationAttempts > ZLAAutoAuthMaxTimeBetweenAttempts) {
        self.timeBetweenAuthorizationAttempts = ZLAAutoAuthMaxTimeBetweenAttempts;
    }
}

#pragma mark - Auto auth

-(void) performAutoAuthorizationWithAuthorizer:(id <ZLAConcreteAuthorizer>) authorizer
                               completionBlock:(ZLARequestCompletionBlock) completionBlock
{
    [self resetAuthorizationAttemptsTimer];

    self.authorizer = authorizer;
    self.completionBlock = completionBlock;

    [self tryToAuthorize];
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