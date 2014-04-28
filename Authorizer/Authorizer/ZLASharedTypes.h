//
//  ZLASharedTypes.h
//  AuthorizerExample
//
//  Created by Ilya Dyakonov on 28/04/14.
//  Copyright (c) 2014 ZappyLab. All rights reserved.
//

#ifndef AuthorizerExample_ZLASharedTypes_h
#define AuthorizerExample_ZLASharedTypes_h

#ifdef __OBJC__
#import <Foundation/Foundation.h>

typedef void(^ZLASigninRequestCompletionBlock)(BOOL success, NSDictionary *response);

#endif /* __OBJC__ */

#endif /* AuthorizerExample_ZLASharedTypes_h */
