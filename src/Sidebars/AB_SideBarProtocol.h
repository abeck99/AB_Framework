//
//  AB_SideBarProtocol.h
//  Eastern
//
//  Created by phoebe on 7/2/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

@class AB_BaseViewController;

@protocol AB_SideBarProtocol

- (void) setupSidebarInController:(AB_BaseViewController*)controller;
@property(assign) BOOL sliderOpen;

- (int) priority;
- (UIView*) sidebarView;

@end

// TODO: Add typedef for AB_BaseViewController<AB_SidebarProtocol> (maybe AB_Controller<AB_SidebarProtocol>)


CGFloat EasingFunction(CGFloat p);
