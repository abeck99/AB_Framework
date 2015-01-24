//
//  AB_WrappedViewController.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_WrappedViewController.h"

@interface AB_WrappedViewController ()

@end

@implementation AB_WrappedViewController

@synthesize lastSectionController;

- (void) popControllerAnimated:(BOOL)animated
{
    [[self currentController] closeView];
    contentControllers = nil;
    [self.navigationController popViewControllerAnimated:animated];
    [[self.lastSectionController currentController] poppedBackWhileStillOpen];
}

- (void)openViewInView:(UIView *)insideView withParent:(AB_SectionViewController*)setParent
{
    retainSelf = @[self];
    [super openViewInView:insideView withParent:setParent];
}

- (void) closeView
{
    [super closeView];
    retainSelf = nil;
}

- (void) dealloc
{
}

@end
