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

- (void) popControllerWithAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    // TODO: implement with animation controllers
    [NSException raise:NSInternalInconsistencyException format:@"Navigation controller popping not supported with new animation system yet!"];

//    [[self currentController] closeView];
//    contentControllers = nil;
//    [self.navigationController popViewControllerAnimated:animated];
//    [[self.lastSectionController currentController] poppedBackWhileStillOpen];
}

//- (id<UIViewControllerAnimatedTransitioning>)navigationController:
//(UINavigationController *)navigationController
//                                  animationControllerForOperation:(UINavigationControllerOperation)operation
//                                               fromViewController:(UIViewController *)fromVC
//                                                 toViewController:(UIViewController *)toVC {
//    
//    // reverse the animation for 'pop' transitions
//    _animationController.reverse = operation == UINavigationControllerOperationPop;
//    
//    return _animationController;
//}

- (void) openInView:(UIView*)insideView
     withViewParent:(AB_BaseViewController*)viewParent_
          inSection:(AB_SectionViewController*)sectionParent_
{
    retainSelf = @[self];
    [super openInView:insideView
       withViewParent:viewParent_
            inSection:sectionParent_];
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
