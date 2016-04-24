//
//  AB_PassthroughView.m
//  Eastern
//
//  Created by phoebe on 7/2/15.
//

#import "AB_PassthroughView.h"
#import "Underscore.h"

@implementation AB_PassthroughView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isPointInside = Underscore.array(self.subviews)
    .filter(^BOOL(UIView* subview)
            {
                return subview.isUserInteractionEnabled && !subview.hidden;
            })
    .any(^BOOL(UIView* subview)
         {
             CGPoint pointInView = [subview convertPoint:point fromView:self];
             return [subview pointInside:pointInView withEvent:event];
         });
    
    return isPointInside
    ? [super pointInside:point withEvent:event]
    : NO;
}

@end

@implementation AB_PassthroughTableView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
//    NSMutableArray* touchableViews = [[self visibleCells] mutableCopy];
//
//    [touchableViews addObjectsFromArray:
//    Underscore.array(self.subviews)
//    .filter(^(UIView* view)
//            {
//                return [view isKindOfClass:[UITableViewHeaderFooterView class]];
//            })
//     .unwrap];
//
//    BOOL isPointInside = Underscore.array([NSArray arrayWithArray:touchableViews])
//    .map(^NSArray*(UIView* subview)
//         {
//             if ([subview isKindOfClass:[UITableViewCell class]])
//             {
//                 return ((UITableViewCell*)subview).contentView.subviews;
//             }
//
//             return @[subview];
//         })
//    .flatten
//    .filter(^BOOL(UIView* subview)
//            {
//                return subview.isUserInteractionEnabled;
//            })
//    .any(^BOOL(UIView* subview)
//         {
//             CGPoint pointInView = [subview convertPoint:point fromView:self];
//             return [subview pointInside:pointInView withEvent:event];
//         });

    NSMutableArray* allViews = [
                                Underscore.array(self.visibleCells)
                                .map(^(UITableViewCell* c)
                                     {
                                         return c.contentView.subviews;
                                     })
                                .flatten
                                .unwrap
                                mutableCopy];
    
    
    for (int i=0; i<[self numberOfSections]; i++)
    {
        UIView* v = [self headerViewForSection:i];
        if (v)
        {
            [allViews addObjectsFromArray:v.subviews];
        }
        
        v = [self footerViewForSection:i];
        if (v)
        {
            [allViews addObjectsFromArray:v.subviews];
        }
    }
    
    BOOL isPointInside = Underscore.array(allViews)
    .filter(^BOOL(UIView* subview)
            {
                return subview.isUserInteractionEnabled && !subview.hidden;
            })
    .any(^BOOL(UIView* subview)
         {
             CGPoint pointInView = [subview convertPoint:point fromView:self];
             BOOL pointInside = [subview pointInside:pointInView withEvent:event];
                        
             return pointInside;
         });

    return isPointInside
    ? [super pointInside:point withEvent:event]
    : NO;
}

@end

@implementation AB_PassthroughTableViewCell

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isPointInside = Underscore.array(self.contentView.subviews)
    .filter(^BOOL(UIView* subview)
            {
                return subview.isUserInteractionEnabled && !subview.hidden;
            })
    .any(^BOOL(UIView* subview)
         {
             CGPoint pointInView = [subview convertPoint:point fromView:self];
             return [subview pointInside:pointInView withEvent:event];
         });
    
    return isPointInside
    ? [super pointInside:point withEvent:event]
    : NO;
}

@end
