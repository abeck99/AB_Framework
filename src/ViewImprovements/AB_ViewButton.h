//
//  AB_ViewButton.h
//  Eastern
//
//  Created by phoebe on 7/4/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AB_ViewButton : UIButton
{
    IBOutlet UIView* selectedView;
    IBOutlet UIView* selectedHighlightedView;
    IBOutlet UIView* selectedDisabledView;
    IBOutlet UIView* selectedHighlightedDisabledView;
    
    IBOutlet UIView* normalView;
    IBOutlet UIView* normalHighlightedView;
    IBOutlet UIView* normalHighlightedDisabledView;
    IBOutlet UIView* normalDisabledView;
}

@property(readonly) UIView* currentView;
@property(readonly) IBInspectable BOOL stretchesView;

@end
