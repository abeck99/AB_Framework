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

@class AB_TransitionContextObject;

typedef void (^TransitionCancelledBlock)();
typedef void (^TransitionCompleteBlock)(AB_TransitionContextObject* contextObject);

@interface AB_TransitionContextObject : NSObject<UIViewControllerContextTransitioning>
{
    AB_Controller fromController;
    AB_Controller toController;
    UIView* contentView;
    id<UIViewControllerAnimatedTransitioning> animation;
    NSArray* cancelBlocks;
    NSArray* completedBlocks;
    
    BOOL isCancelled;
}

@property(readonly) AB_Controller toController;

- (id) initWithFromController:(AB_Controller)_fromController
                 toController:(AB_Controller)_toController
                inContentView:(UIView*)_contentView
                withAnimation:(id<UIViewControllerAnimatedTransitioning>)_animation
              withCancelBlock:(TransitionCancelledBlock)_cancelBlock
              withFinishBlock:(TransitionCompleteBlock)_completeBlock;

- (void) addCompleteBlock:(TransitionCompleteBlock)completeBlock;
- (void) addCancelBlock:(TransitionCancelledBlock)cancelBlock;

@end
