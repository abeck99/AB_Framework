//
//  AB_ShadowImageView.m
//  Eastern
//
//  Created by phoebe on 7/4/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ShadowImageView.h"

@implementation AB_ShadowImageView

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

@end
