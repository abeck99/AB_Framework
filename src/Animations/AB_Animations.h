//
//  AB_Animations.h
//  AB
//
//  Created by phoebe on 8/27/15.
//

#import <UIKit/UIKit.h>

#define DEFAULT_ANIMATION_TIME 0.3f

@interface AB_Animations : NSObject

+ (AB_Animations*) get;

- (id<UIViewControllerAnimatedTransitioning>) pan;
- (id<UIViewControllerAnimatedTransitioning>) reversePan;
- (id<UIViewControllerAnimatedTransitioning>) crossFade;

@end
