//
//  AB_TransitionContextObject.m
//  AnsellInterceptApp
//
//  Created by andrew on 2/1/15.
//  Copyright (c) 2015 Ansell. All rights reserved.
//

#import "AB_TransitionContextObject.h"

@implementation AB_TransitionContextObject

- (id) initWithFromController:(AB_Controller)_fromController
                 toController:(AB_Controller)_toController
                inContentView:(UIView*)_contentView
                withAnimation:(id<UIViewControllerAnimatedTransitioning>)_animation
              withCancelBlock:(TransitionCancelledBlock)_cancelBlock
              withFinishBlock:(TransitionCompleteBlock)_completeBlock
{
    if ( self == [super init] )
    {
        fromController = _fromController;
        toController = _toController;
        contentView = _contentView;
        animation = _animation;
        cancelBlock = _cancelBlock;
        completeBlock = _completeBlock;
    }
    
    return self;
}

// The view in which the animated transition should take place.
- (UIView *)containerView
{
    return contentView;
}

- (BOOL)isAnimated
{
    return YES;
}

- (BOOL) isInteractive
{
    return NO;
}

- (BOOL)transitionWasCancelled
{
    return isCancelled;
}

- (UIModalPresentationStyle)presentationStyle
{
    return UIModalPresentationCustom;
}

// It only makes sense to call these from an interaction controller that
// conforms to the UIViewControllerInteractiveTransitioning protocol and was
// vended to the system by a container view controller's delegate or, in the case
// of a present or dismiss, the transitioningDelegate.
- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    // TODO: Interactive Transitions not added yet
}

- (void) finishInteractiveTransition
{
    // TODO: Interactive Transitions not added yet
}

- (void) cancelInteractiveTransition
{
    isCancelled = YES;
    [contentView.layer removeAllAnimations];
}

// This must be called whenever a transition completes (or is cancelled.)
// Typically this is called by the object conforming to the
// UIViewControllerAnimatedTransitioning protocol that was vended by the transitioning
// delegate.  For purely interactive transitions it should be called by the
// interaction controller. This method effectively updates internal view
// controller state at the end of the transition.
- (void) completeTransition:(BOOL)didComplete
{
    if ( didComplete )
    {
        completeBlock(self);
    }
    else
    {
        cancelBlock();
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    return [@{
             UITransitionContextToViewControllerKey: toController,
             UITransitionContextFromViewControllerKey: fromController,
             } objectForKey:key];
}

- (UIView *)viewForKey:(NSString *)key
{
    return [@{
             UITransitionContextFromViewKey: fromController.view,
             UITransitionContextToViewKey: toController.view,
             } objectForKey:key];
}

- (CGAffineTransform)targetTransform
{
    return CGAffineTransformIdentity;
}

// The frame's are set to CGRectZero when they are not known or
// otherwise undefined.  For example the finalFrame of the
// fromViewController will be CGRectZero if and only if the fromView will be
// removed from the window at the end of the transition. On the other
// hand, if the finalFrame is not CGRectZero then it must be respected
// at the end of the transition.
- (CGRect)initialFrameForViewController:(UIViewController *)vc
{
    if ( vc == fromController )
    {
        return fromController.view.frame;
    }
    
    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc
{
    if ( vc == toController )
    {
        return toController.view.frame;
    }
    
    return CGRectZero;
}

@end
