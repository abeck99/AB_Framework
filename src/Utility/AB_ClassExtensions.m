//
//  AB_ClassExtensions.m
//  GoHeroClient
//
//  Created by phoebe on 15/1/9.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import "AB_ClassExtensions.h"

@implementation UIColor (TwoFiveFiveExtension)

+ (UIColor*) colorWith255Red:(int)red green:(int)green blue:(int)blue alpha:(CGFloat) alpha
{
    return [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:alpha];
}

@end

@implementation NSArray (SafeAccessExtension)

- (id) objectAtIndexOrNil:(NSUInteger)index
{
    if ( index < self.count )
    {
        return [self objectAtIndex:index];
    }
    
    return nil;
}

@end
