//
//  AB_ShadowLabel.h
//  Eastern
//
//  Created by phoebe on 7/4/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AB_ShadowLabel : UILabel

@property(assign, nonatomic) IBInspectable CGFloat shadowRadius;
@property(assign, nonatomic) IBInspectable CGSize shadowOffset2;
@property(assign, nonatomic) IBInspectable UIColor* shadowColor2;
@property(assign, nonatomic) IBInspectable CGFloat shadowOpacity;

@property(assign, nonatomic) IBInspectable CGFloat cornerRadius;
@property(assign, nonatomic) IBInspectable CGFloat borderWidth;
@property(assign, nonatomic) IBInspectable UIColor* borderColor;

@end
