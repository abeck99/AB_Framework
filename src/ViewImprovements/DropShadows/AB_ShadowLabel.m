//
//  AB_ShadowLabel.m
//  Eastern
//
//  Created by phoebe on 7/4/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ShadowLabel.h"

@implementation AB_ShadowLabel

- (void) setShadowRadius:(CGFloat)shadowRadius
{
//    self.layer.shadowRadius = shadowRadius;
}

- (CGFloat) shadowRadius
{
    return self.layer.shadowRadius;
}

- (void) setShadowOffset2:(CGSize)shadowOffset
{
//    self.layer.shadowOffset = shadowOffset;
}

- (CGSize) shadowOffset2
{
    return self.layer.shadowOffset;
}

- (void) setShadowColor2:(UIColor*)shadowColor
{
//    self.layer.shadowColor = shadowColor.CGColor;
}

- (UIColor*) shadowColor2
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
@end
