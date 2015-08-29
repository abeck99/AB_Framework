//
//  AB_PassthroughView.m
//  Eastern
//
//  Created by phoebe on 7/2/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_PassthroughView.h"
#import "Underscore.h"

@implementation AB_PassthroughView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isPointInside = Underscore.array(self.subviews)
    .filter(^BOOL(UIView* subview)
            {
                return subview.isUserInteractionEnabled;
            })
    .any(^BOOL(UIView* subview)
         {
             CGPoint pointInView = [subview convertPoint:point fromView:self];
             return [subview pointInside:pointInView withEvent:event];
         });
    
    return isPointInside;
}

@end

@implementation AB_PassthroughTableView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    NSMutableArray* touchableViews = [[self visibleCells] mutableCopy];

    [touchableViews addObjectsFromArray:
    Underscore.array(self.subviews)
    .filter(^(UIView* view)
            {
                return [view isKindOfClass:[UITableViewHeaderFooterView class]];
            })
     .unwrap];

    BOOL isPointInside = Underscore.array([NSArray arrayWithArray:touchableViews])
    .map(^NSArray*(UIView* subview)
         {
             if ([subview isKindOfClass:[UITableViewCell class]])
             {
                 return ((UITableViewCell*)subview).contentView.subviews;
             }

             return @[subview];
         })
    .flatten
    .filter(^BOOL(UIView* subview)
            {
                return subview.isUserInteractionEnabled;
            })
    .any(^BOOL(UIView* subview)
         {
             CGPoint pointInView = [subview convertPoint:point fromView:self];
             return [subview pointInside:pointInView withEvent:event];
         });
    
    return isPointInside;
}

@end

@implementation AB_PassthroughTableViewCell

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isPointInside = Underscore.array(self.contentView.subviews)
    .filter(^BOOL(UIView* subview)
            {
                return subview.isUserInteractionEnabled;
            })
    .any(^BOOL(UIView* subview)
         {
             CGPoint pointInView = [subview convertPoint:point fromView:self];
             return [subview pointInside:pointInView withEvent:event];
         });
    
    return isPointInside;
}

@end
