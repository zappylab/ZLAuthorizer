//
//  Created by Yulia Kurnosova on 25/09/15.
//  Copyright © 2015 ZappyLab. All rights reserved.
//

#import "NSString+ZLAUserNameParser.h"

/////////////////////////////////////////////////////

static NSString *const ZLAUserNameDelimiter = @" ";

/////////////////////////////////////////////////////

@implementation NSString (ZLAUserNameParser)

-(NSString *) zl_firstNameOfFullName
{
    NSRange whitespaceRange = [self rangeOfString:ZLAUserNameDelimiter];
    NSString *firstName;
    if (whitespaceRange.length > 0)
    {
        firstName = [self substringToIndex:whitespaceRange.location];
    }
    else
    {
        firstName = [self copy];
    }
    
    return firstName;
}

-(NSString *) zl_lastNameOfFullName
{
    NSRange whitespaceRange = [self rangeOfString:ZLAUserNameDelimiter];
    NSString *lastName;
    if (whitespaceRange.length > 0
        && whitespaceRange.location + 1 < self.length)
    {
        lastName = [self substringFromIndex:whitespaceRange.location + 1];
    }
    else
    {
        lastName = nil;
    }
    
    return lastName;
}

@end

/////////////////////////////////////////////////////