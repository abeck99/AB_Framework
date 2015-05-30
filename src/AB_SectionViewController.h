//
//  AB_SectionViewController.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_BaseViewController.h"

@interface AB_SectionViewController : AB_BaseViewController
{
    IBOutlet UIView* contentView;
    
    NSMutableArray* contentControllers;
    
    NSOperationQueue* controllerLoadQueue;
    
    NSNumber* currentlyLoading;
    
    id sectionSyncObject;
    
    IBOutlet UIImageView* triangleView;

    NSArray* controllerDataStack;
    
    id<UIViewControllerContextTransitioning> currentTransitionObject;
}

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
     defaultController:(AB_Controller)defaultController;

- (IBAction) changeController:(id)sender;
- (IBAction) changeController:(id)sender forced:(BOOL)forced;
- (IBAction) changeControllerForced:(id)sender;
- (void) changeControllerName:(id)controllerName forced:(BOOL)forced;

- (AB_Controller) currentController;

- (void) pushControllerWithName:(id)name;
- (void) pushControllerWithName:(id)name withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock;
- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) popController;
- (void) popControllerWithAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;

- (NSUInteger) numPushedViews;
- (void) setHighlighted;
- (void) controllerDidChange;

- (void) requestFullScreen;
- (void) requestEmbeddedScreen;

@property(readonly) UIView* contentView;

@end
