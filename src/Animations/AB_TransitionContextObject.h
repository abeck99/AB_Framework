//
//  AB_TransitionContextObject.h
//  AnsellInterceptApp
//
//  Created by andrew on 2/1/15.
//  Copyright (c) 2015 Ansell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AB_BaseViewController.h"

typedef void (^TransitionCancelledBlock)();
typedef void (^TransitionCompleteBlock)();

@interface AB_TransitionContextObject : NSObject<UIViewControllerContextTransitioning>
{
    AB_Controller fromController;
    AB_Controller toController;
    UIView* contentView;
    id<UIViewControllerAnimatedTransitioning> animation;
    TransitionCancelledBlock cancelBlock;
    TransitionCompleteBlock completeBlock;
    
    BOOL isCancelled;
}

- (id) initWithFromController:(AB_Controller)_fromController
                 toController:(AB_Controller)_toController
                inContentView:(UIView*)_contentView
                withAnimation:(id<UIViewControllerAnimatedTransitioning>)_animation
              withCancelBlock:(TransitionCancelledBlock)_cancelBlock
              withFinishBlock:(TransitionCompleteBlock)_completeBlock;

@end
