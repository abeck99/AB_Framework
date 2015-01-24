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
}

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
     defaultController:(AB_Controller)defaultController;

- (IBAction) changeController:(id)sender;
- (IBAction) changeController:(id)sender forced:(BOOL)forced;
- (IBAction) changeControllerForced:(id)sender;
- (void) changeControllerName:(id)controllerName forced:(BOOL)forced;

- (AB_Controller) currentController;

- (void) pushController:(AB_Controller)newController;
- (void) popController;
- (void) popControllerAnimated:(BOOL)animated;
- (void) replaceController:(AB_Controller)newController;
- (void) forceReplaceControllerWithName:(id)controllerName;

- (void) pushControllerWithName:(id)name;
- (void) pushControllerWithName:(id)name withCompletion:(CreateControllerBlock)completionBlock;
- (void) replaceControllerWithName:(id)name;

- (int) numPushedViews;
- (void) setHighlighted;
- (void) controllerDidChange;

- (void) requestFullScreen;
- (void) requestEmbeddedScreen;

@property(readonly) UIView* contentView;

@end
