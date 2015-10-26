//
//  AB_SectionViewController.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_BaseViewController.h"
#import "AB_SelectControllerButton.h"

@interface AB_SectionViewController : AB_BaseViewController<AB_SectionContainer>
{
    IBOutlet UIView* contentView;
    
    NSMutableArray* contentControllers;
    
    NSNumber* currentlyLoading;
    
    id sectionSyncObject;
    
    IBOutlet UIView* triangleView;
   
    id<UIViewControllerContextTransitioning> currentTransitionObject;

    NSDictionary* sectionButtons;
}

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
     defaultController:(AB_Controller)defaultController;

- (AB_Controller) currentController;

- (void) pushControllerWithName:(id)name;
- (void) pushControllerWithName:(id)name
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock;
- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) pushControllerWithName:(id)name
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                    pushOnState:(BOOL)shouldPushOnState;

- (void) pushController:(AB_Controller)sectionController;
- (void) pushController:(AB_Controller)sectionController
              forceOpen:(BOOL)forceOpen
            pushOnState:(BOOL)shouldPushOnState;
- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock;
- (void) pushController:(AB_Controller)sectionController
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
              forceOpen:(BOOL)forceOpen
            pushOnState:(BOOL)shouldPushOnState;

@property(readonly) BOOL canPopController;
- (void) popController;
- (void) popControllerWithAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;

- (id<UIViewControllerAnimatedTransitioning>) defaultAnimationTransitioningTo:(id)key;

- (NSUInteger) numPushedViews;
- (void) controllerWillChange:(AB_Controller)newController;
- (void) controllerDidChange;

- (void) momentOfOverlapInView:(UIView*)parentView;

@property(readonly) UIView* contentView;

- (void) clearBackHistory;

@end
