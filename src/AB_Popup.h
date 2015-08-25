//
//  AB_Popup.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_BaseViewController.h"
#import <ReactiveCocoa.h>
#import "Underscore.h"

@class AB_Popup;

typedef enum RevealDirection
{
    Bottom = 0,
    Top,
    Left,
    Right,
    None
} RevealDirection;

typedef enum PopupState
{
    PopupState_Pending = 0,
    PopupState_ReturningToPending,
    PopupState_Opening,
    PopupState_Opened,
    PopupState_Closing,
    PopupState_Closed
} PopupState;

// TODO: Unit test
@interface AB_Popup : UIView
{
    IBOutletCollection(UITextView) NSArray* expandableTextViews;
    IBOutletCollection(UIView) NSArray* roundedViews;
    
    UIView* blockingView;
}

+ (instancetype) get;

- (IBAction) closeSelf:(id)sender;
- (void) close;
- (void) setup;
- (void) closeFromBackgroundTap:(id)sender;
- (void) recalculateDestination;
- (BOOL) isOverlayPopup;
- (int) popupPriority;
- (CGFloat) animationSpeed;

@property(weak) UIViewController* viewController;
@property(strong) IBInspectable UIColor* blockingViewColor;
@property(assign) IBInspectable int revealDirection;

@property(readonly) RACSignal* stateSignal;

@end

@interface UIView(PopupExtension)

- (USArrayWrapper*) popups;

@end

@interface UIViewController (PopupExtension)

- (AB_Popup*) showPopup:(Class)popupClass;
- (void) closeAllPopups;
- (void) closeAllPopupsOfType:(Class)popupClass;
- (void) closeAllPopupsExcept:(NSArray*)popupClasses;
- (void) closeAllPopupsOfTypes:(NSArray*)popupClasses;

@end

#define RETURN_NIB_NAMED(nibName) static UINib * __nib; static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{ __nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]]; }); return __nib;
