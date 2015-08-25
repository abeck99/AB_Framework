//
//  AB_Funcs.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RETURN_THREAD_SAFE_SINGLETON(className) static dispatch_once_t pred; static className* ret = nil; dispatch_once(&pred, ^{ ret = [[className alloc] init]; }); return ret;

#define RETURN_THREAD_SAFE_NIB(nibName) static dispatch_once_t pred; static UINib* ret = nil; dispatch_once (&pred, ^{ ret = [UINib nibWithNibName:@nibName bundle:[NSBundle mainBundle]];}); return ret;


void printAllSubviews(UIView* view, int depth);

void AdjustViewToHeight(UIView* root, UIView* viewToAdjust, CGFloat height);
void RecursivelyAdjustView(UIView* root, UIView* viewToAdjust, CGFloat dif);

CGSize CGSizeMultiply(CGSize a, CGSize b);
CGSize CGSizeMultiplyScalar(CGSize size, CGFloat scalar);
CGSize CGSizeAdd(CGSize a, CGSize b);
CGSize CGSizeAddScalar(CGSize point, CGFloat scalar);
CGRect CGRectFromComponents(CGSize point, CGSize size);

CGSize CGSizeXComponent(CGSize size);
CGSize CGSizeYComponent(CGSize size);

CGPoint CGSizeToCGPoint(CGSize size);
CGSize CGPointToCGSize(CGPoint point);

CGFloat Lerp(CGFloat x, CGFloat y, CGFloat a);
CGSize CGSizeLerp(CGSize x, CGSize y, CGFloat a);
CGRect CGRectLerp(CGRect x, CGRect y, CGFloat a);

CGFloat Square(CGFloat x);
CGFloat Clamp(CGFloat x, CGFloat min, CGFloat max);
CGFloat CGPointDistanceSquared(CGPoint x, CGPoint y);

// This may be the longest method name I have ever used, and I've seen this mocked in the days before autocomplete was a standard feature in IDES. I stand by descriptivness
CGFloat DistanceAlongSegmentOfPointClosestToPoint(CGPoint p, CGPoint v, CGPoint w);
CGPoint CGPointNearestPointOnSegment(CGPoint p, CGPoint v, CGPoint w);

CGPoint CGRectCenterPoint(CGRect rect);
