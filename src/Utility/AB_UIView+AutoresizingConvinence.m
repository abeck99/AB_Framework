//
//  AB_UIView+AutoresizingConvinence.m
//  Eastern
//
//  Created by phoebe on 7/4/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_UIView+AutoresizingConvinence.h"

@implementation UIView(AutoresizingConvinence)

- (BOOL) hasFlexibleLeftMargin
{
    return (self.autoresizingMask & UIViewAutoresizingFlexibleLeftMargin) == UIViewAutoresizingFlexibleLeftMargin;
}

- (BOOL) hasFlexibleWidth
{
    return (self.autoresizingMask & UIViewAutoresizingFlexibleWidth) == UIViewAutoresizingFlexibleWidth;
}

- (BOOL) hasFlexibleRightMargin
{
    return (self.autoresizingMask & UIViewAutoresizingFlexibleRightMargin) == UIViewAutoresizingFlexibleRightMargin;
}

- (BOOL) hasFlexibleTopMargin
{
    return (self.autoresizingMask & UIViewAutoresizingFlexibleTopMargin) == UIViewAutoresizingFlexibleTopMargin;
}

- (BOOL) hasFlexibleHeight
{
    return (self.autoresizingMask & UIViewAutoresizingFlexibleHeight) == UIViewAutoresizingFlexibleHeight;
}

- (BOOL) hasFlexibleBottomMargin
{
    return (self.autoresizingMask & UIViewAutoresizingFlexibleBottomMargin) == UIViewAutoresizingFlexibleBottomMargin;
}

@end

