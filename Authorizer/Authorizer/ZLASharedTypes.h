//
//  ZLASharedTypes.h
//  ZLAuthorizer
//
//  Created by Ilya Dyakonov on 28/04/14.
//  Copyright (c) 2014 ZappyLab. All rights reserved.
//

#pragma once

#ifdef __OBJC__

#import <Foundation/Foundation.h>

typedef void(^ZLARequestCompletionBlock)(BOOL success,
        NSDictionary *response,
        NSError *error);

extern NSString *const ZLAErrorDomain;
extern NSInteger const ZLAErrorCodeInvalidEmail;
extern NSString *const ZLAErrorMessageKey;

#endif /* __OBJC__ */
