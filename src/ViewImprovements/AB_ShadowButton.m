//
//  AB_ShadowButton.m
//  Eastern
//
//  Created by phoebe on 7/4/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ShadowButton.h"
#import "ReactiveCocoa.h"
#import "AB_PauseUpdates.h"
#import "AB_ReactiveCocoaExtensions.h"

@interface AB_ShadowButton()
{
}

@property(strong) UIColor* originalBackgroundColor;

@end

@implementation AB_ShadowButton

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
    AB_PauseUpdates* pauseUpdates = [[AB_PauseUpdates alloc] init];
    
    [pauseUpdates pauseDuringExecution:^
     {
         self.originalBackgroundColor = self.backgroundColor;
         
         RAC(self, backgroundColor) =
         [[[RACSignal
           combineLatest:@[
                           RACObserve(self, highlighted),
                           RACObserve(self, enabled),
                           RACObserve(self, selected),
                           RACObserve(self, originalBackgroundColor),
                           RACObserve(self, disabledBackgroundColor),
                           RACObserve(self, highlightedBackgroundColor),
                           RACObserve(self, selectedBackgroundColor),
                           ]] pause:pauseUpdates]
          map:^(RACTuple* tuple)
          {
              NSNumber* isHighlighted = tuple[0];
              NSNumber* isEnabled = tuple[1];
              NSNumber* isSelected = tuple[2];
              
              UIColor* originalBackgroundColor = [tuple[3] isValid] ? tuple[3] : nil;
              UIColor* disabledBackgroundColor = [tuple[4] isValid] ? tuple[4] : nil;
              UIColor* highlightedBackgroundColor = [tuple[5] isValid] ? tuple[5] : nil;
              UIColor* selectedBackgroundColor = [tuple[6] isValid] ? tuple[6] : nil;
              
              if (![isEnabled boolValue] && disabledBackgroundColor)
              {
                  return disabledBackgroundColor;
              }
              if ([isHighlighted boolValue] && highlightedBackgroundColor)
              {
                  return highlightedBackgroundColor;
              }
              if ([isSelected boolValue] && selectedBackgroundColor)
              {
                  return selectedBackgroundColor;
              }
              return originalBackgroundColor;
          }];
     }];
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    if (backgroundColor != self.disabledBackgroundColor &&
        backgroundColor != self.highlightedBackgroundColor &&
        backgroundColor != self.selectedBackgroundColor &&
        backgroundColor != self.originalBackgroundColor)
    {
        self.originalBackgroundColor = backgroundColor;
    }
    else
    {
        [super setBackgroundColor:backgroundColor];
    }
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
