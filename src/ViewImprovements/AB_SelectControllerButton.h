//
//  AB_SelectControllerButton.h

//
//  Created by phoebe on 5/31/15.
//  Copyright (c) 2015 Hero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AB_SelectControllerButton : UIButton
{
    IBOutletCollection(UIView) NSArray* enabledViews;
}

- (void) setIsSelected:(BOOL)selected;

@property(strong) IBInspectable NSString* controllerName;
@property(assign) IBInspectable BOOL forwardData;
@property(strong) id<UIViewControllerAnimatedTransitioning> animation;

@property(assign) IBInspectable CGFloat shadowRadius;
@property(assign) IBInspectable CGSize shadowOffset;
@property(assign) IBInspectable UIColor* shadowColor;
@property(assign) IBInspectable CGFloat shadowOpacity;

@property(assign) IBInspectable CGFloat cornerRadius;
@property(assign) IBInspectable CGFloat borderWidth;
@property(assign) IBInspectable UIColor* borderColor;

@property(strong) IBInspectable UIColor* highlightedBackgroundColor;
@property(strong) IBInspectable UIColor* disabledBackgroundColor;
@property(strong) IBInspectable UIColor* selectedBackgroundColor;


@end
