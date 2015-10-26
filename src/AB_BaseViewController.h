//
//  AB_BaseViewController.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_DataContainer.h"
#import "AB_Funcs.h"
#import "AB_SideBarProtocol.h"

//#import "GAITrackedViewController.h"

@interface AB_BaseViewController : UIViewController<AB_DataContainer>
{
    IBOutlet UIView* heightDefiningView;
    
    AB_Section sectionParent;
    
    NSArray* retainObjects;
    NSArray* sidebars;
}

- (NSString*) setScreenName;

- (void) openInView:(UIView*)insideView
     withViewParent:(AB_Controller)viewParent_
          inSection:(AB_Section)sectionParent_;
- (void) closeView;

- (id<AB_SideBarProtocol>) addSidebarAndOpen:(id)name;
- (id<AB_SideBarProtocol>) addSidebar:(id)name;
- (void) removeSidebar:(id)name;
- (id<AB_SideBarProtocol>) sidebar:(id)name;

- (IBAction) back:(id)sender;

@property(readonly) BOOL open;
@property(readonly) AB_Section sectionParent;

@property(readonly) CGFloat height;

@property(strong) NSString* sourceString;


- (void) showExistingControllers;

@end
