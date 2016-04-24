//
//  AB_ControllerTableViewCell.h
//  AB
//
//  Created by Andrew on 09/15/2015.
//

#import <UIKit/UIKit.h>
#import "AB_MultiTableViewCell.h"
#import "AB_DataContainer.h"
#import "AB_PassthroughView.h"
#import "AB_SectionHeader.h"
#import "AB_BaseViewController.h"

@interface AB_ControllerTableViewCell : AB_PassthroughView<AB_TableView>

- (void) setController:(AB_Controller)controller
    withViewController:(AB_Controller)viewController
               section:(AB_Section)section;

@property(strong) NSObject<AB_SectionHeader>* header;
@property(readonly, strong) AB_Controller controller;

@end

@interface AB_BaseCellViewController : AB_BaseViewController
{
    IBOutletCollection(UIView) NSArray* openViews;
    // When going to 1px height, the cell is considered closed (if it's 0px, apple displays this error: "Warning once only: Detected a case where constraints ambiguously suggest a height of zero for a tableview cell's content view. We're considering the collapse unintentional and using standard height instead." and sets the cell very large - there doesn't appear to be a way to mark 0px height as "intentional)
    //      Due to this odd design choice, openViews is used to fade in views meant to be displayed when "open" (IE > 1px) and clsoedViews are faded in when display is "closed"
    IBOutletCollection(UIView) NSArray* closedViews;
}

@property(assign) BOOL isExpanded;

@end