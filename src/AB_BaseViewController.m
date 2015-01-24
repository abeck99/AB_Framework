//
//  AB_BaseViewController.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_BaseViewController.h"
#import "AB_Widget.h"
#import "AB_SectionViewController.h"

@implementation AB_BaseViewController

@synthesize isOpen;
@synthesize key;
@synthesize parent;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupScrollViews];
    
    for ( UIView* view in roundedViews )
    {
        view.clipsToBounds = YES;
        view.layer.cornerRadius = 5.f;
    }
    
    for ( UIView* view in circleViews )
    {
        view.clipsToBounds = YES;
        view.layer.cornerRadius = view.frame.size.width/2.f;
    }
    
    for ( UIView* view in gradientViews )
    {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = view.bounds;
        gradient.colors = @[(id) [[UIColor blackColor] CGColor], (id) [[UIColor grayColor] CGColor]];
        [view.layer insertSublayer:gradient atIndex:0];
    }
    
    searchForFonts(self.view);
    for ( UIView* view in fontViews )
    {
        searchForFonts(view);
    }
    
    for ( UIView* view in rotatedViews )
    {
        CGRect originalFrame = view.frame;
        view.center = CGPointMake(0.f, 0.f);
        view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI/-2.f);
        
        CGRect newFrame = view.frame;
        newFrame.origin = originalFrame.origin;
        view.frame = newFrame;
    }
}

- (void) setupWithFrame:(CGRect)frame
{
    self.view.frame = frame;
}

- (void) openViewInView:(UIView*)insideView withParent:(AB_SectionViewController*)setParent
{
    parent = setParent;
    [parent addChildViewController:self];
    [insideView addSubview:self.view];
    [self didMoveToParentViewController:parent];
    
    isOpen = YES;
}

- (void) closeView
{
    for ( UIGestureRecognizer* rec in [self.view.gestureRecognizers copy] )
    {
        [self.view removeGestureRecognizer:rec];
    }
    
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    isOpen = NO;
    parent = nil;
}

- (UIImage*) image:(UIImage*)image tintedWithColor:(UIColor*)tintColor
{
    CGSize imagesize = image.size;
    
    
    UIGraphicsBeginImageContextWithOptions(imagesize, NO, 0.f);
    CGRect rect = CGRectMake(0, 0, imagesize.width, imagesize.height);
    
    [image drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage* retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

- (void) pushOnParent:(NSString*)controllerName
{
    [self pushOnParent:controllerName withCompletion:nil];
}

- (void) pushOnParent:(NSString*)controllerName withCompletion:(CreateControllerBlock)completionBlock
{
    [parent pushControllerWithName:controllerName withCompletion:completionBlock];
}

- (void) replaceOnParent:(NSString*)controllerName
{
    [parent replaceControllerWithName:controllerName];
}

- (id) data
{
    return _data;
}

- (void) setData:(id)data
{
    if ( [data isKindOfClass:[[self class] expectedClass]] )
    {
        _data = data;
        [self setupFromData];
    }
    else
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Wrong class of data %@ sent to object expected %@", [data class], [[self class] expectedClass]]
                                     userInfo:nil];
    }
}

- (void) pushOnNavigationController:(id)controllerName withCompletion:(CreateControllerBlock)completionBlock
{
    [self pushOnNavigationController:controllerName withCompletion:completionBlock animated:YES];
}

- (void) pushOnNavigationController:(id)controllerName withCompletion:(CreateControllerBlock)completionBlock animated:(BOOL)animated
{
    [parent pushOnNavigationController:controllerName withCompletion:completionBlock animated:animated];
}

- (void) jumpToOrigin
{
    CGRect frame = self.view.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    frame.origin.y = self.view.bounds.origin.y;
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

- (void) jumpToElement:(UIView*)element
{
    CGRect frame = self.view.frame;
    
    CGPoint originInMainView = [self.view convertPoint:element.frame.origin fromView:element.superview];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    
    frame.origin.y = self.view.bounds.origin.y - originInMainView.y;
    self.view.frame = frame;
    
    [UIView commitAnimations];

//    
//    float rMoveDt = self.view.bounds.size.height - rPos_Y;
//    if( rMoveDt < 350 ) {
//        
//        rMoveDt = 350 - rMoveDt;
//        
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.2f];
//        
//        frame.origin.y = self.view.bounds.origin.y - rMoveDt;
//        self.view.frame = frame;
//        
//        [UIView commitAnimations];
//    }
//    else
//    {
//        [self jumpToOrigin];
//    }
}

- (void) setupFromData
{
}

- (void) attemptToReopen
{

}

+ (Class) expectedClass
{
    return [NSDictionary class];
}

- (void) poppedAwayWhileStillOpen
{
    
}

- (void) poppedBackWhileStillOpen
{
    
}

- (void) rootJumpToOrigin
{
    if ( !parent )
    {
        [self jumpToOrigin];
    }
    [parent rootJumpToOrigin];
}

- (void) rootJumpToElement:(UIView*)element
{
    if ( !parent )
    {
        [self jumpToElement:element];
    }
    [parent rootJumpToElement:element];
}

- (void) setupScrollViews
{
    if ( scrollViews.count != scrollContentViews.count )
    {
        [NSException raise:@"XIBSetupError" format:@"Invalid ScrollView setup!"];
    }
    
    for ( int i = 0; i < scrollViews.count; ++i )
    {
        UIScrollView* scrollView = [scrollViews objectAtIndex:i];
        UIView* contentView = [scrollContentViews objectAtIndex:i];
        
        CGRect contentFrame = contentView.frame;
        contentFrame.size.width = scrollView.frame.size.width;
        contentFrame.origin = CGPointZero;
        
        [scrollView addSubview:contentView];
        scrollView.contentSize = contentView.frame.size;
    }
}

- (IBAction) debugLayout:(id)sender
{
    printAllSubviews(self.view, 0);
}

- (void) allowChangeController:(ConfirmBlock)confirmBlock
{
    confirmBlock(YES);
}

@end

