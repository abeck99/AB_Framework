//
//  AB_BaseViewController.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_BaseViewController.h"
#import "AB_Widget.h"
#import "AB_SectionViewController.h"
#import "AB_Controllers.h"
#import "AB_SideBarProtocol.h"
#import "Underscore.h"
#import "AB_Popup.h"

@implementation AB_BaseViewController

@synthesize isOpen;
@synthesize key;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    sidebars = sidebars ? sidebars : @[];
    
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
    
    for ( UIView* view in rotatedViews )
    {
        CGRect originalFrame = view.frame;
        view.center = CGPointMake(0.f, 0.f);
        view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI/-2.f);
        
        CGRect newFrame = view.frame;
        newFrame.origin = originalFrame.origin;
        view.frame = newFrame;
    }

    // TODO: Figure out cocoapods and google analytics dependency
    // self.screenName = [self setScreenName];
}

- (NSString*) setScreenName
{
    return nil;
}

- (void) setupWithFrame:(CGRect)frame
{
    sidebars = sidebars ? sidebars : @[];
    self.view.frame = frame;
}

- (void) openInView:(UIView*)insideView
     withViewParent:(AB_BaseViewController*)viewParent_
          inSection:(AB_SectionViewController*)sectionParent_;
{
    sectionParent = sectionParent_;
    viewParent = viewParent_;
    
    [viewParent addChildViewController:self];
    
    UIView* topPopupView = (UIView*) [insideView popups].first;
    
    id<AB_SideBarProtocol> sidebarAboveNew = nil;
    
    if ([[self class] conformsToProtocol:@protocol(AB_SideBarProtocol)])
    {
        id<AB_SideBarProtocol> selfSidebar = (id<AB_SideBarProtocol>)self;
        sidebarAboveNew =
        Underscore.array([viewParent_ sidebars])
        .filter(^BOOL(id<AB_SideBarProtocol> sidebar)
                {
                    return [sidebar priority] > [selfSidebar priority];
                })
        .first;
    }
    UIView* sidebarView = [sidebarAboveNew sidebarView];

    UIView* aboveView = sidebarView
        ? sidebarView
        : topPopupView;
    
    if (aboveView)
    {
        [insideView insertSubview:self.view belowSubview:aboveView];
    }
    else
    {
        [insideView addSubview:self.view];
    }

    [self didMoveToParentViewController:viewParent];
    
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
    viewParent = nil;
    sectionParent = nil;
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
    [self pushOnParent:controllerName withConfigBlock:nil];
}

- (void) pushOnParent:(NSString*)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock
{
    [sectionParent pushControllerWithName:controllerName withConfigBlock:configurationBlock];
}

- (id<AB_SideBarProtocol>) addSidebarAndOpen:(id)name
{
    id<AB_SideBarProtocol> sidebar = [self addSidebar:name];
    sidebar.opened = YES;
    return sidebar;
}

- (id<AB_SideBarProtocol>) sidebar:(id)name
{
    for (AB_Controller c in sidebars)
    {
        if ([c.key isEqual:name])
        {
            return (id<AB_SideBarProtocol>) c;
        }
    }
    
    return nil;
}

- (id<AB_SideBarProtocol>) addSidebar:(id)name
{
    AB_Controller sectionController = [getController() controllerForTag:name];
    
    // TODO: Prevent multiple side bars of the same name?
    if ([[sectionController class] conformsToProtocol:@protocol(AB_SideBarProtocol)])
    {
        id<AB_SideBarProtocol> sidebar = (id<AB_SideBarProtocol>)sectionController;
        [sidebar setupSidebarInController:self];
        
        NSMutableArray* mutableSidebars = [sidebars mutableCopy];
        [mutableSidebars addObject:sidebar];
        sidebars = [NSArray arrayWithArray:mutableSidebars];
        
        return sidebar;
    }
    
    return nil;
}

- (void) removeSidebar:(id)name
{
    AB_BaseViewController<AB_SideBarProtocol>* sidebar =
    Underscore.array(sidebars)
    .filter(^BOOL(AB_BaseViewController* controller)
            {
                return [controller isKindOfClass:[AB_BaseViewController class]] &&
                    [controller.key isEqual:name];
            })
    .first;
    
    [sidebar closeView];
    [sidebar.view removeFromSuperview];
    
    sidebars = Underscore.array(sidebars)
    .filter(^BOOL(id obj)
            {
                return obj != sidebar;
            })
    .unwrap;
}

- (id) data
{
    return _data;
}

- (void) setData:(id)data
{
    if ( !data || [data isKindOfClass:[[self class] expectedClass]] )
    {
        _data = data;
        [self dataUpdated];
    }
    else
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Wrong class of data %@ sent to object expected %@", [data class], [[self class] expectedClass]]
                                     userInfo:nil];
    }
}

- (void) pushOnNavigationController:(id)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock
{
    [self pushOnNavigationController:controllerName withConfigBlock:configurationBlock animated:YES];
}

- (void) pushOnNavigationController:(id)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock animated:(BOOL)animated
{
    [sectionParent pushOnNavigationController:controllerName
                              withConfigBlock:configurationBlock
                                     animated:animated];
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

- (void) dataUpdated
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


- (void) resetScrollViewContentSizes
{
    for ( int i = 0; i < scrollViews.count; ++i )
    {
        UIScrollView* scrollView = [scrollViews objectAtIndex:i];
        UIView* contentView = [scrollContentViews objectAtIndex:i];
        scrollView.contentSize = contentView.frame.size;
    }
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

- (NSDictionary*) getDescription
{
    return @{
             @"tag": self.key,
             @"data": _data ? _data : [NSNull null]
             };
}

- (void) applyDescription:(NSDictionary*)dictionary
{
    id data = dictionary[@"data"];
    if (data != [NSNull null])
    {
        self.data = data;
    }
}

- (void) poppedBack
{
    
}

- (AB_SectionViewController*) sectionParent
{
    return sectionParent;
}

- (NSArray*) sidebars
{
    return sidebars;
}

@end

