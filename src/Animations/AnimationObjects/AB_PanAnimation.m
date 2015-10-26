//
//  AB_PanAnimation.m
//  AB
//
//  Created by Andrew Beck on 10/26/15.
//

#import "AB_PanAnimation.h"
#import "POP.h"
#import "ReactiveCocoa.h"

@implementation AB_PanAnimation

- (id)init
{
    if (self = [super init])
    {
        self.duration = 1.0f;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    
    [self animateTransition:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
                   fromVC:(UIViewController *)fromVC
                     toVC:(UIViewController *)toVC
                 fromView:(UIView *)fromView
                   toView:(UIView *)toView
{
    toView.hidden = YES;
    
    [[RACScheduler mainThreadScheduler] after:[[NSDate date] dateByAddingTimeInterval:0.01f] schedule:^
     {
         toView.hidden = NO;
         UIView* containerView = [transitionContext containerView];
         [containerView addSubview:toView];

        CGFloat contentWidth = containerView.frame.size.width;
        
        NSTimeInterval duration = [self transitionDuration:transitionContext];

        POPBasicAnimation* fromAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        fromAnimation.duration = duration;
        fromAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        fromAnimation.toValue = self.reverse
         ? @(1.0*contentWidth)
         : @(-0.25*contentWidth);

        POPBasicAnimation* toAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        toAnimation.duration = duration;
        toAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
         toAnimation.fromValue = self.reverse
         ? @(-0.5*contentWidth)
         : @(1.5*contentWidth);
         
         static NSUInteger someArbitraryCounter = 0;
         someArbitraryCounter++;
         
         NSUInteger counter = someArbitraryCounter;
         
         NSString* fromAnimationPositionKey = [NSString stringWithFormat:@"fromAnimationPosition:%lu", (unsigned long)counter];
         NSString* toAnimationPosition = [NSString stringWithFormat:@"toAnimationPosition:%lu", (unsigned long)counter];
         NSString* springScaleAnimation = [NSString stringWithFormat:@"springScaleAnimation:%lu", (unsigned long)counter];
        
        [[RACSignal merge:@[
                           [AB_PanAnimation performAnimation:fromAnimation onView:fromView forKey:fromAnimationPositionKey],
                           [AB_PanAnimation performAnimation:toAnimation onView:toView forKey:toAnimationPosition],
                           ]]
         subscribeError:^(NSError* err)
         {
             [toView removeFromSuperview];
             [transitionContext completeTransition:NO];
         }
         completed:^
         {
             [fromView removeFromSuperview];
             [transitionContext completeTransition:YES];
         }];
        
        POPSpringAnimation* scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.springBounciness = 5;
        scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(2.f, 2.f)];
        [toView.layer pop_addAnimation:scaleAnimation forKey:springScaleAnimation];
     }];
}

+ (RACSignal*) performAnimation:(POPAnimation*)anim onView:(UIView*)view forKey:(NSString*)animKey
{
    return
    [RACSignal createSignal:^RACDisposable*(id<RACSubscriber>subscriber)
     {
         anim.completionBlock = ^(POPAnimation* anim, BOOL finished)
         {
             if (finished)
             {
                 [subscriber sendCompleted];
             }
             else
             {
                 [subscriber sendError:[NSError errorWithDomain:@"RuntimeApp" code:1 userInfo:@{}]];
             }
         };
         
         [view.layer pop_addAnimation:anim forKey:animKey];
         return nil;
     }];
}

@end
