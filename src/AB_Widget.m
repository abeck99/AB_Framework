//
//  AB_Widget.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_Widget.h"

@implementation AB_Widget

@synthesize pos = _pos;
@synthesize viewController;

// Overrides
+ (UINib*) baseNib
{
    return nil;
}

- (void) setup
{
    
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (id) initAtPos:(AB_WidgetPos)pos
{
    self = [super initWithFrame:CGRectMake(0,0,10,10)];
    if ( self )
    {
        UINib* nib = [[self class] baseNib];
        
        NSArray* arrayOfViews = [nib instantiateWithOwner:nil options:nil];
        
        if([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        id view = [arrayOfViews objectAtIndex: 0];
        self = view;
        _pos = pos;
        [self setup];
    }
    
    return self;
}

- (id) initAtPos:(AB_WidgetPos)pos inController:(UIViewController *)parentController
{
    self = [self initAtPos:pos];
    if ( self )
    {
        _pos = pos;
    }
    
    return self;
}

- (CGFloat) positionWidgetInController:(UIViewController*)parentController atPos:(CGFloat)yPos
{
    if ( _pos == BottomWidget )
    {
        yPos -= self.frame.size.height;
    }
    
    self.frame = CGRectMake(0, yPos, self.frame.size.width, self.frame.size.height);
    
    if ( _pos == TopWidget )
    {
        yPos += self.frame.size.height;
    }
    
    return yPos;
}

+ (void) load
{
    [[self class] baseNib];
}

- (void) setHeight:(CGFloat)newHeight
{
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

@end


@implementation UIViewController (WidgetExtension)

- (NSArray*) allWidgetsWithPos:(AB_WidgetPos)pos ascending:(BOOL)ascending
{
    NSPredicate* widgetSearch = [NSPredicate predicateWithFormat:@"(self isKindOfClass: %@) AND (pos == %d)", [AB_Widget class], (int) pos];
    
    NSArray* currentWidgets = [self.view.subviews filteredArrayUsingPredicate:widgetSearch];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:ascending];
    return [currentWidgets sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (NSArray*) allWidgetsWithPos:(AB_WidgetPos)pos
{
    return [self allWidgetsWithPos:pos ascending:NO];
}

- (AB_Widget*) addWidget:(Class)widgetClass atPos:(AB_WidgetPos)pos withPosition:(int)posTag
{
    AB_Widget* newWidget = [((AB_Widget*) [widgetClass alloc]) initAtPos:pos inController:self];
    newWidget.tag = posTag;
    newWidget.viewController = self;
    [self.view addSubview:newWidget];
    [self arrangeWidgetsWithPos:pos];
    return newWidget;
}

- (CGFloat) maximumExtentForWidgets:(AB_WidgetPos)pos
{
    NSArray* currentWidgets = [self allWidgetsWithPos:pos];
    
    CGFloat yPos = 0.f;
    switch ( pos )
    {
        case TopWidget:
        {
            yPos = currentWidgets.count > 0 ? ((UIView*) currentWidgets[0]).frame.origin.y + ((UIView*) currentWidgets[0]).frame.size.height : 0.f;
        }
            break;
        case BottomWidget:
        {
            yPos = currentWidgets.count > 0 ? ((UIView*) currentWidgets[0]).frame.origin.y : self.view.frame.size.height;
        }
            break;
    }
    
    return yPos;
}

- (void) arrangeWidgetsWithPos:(AB_WidgetPos)pos
{
    NSArray* widgets = [self allWidgetsWithPos:pos ascending:YES];
    
    CGFloat yPos = pos == TopWidget ? 0.f : self.view.frame.size.height;

    for ( AB_Widget* widget in widgets )
    {
        yPos = [widget positionWidgetInController:self atPos:yPos];
    }
}

- (void) setAlphaOnAllWidgets:(CGFloat)alpha
{
    for ( AB_Widget* widget in [self allWidgetsWithPos:TopWidget] )
    {
        widget.alpha = alpha;
    }
    for ( AB_Widget* widget in [self allWidgetsWithPos:BottomWidget] )
    {
        widget.alpha = alpha;
    }
}

- (void) arrangeAllWidgets
{
    [self arrangeWidgetsWithPos:TopWidget];
    [self arrangeWidgetsWithPos:BottomWidget];
}

- (void) centerView:(UIView*)view
{
    CGFloat topY = [self maximumExtentForWidgets:TopWidget];
    CGFloat botY = [self maximumExtentForWidgets:BottomWidget];
    
    CGRect frame = view.frame;
    frame.origin.y = topY;
    frame.size.height = botY - topY;
    view.frame = frame;
}

@end
