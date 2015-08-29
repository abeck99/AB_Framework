//
//  AB_SectionViewController.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_BaseViewController.h"
#import "AB_SelectControllerButton.h"

@interface AB_SectionViewController : AB_BaseViewController
{
    IBOutlet UIView* contentView;
    
    NSMutableArray* contentControllers;
    
    NSOperationQueue* controllerLoadQueue;
    
    NSNumber* currentlyLoading;
    
    id sectionSyncObject;
    
    IBOutlet UIView* triangleView;

    NSArray* controllerDataStack;
    
    id<UIViewControllerContextTransitioning> currentTransitionObject;

    NSDictionary* sectionButtons;
}

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
     defaultController:(AB_Controller)defaultController;

- (AB_Controller) currentController;

- (void) pushControllerWithName:(id)name;
- (void) pushControllerWithName:(id)name withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock;
- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;

- (void) pushControllerWithName:(id)name allowReopen:(BOOL)allowReopen;
- (void) pushControllerWithName:(id)name withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation allowReopen:(BOOL)allowReopen;
- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock allowReopen:(BOOL)allowReopen;
- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation allowReopen:(BOOL)allowReopen;

- (void) handleMagicButton:(AB_SelectControllerButton*)magicButton;

- (id<UIViewControllerAnimatedTransitioning>) defaultAnimationTransitioningTo:(id)key;
- (void) popController;
- (void) popControllerWithAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;

- (NSUInteger) numPushedViews;
- (void) setHighlighted;
- (void) controllerWillChange:(AB_Controller)newController;
- (void) controllerDidChange;

@property(readonly) UIView* contentView;

@end
