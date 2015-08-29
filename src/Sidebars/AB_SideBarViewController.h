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
    IBOutlet UIView* overhangFrame;
        
    UIView* closedView;
    UIView* openView;
    
    BOOL isOpened;
}

- (CGFloat) animationSpeed;
- (void) finishedOpen:(BOOL)wasAnimated;

- (void) setupOpenCloseFramesInView:(UIView*)insideView;

// TODO: Determine a better method than the anchor system (needs to be able to use constraints for the future)
// TODO: Allow Sidebar to remove itself (needs to remove itself from parent array)
// TODO: Add property for close direction and auto remove (will end up being like popup)
// TODO: Merge in popups ideas about priority and overlay
@property(assign) BOOL opened;
@property(assign) IBInspectable BOOL startsOpen;
@property(assign) IBInspectable BOOL keepsFrameSize;

@property(readonly) CGRect openFrame;
@property(readonly) CGRect closedFrame;

- (IBAction) toggleOpened:(id)sender;

@end
