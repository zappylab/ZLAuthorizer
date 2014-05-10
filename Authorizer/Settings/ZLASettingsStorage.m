//
// Created by Ilya Dyakonov on 10/05/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import "ZLASettingsStorage.h"

/////////////////////////////////////////////////////

static NSString *const ZLASettingsRanAlreadyKey = @"ZLARanAlready";

/////////////////////////////////////////////////////

@interface ZLASettingsStorage ()
{
    BOOL _firstRun;
}

@end

/////////////////////////////////////////////////////

@implementation ZLASettingsStorage

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
    [self determineIfThisRunIsFirst];
}

-(void) determineIfThisRunIsFirst
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:ZLASettingsRanAlreadyKey] boolValue]) {
        _firstRun = NO;
    }
    else {
        _firstRun = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@(YES)
                                                  forKey:ZLASettingsRanAlreadyKey];
    }
}

#pragma mark - Settings access

-(BOOL) firstRun
{
    return _firstRun;
}

@end

/////////////////////////////////////////////////////