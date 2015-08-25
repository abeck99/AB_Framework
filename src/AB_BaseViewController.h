//
//  AB_BaseViewController.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_DataContainer.h"
#import "AB_Funcs.h"
#import "AB_SideBarProtocol.h"

#import "GAITrackedViewController.h"

typedef void (^CreateControllerBlock)(AB_Controller controller);

@interface AB_BaseViewController : GAITrackedViewController<AB_DataContainer>
{
    BOOL isOpen;
    IBOutletCollection(UIView) NSArray* themeViews;
    IBOutletCollection(UIView) NSArray* roundedViews;
    IBOutletCollection(UIView) NSArray* circleViews;
    IBOutletCollection(UIView) NSArray* gradientViews;
    IBOutletCollection(UIView) NSArray* rotatedViews;
    
    IBOutletCollection(UIScrollView) NSArray* scrollViews;
    IBOutletCollection(UIView) NSArray* scrollContentViews;
    
    AB_SectionViewController* sectionParent;
    AB_BaseViewController* viewParent;
    
    NSArray* sidebars;
    
    id _data;
}

- (NSString*) setScreenName;

+ (Class) expectedClass;

- (void) setupWithFrame:(CGRect)frame;
- (void) openInView:(UIView*)insideView
     withViewParent:(AB_BaseViewController*)viewParent_
          inSection:(AB_SectionViewController*)sectionParent_;
- (void) closeView;

- (id<AB_SideBarProtocol>) addSidebarAndOpen:(id)name;
- (id<AB_SideBarProtocol>) addSidebar:(id)name;
- (void) removeSidebar:(id)name;
- (id<AB_SideBarProtocol>) sidebar:(id)name;

- (void) pushOnParent:(NSString*)controllerName;
- (void) pushOnParent:(NSString*)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock;

- (void) pushOnNavigationController:(id)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock;
- (void) pushOnNavigationController:(id)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock animated:(BOOL)animated;

- (void) jumpToOrigin;
- (void) jumpToElement:(UIView*)element;

- (void) dataUpdated;

- (void) attemptToReopen;
- (void) poppedAwayWhileStillOpen;
- (void) poppedBackWhileStillOpen;

- (void) setupScrollViews;

- (IBAction) debugLayout:(id)sender;

- (void) resetScrollViewContentSizes;
- (NSArray*) sidebars;

@property(readonly) BOOL isOpen;
@property(strong) id data;
@property(readonly) AB_SectionViewController* sectionParent;

@end
