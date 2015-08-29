//
//  AB_SelectControllerButton.m
//  GoHeroClient
//
//  Created by phoebe on 5/31/15.
//  Copyright (c) 2015 Hero. All rights reserved.
//

#import "AB_SelectControllerButton.h"
#import "ReactiveCocoa.h"

@interface AB_SelectControllerButton()
{
}

@property(strong) UIColor* originalBackgroundColor;

@end

@implementation AB_SelectControllerButton

- (void) setIsSelected:(BOOL)selected
{
    for(UIView* view in enabledViews)
    {
        view.hidden = !selected;
    }
    self.selected = selected;
}

- (void) awakeFromNib
{
    [self setup];
}

- (void) prepareForInterfaceBuilder
{
    [self setup];
}

- (void) setup
{
    self.originalBackgroundColor = self.backgroundColor;
    
    @weakify(self)
    RAC(self, backgroundColor) =
    [[RACSignal
      combineLatest:@[
                      RACObserve(self, highlighted),
                      RACObserve(self, enabled),
                      RACObserve(self, selected),
                      ]]
     map:^(RACTuple* tuple)
     {
         NSNumber* isHighlighted = tuple[0];
         NSNumber* isEnabled = tuple[1];
         NSNumber* isSelected = tuple[2];
         
         @strongify(self)
         if (![isEnabled boolValue] && self.disabledColor)
         {
             return self.disabledColor;
         }
         if ([isHighlighted boolValue] && self.highlightedColor)
         {
             return self.highlightedColor;
         }
         if ([isSelected boolValue] && self.selectedColor)
         {
             return self.selectedColor;
         }
         return self.originalBackgroundColor;
     }];
}

- (void) setShadowRadius:(CGFloat)shadowRadius
{
    self.layer.shadowRadius = shadowRadius;
}

- (CGFloat) shadowRadius
{
    return self.layer.shadowRadius;
}

- (void) setShadowOffset:(CGSize)shadowOffset
{
    self.layer.shadowOffset = shadowOffset;
}

- (CGSize) shadowOffset
{
    return self.layer.shadowOffset;
}

- (void) setShadowColor:(UIColor*)shadowColor
{
    self.layer.shadowColor = shadowColor.CGColor;
}

- (UIColor*) shadowColor
{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void) setShadowOpacity:(CGFloat)shadowOpacity
{
    self.layer.shadowOpacity = shadowOpacity;
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
