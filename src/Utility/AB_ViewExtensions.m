//
//  AB_ViewExtensions.m
//  Eastern
//
//  Created by phoebe on 7/8/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ViewExtensions.h"

@implementation UIView(AB_ViewExtensions)

- (void) removeAllSubviews
{
    for(UIView* view in [self.subviews copy])
    {
        [view removeFromSuperview];
    }
}

@end
