//
//  AB_SideBarViewController.m
//  Eastern
//
//  Created by phoebe on 7/2/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_SideBarViewController.h"
#import "Underscore.h"
#import "AB_Funcs.h"
#import "ReactiveCocoa.h"
#import "AB_MixGesturesDelegate.h"
#import "AB_UIView+AutoresizingConvinence.h"

@interface AB_SideBarViewController()
{
    AB_MixGesturesDelegate* gestureDelegate;
}

@end

@implementation AB_SideBarViewController

#include "AB_SidebarContentM.inl"

@end

// TODO: There could be a better way to handle pan gestures here, using zip and switch to latest
//      For now I'll just do it the naive way
/*
 RACSignal* signalOfGestureSignals =
 [RACSignal
 if:[newPanGesture.rac_gestureSignal
 map:^NSNumber*(UIGestureRecognizer* rec)
 {
 return @(rec.state == UIGestureRecognizerStateBegan);
 }]
 then:[newPanGesture.rac_gestureSignal
 takeUntilBlock:^BOOL(UIGestureRecognizer* rec)
 {
 return rec.state == UIGestureRecognizerStateEnded;
 }]
 else:[RACSignal empty]];
 
 @weakify(self)
 [signalOfGestureSignals
 map:^RACSignal*(RACSignal* gestureSignal)
 {
 NSValue* curRectValue = nil;
 {
 @strongify(self)
 CGRect curRect = ((CALayer*)[self.view.layer presentationLayer]).frame;
 [self.view.layer removeAllAnimations];
 self.view.frame = curRect;
 curRectValue = [NSValue valueWithCGRect:curRect];
 }
 
 return [gestureSignal zipWith:]
 }]
 ]
 */
