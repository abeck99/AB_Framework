//
//  AB_Funcs.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_Funcs.h"

void printAllSubviews(UIView* view, int depth)
{
    NSString* tabs = @"";
    for ( int i=0; i<depth; i++ )
    {
        tabs = [NSString stringWithFormat:@"\t%@", tabs];
    }
    
    NSLog(@"%@%@", tabs, view);
    
    for ( UIView* subview in view.subviews )
    {
        printAllSubviews(subview, depth+1);
    }
}

void AdjustViewToHeight(UIView* root, UIView* viewToAdjust, CGFloat height)
{
    CGFloat dif = height - viewToAdjust.frame.size.height;
    RecursivelyAdjustView(root, viewToAdjust, dif);
}

void RecursivelyAdjustView(UIView* root, UIView* viewToAdjust, CGFloat dif)
{
    CGRect f = viewToAdjust.frame;
    f.size.height += dif;
    
    UIViewAutoresizing mask = viewToAdjust.autoresizingMask;
    viewToAdjust.autoresizingMask = UIViewAutoresizingNone;
    if (viewToAdjust.superview && viewToAdjust != root)
    {
        RecursivelyAdjustView(root, viewToAdjust.superview, dif);
    }
    
    viewToAdjust.frame = f;
    viewToAdjust.autoresizingMask = mask;
}

float randomFloatBetween(float smallNumber, float bigNumber)
{
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

CGSize CGSizeMultiply(CGSize a, CGSize b)
{
    return CGSizeMake(a.width*b.width, a.height*b.height);
}

CGSize CGSizeMultiplyScalar(CGSize size, CGFloat scalar)
{
    return CGSizeMake(size.width * scalar, size.height * scalar);
}

CGSize CGSizeAdd(CGSize a, CGSize b)
{
    return CGSizeMake(a.width + b.width, a.height + b.height);
}

CGPoint CGSizeToCGPoint(CGSize size)
{
    return CGPointMake(size.width, size.height);
}

CGSize CGPointToCGSize(CGPoint point)
{
    return CGSizeMake(point.x, point.y);
}

CGRect CGRectFromComponents(CGSize point, CGSize size)
{
    return CGRectMake(point.width, point.height, size.width, size.height);
}

CGSize CGSizeXComponent(CGSize size)
{
    return CGSizeMultiply(size, CGSizeMake(1.f, 0.f));
}

CGSize CGSizeYComponent(CGSize size)
{
    return CGSizeMultiply(size, CGSizeMake(0.f, 1.f));
}

CGFloat Lerp(CGFloat x, CGFloat y, CGFloat a)
{
    return (x*(1-a))+(y*a);
}

CGSize CGSizeLerp(CGSize x, CGSize y, CGFloat a)
{
    return CGSizeMake(Lerp(x.width, y.width, a), Lerp(x.height, y.height, a));
}

CGRect CGRectLerp(CGRect x, CGRect y, CGFloat a)
{
    return CGRectFromComponents(
                                CGSizeLerp(CGPointToCGSize(x.origin), CGPointToCGSize(y.origin), a),
                                CGSizeLerp(x.size, y.size, a)
                                );
}

CGFloat Square(CGFloat x)
{
    return x*x;
}

CGFloat CGPointDistanceSquared(CGPoint x, CGPoint y)
{
    return Square(x.x - y.x) + Square(x.y - y.y);
}

CGFloat Clamp(CGFloat x, CGFloat min, CGFloat max)
{
    if (x > max)
    {
        return max;
    }
    if (x < min)
    {
        return min;
    }
    return x;
}

CGFloat DistanceAlongSegmentOfPointClosestToPoint(CGPoint p, CGPoint v, CGPoint w)
{
    CGFloat segmentDistance = CGPointDistanceSquared(v, w);
    if (segmentDistance == 0.f)
    {
        return 0.f;
    }
    
    return ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / segmentDistance;
}


CGPoint CGPointNearestPointOnSegment(CGPoint p, CGPoint v, CGPoint w)
{
    CGFloat segmentDistance = CGPointDistanceSquared(v, w);
    if (segmentDistance == 0.f)
    {
        return v;
    }
    
    CGFloat t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / segmentDistance;
    if (t < 0)
    {
        return v;
    }
    if (t > 1)
    {
        return w;
    }
    
    return CGSizeToCGPoint(CGSizeLerp(CGPointToCGSize(v), CGPointToCGSize(w), t));
}

CGPoint CGRectCenterPoint(CGRect rect)
{
    return CGPointMake(
                       rect.origin.x + (rect.size.width*0.5f),
                       rect.origin.y + (rect.size.height*0.5f)
                       );
}