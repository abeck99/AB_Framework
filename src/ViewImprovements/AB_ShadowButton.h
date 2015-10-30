//
//  AB_ShadowButton.h
//  Eastern
//
//  Created by phoebe on 7/4/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AB_ShadowButton : UIButton

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
