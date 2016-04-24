//
//  AB_SideBarSectionViewController.m
//  Eastern
//
//  Created by phoebe on 7/2/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_SideBarSectionViewController.h"
#import "Underscore.h"
#import "AB_Funcs.h"
#import "ReactiveCocoa.h"
#import "AB_MixGesturesDelegate.h"
#import "AB_UIView+AutoresizingConvinence.h"
#include "easing.h"

@interface AB_SideBarSectionViewController()
{
    AB_MixGesturesDelegate* gestureDelegate;
    BOOL ignoreLayoutChanges;
    RACDisposable* animationDisposable;
    
    CGFloat _openAmount;
}

@property(assign) CGFloat openAmount;

@end

@implementation AB_SideBarSectionViewController

#include "AB_SidebarContentM.inl"

@end

CGFloat EasingFunction(CGFloat p)
{
    return -(p * (p - 2));
}