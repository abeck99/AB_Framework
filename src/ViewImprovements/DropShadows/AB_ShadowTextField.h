//
//  AB_ShadowTextField.h
//  Eastern
//
//  Created by phoebe on 7/5/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AB_ShadowTextField : UITextField

@property(assign) IBInspectable CGFloat shadowRadius;
@property(assign) IBInspectable CGSize shadowOffset;
@property(assign) IBInspectable UIColor* shadowColor;
@property(assign) IBInspectable CGFloat shadowOpacity;

@property(assign) IBInspectable CGFloat cornerRadius;
@property(assign) IBInspectable CGFloat borderWidth;
@property(assign) IBInspectable UIColor* borderColor;

@property(assign) IBInspectable CGFloat topInset;
@property(assign) IBInspectable CGFloat leftInset;
@property(assign) IBInspectable CGFloat bottomInset;
@property(assign) IBInspectable CGFloat rightInset;

@end
