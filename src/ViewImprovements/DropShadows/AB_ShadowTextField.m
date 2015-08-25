//
//  AB_ShadowTextField.m
//  Eastern
//
//  Created by phoebe on 7/5/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ShadowTextField.h"

@implementation AB_ShadowTextField

- (void) setShadowRadius:(CGFloat)shadowRadius
{
//    self.layer.shadowRadius = shadowRadius;
}

- (CGFloat) shadowRadius
{
    return self.layer.shadowRadius;
}

- (void) setShadowOffset:(CGSize)shadowOffset
{
//    self.layer.shadowOffset = shadowOffset;
}

- (CGSize) shadowOffset
{
    return self.layer.shadowOffset;
}

- (void) setShadowColor:(UIColor*)shadowColor
{
//    self.layer.shadowColor = shadowColor.CGColor;
}

- (UIColor*) shadowColor
{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void) setShadowOpacity:(CGFloat)shadowOpacity
{
//    self.layer.shadowOpacity = shadowOpacity;
}

- (CGFloat) shadowOpacity
{
    return self.layer.shadowOpacity;
}

- (void) setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat) cornerRadius
{
    return self.layer.cornerRadius;
}

- (void) setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat) borderWidth
{
    return self.layer.borderWidth;
}

- (void) setBorderColor:(UIColor*)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor*) borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (UIEdgeInsets) insets
{
    return UIEdgeInsetsMake(self.topInset, self.leftInset, self.bottomInset, self.rightInset);
}

- (CGRect) textRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, [self insets]);
}

- (CGRect) editingRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, [self insets]);
}

@end
