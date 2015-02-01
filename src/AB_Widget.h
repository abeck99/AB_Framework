//
//  AB_Widget.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum AB_WidgetPos
{
    TopWidget,
    BottomWidget,
} AB_WidgetPos;

@interface AB_Widget : UIView
{
    AB_WidgetPos _pos;
}

// Overrides
+ (UINib*) baseNib;
- (void) setup;

// Init
- (id) initAtPos:(AB_WidgetPos)pos inController:(UIViewController*) parentController;
- (CGFloat) positionWidgetInController:(UIViewController*)parentController atPos:(CGFloat)yPos;

- (void) setHeight:(CGFloat)newHeight;

@property(readonly) AB_WidgetPos pos;
@property(weak) UIViewController* viewController;

@end

@interface UIViewController (WidgetExtension)

- (NSArray*) allWidgetsWithPos:(AB_WidgetPos)pos;
- (AB_Widget*) addWidget:(Class)widgetClass atPos:(AB_WidgetPos)pos withPosition:(int)posTag;
- (CGFloat) maximumExtentForWidgets:(AB_WidgetPos)pos;
- (void) arrangeWidgetsWithPos:(AB_WidgetPos)pos;
- (void) arrangeAllWidgets;
- (void) centerView:(UIView*)view;

- (void) setAlphaOnAllWidgets:(CGFloat)alpha;

@end


#define RETURN_NIB_NAMED(nibName) static UINib * __nib; static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{ __nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]]; }); return __nib;

