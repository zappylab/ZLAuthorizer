//
// Created by Ilya Dyakonov on 24/04/14.
// Copyright (c) 2014 ZappyLab. All rights reserved.
//
//


#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////

@class ACAccount;

/////////////////////////////////////////////////////

@interface ZLATwitterAccountsAccessor : NSObject

-(void) askUserToChooseAccountWithCompletionBlock:(void (^)(ACAccount *account)) completionBlock;

@end

/////////////////////////////////////////////////////