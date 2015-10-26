//
//  AB_SideBarViewController.h
//  Eastern
//
//  Created by phoebe on 7/2/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_BaseViewController.h"
#import "AB_SideBarProtocol.h"

// TODO: Rename to something that would encompass both popups and side bars...
@interface AB_SideBarViewController : AB_BaseViewController<AB_SideBarProtocol>
{
    IBOutletCollection(UIView) NSArray* interactionBars;
    IBOutletCollection(UIView) NSArray* viewsToHideWhenClosed;
    IBOutletCollection(UIView) NSArray* viewsToHideWhenOpened;
    
    IBOutlet NSLayoutConstraint* slidingConstraint;

    CGRect openRect;
    CGRect closedRect;

    IBOutlet UIView* slideContentView;
}

- (CGFloat) animationSpeed;
- (void) finishedOpen:(BOOL)wasAnimated;

// TODO: Allow Sidebar to remove itself (needs to remove itself from parent array)
// TODO: Merge in popups ideas about priority and overlay
@property(assign) BOOL sliderOpen;
@property(assign) IBInspectable BOOL startsOpen;

@property(assign) IBInspectable CGFloat closedConstant;
@property(assign) IBInspectable CGFloat openConstant;

- (IBAction) toggleOpened:(id)sender;

@end
