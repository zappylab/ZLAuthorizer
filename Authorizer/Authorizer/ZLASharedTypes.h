//
//  ZLASharedTypes.h
//  ZLAuthorizer
//
//  Created by Ilya Dyakonov on 28/04/14.
//  Copyright (c) 2014 ZappyLab. All rights reserved.
//

#ifndef AuthorizerExample_ZLASharedTypes_h
#define AuthorizerExample_ZLASharedTypes_h

#ifdef __OBJC__
#import <Foundation/Foundation.h>

typedef void(^ZLARequestCompletionBlock)(BOOL success,
        NSDictionary *response,
        NSError *error);

#endif /* __OBJC__ */

#endif /* AuthorizerExample_ZLASharedTypes_h */
