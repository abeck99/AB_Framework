//
//  AB_BaseViewController.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_DataContainer.h"
#import "AB_Funcs.h"

#import "GAITrackedViewController.h"

// Return relevant data
typedef void (^CreateControllerBlock)(AB_Controller controller);
typedef void (^ConfirmBlock)(BOOL confirmed);


@interface AB_BaseViewController : GAITrackedViewController<AB_DataContainer>
{
    BOOL isOpen;
    IBOutletCollection(UIView) NSArray* themeViews;
    IBOutletCollection(UIView) NSArray* roundedViews;
    IBOutletCollection(UIView) NSArray* circleViews;
    IBOutletCollection(UIView) NSArray* gradientViews;
    IBOutletCollection(UIView) NSArray* fontViews;
    IBOutletCollection(UIView) NSArray* rotatedViews;
    
    IBOutletCollection(UIScrollView) NSArray* scrollViews;
    IBOutletCollection(UIView) NSArray* scrollContentViews;
    
    AB_SectionViewController* parent;
    
    id _data;
}

+ (Class) expectedClass;

- (void) setupWithFrame:(CGRect)frame;
- (void) openViewInView:(UIView*)insideView withParent:(AB_SectionViewController*)setParent;
- (void) closeView;

- (void) pushOnParent:(NSString*)controllerName;
- (void) pushOnParent:(NSString*)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock;
- (void) replaceOnParent:(NSString*)controllerName;

- (void) pushOnNavigationController:(id)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock;
- (void) pushOnNavigationController:(id)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock animated:(BOOL)animated;

- (void) jumpToOrigin;
- (void) jumpToElement:(UIView*)element;

- (void) rootJumpToOrigin;
- (void) rootJumpToElement:(UIView*)element;

- (void) setupFromData;

- (void) attemptToReopen;
- (void) poppedAwayWhileStillOpen;
- (void) poppedBackWhileStillOpen;

- (void) setupScrollViews;

- (IBAction) debugLayout:(id)sender;

- (void) allowChangeController:(ConfirmBlock)confirmBlock;

@property(readonly) BOOL isOpen;
@property(strong) id data;
@property(readonly) AB_SectionViewController* parent;

@end
