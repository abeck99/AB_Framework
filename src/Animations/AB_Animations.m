//
//  AB_Animations.m
//  AB
//
//  Created by phoebe on 8/27/15.
//

#import "AB_Animations.h"
#import "AB_Funcs.h"
#import "CECrossfadeAnimationController.h"
#import "CEPanAnimationController.h"
#import "AB_PanAnimation.h"

@implementation AB_Animations

+ (AB_Animations*) get
{
    RETURN_THREAD_SAFE_SINGLETON(AB_Animations)
}

- (id<UIViewControllerAnimatedTransitioning>) pan
{
    AB_PanAnimation* anim = [[AB_PanAnimation alloc] init];
    anim.duration = DEFAULT_ANIMATION_TIME;
    return anim;
}

- (id<UIViewControllerAnimatedTransitioning>) reversePan
{
    AB_PanAnimation* anim = [[AB_PanAnimation alloc] init];
    anim.duration = DEFAULT_ANIMATION_TIME;
    anim.reverse = YES;
    return anim;
}

- (id<UIViewControllerAnimatedTransitioning>) crossFade
{
    CECrossfadeAnimationController* anim = [[CECrossfadeAnimationController alloc] init];
    anim.duration = DEFAULT_ANIMATION_TIME;
    return anim;
}


@end
