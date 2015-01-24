//
//  AB_Popup.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_BaseViewController.h"

@interface AB_Popup : UIView
{
    IBOutletCollection(UIView) NSArray* roundedViews;
}

- (IBAction) closeSelf:(id)sender;
- (void) setup;
- (void) closeFromBackgroundTap:(id)sender;

@property(weak) AB_BaseViewController* viewController;
@property(weak) UIView* blockingView;

@end


@interface UIViewController (PopupExtension)

- (AB_Popup*) showPopup:(Class)popupClass;
- (void) dismissPopup:(AB_Popup*)popup;

@end

#define RETURN_NIB_NAMED(nibName) static UINib * __nib; static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{ __nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]]; }); return __nib;
