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

#define LOG_LIFECYCLE 0

@interface AB_BaseViewController()
{
    BOOL _open;
    NSLayoutConstraint* heightConstraint;
    
    BOOL ignoreNextLayout;
    
    RACSubject* openSubject;
    RACSubject* closeSubject;
    
    CloseControllerBlock closeBlock;
}

@end


@implementation AB_BaseViewController

- (void) setCloseBlock:(CloseControllerBlock)setCloseBlock
{
    closeBlock = setCloseBlock;
}

- (void) prepareForReuse
{
    CloseControllerBlock capturedCloseBlock = closeBlock;
    closeBlock = nil;
    if (capturedCloseBlock)
    {
        capturedCloseBlock(self);
    }
}

+ (NSMutableArray*) existingControllers
{
    static dispatch_once_t pred;
    static NSMutableArray* existingControllers = nil;
    
    dispatch_once(&pred, ^{
        existingControllers = [@[] mutableCopy];
    });
    
    return existingControllers;
}

@synthesize key;

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        _open = NO;
        sidebars = @[];
        openSubject = [RACSubject subject];
        closeSubject = [RACSubject subject];
    }
    
    return self;
}

+ (BOOL) fitToView
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // TODO: Figure out cocoapods and google analytics dependency
    // self.screenName = [self setScreenName];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
//    if (ignoreNextLayout)
//    {
//        ignoreNextLayout = NO;
//        return;
//    }
    
//    if (heightDefiningView)
//    {
//        ignoreNextLayout = YES;
//        CGRect selfSize = self.view.frame;
//        selfSize.size.height = heightDefiningView.frame.size.height;
//        self.view.frame = selfSize;
//    }
}

- (CGFloat) height
{
    return heightDefiningView
    ? heightDefiningView.frame.size.height
    : self.view.frame.size.height;
}

- (CGFloat) width
{
    return heightDefiningView
    ? heightDefiningView.frame.size.width
    : self.view.frame.size.width;
}
//- (void) viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    if (heightDefiningView)
//    {
//        [self.view.superview addConstraint:[NSLayoutConstraint
//                                            constraintWithItem:self.view
//                                            attribute:NSLayoutAttributeHeight
//                                            relatedBy:0
//                                            toItem:heightDefiningView
//                                            attribute:NSLayoutAttributeHeight
//                                            multiplier:1.f
//                                            constant:0.f]];
//    }
//
//}

- (NSString*) setScreenName
{
    return nil;
}

- (void) openInView:(UIView*)insideView
     withViewParent:(AB_Controller)viewParent_
          inSection:(AB_Section)sectionParent_
{
#if LOG_LIFECYCLE
    NSLog(@"%p . Opening %@", self, self);
#endif
    sectionParent = sectionParent_;
//    NSLog(@"openInView withViewParent inSection...");

//    [viewParent_ addChildViewController:self];
    
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
    
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if (aboveView)
    {
        [insideView insertSubview:self.view belowSubview:aboveView];
    }
    else
    {
        [insideView addSubview:self.view];
    }

//    [self didMoveToParentViewController:viewParent_];
    
    if ([[self class] fitToView])
    {
        UIView* subview = self.view;
        
        [insideView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|-0-[subview]-0-|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:NSDictionaryOfVariableBindings(subview)]];
        
        [insideView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"V:|-0-[subview]-0-|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:NSDictionaryOfVariableBindings(subview)]];
    }

//    [insideView updateConstraints];
//    
////        self.view.translatesAutoresizingMaskIntoConstraints = NO;
////        self.view.frame = insideView.bounds;
//    
//    [insideView setNeedsLayout];
//    [self.view layoutIfNeeded];
    
    [self setOpen:YES];
    [openSubject sendNext:self];
}

+ (BOOL) shouldCache
{
    return YES;
}

- (void) bind
{
#if LOG_LIFECYCLE
    NSLog(@"%p . Binding %@", self, self);
#endif
    
    NSMutableArray* existingControllers = [AB_BaseViewController existingControllers];
    [existingControllers addObject:self];
    
//    NSLog(@"+ %lu", (unsigned long)existingControllers.count);
    [self showExistingControllers];
}

- (void) showExistingControllers
{
#if LOG_LIFECYCLE
    static NSUInteger i = 0;
    i = (i+1)%100;
    
    if (i==0)
    {
        for (AB_BaseViewController* bc in [AB_BaseViewController existingControllers])
        {
            NSLog(@"\t%@\t%p\t%@", bc.sourceString, bc, bc.key);
        }
    }
#endif
}

- (void) closeView
{
#if LOG_LIFECYCLE
    NSLog(@"%p . Closing %@", self, self);
#endif
    NSMutableArray* existingControllers = [AB_BaseViewController existingControllers];
//    if (![existingControllers containsObject:self])
//    {
//        NSLog(@"OBJ NMOT FOUND! %@", self.key);
//    }
    [existingControllers removeObject:self];
    
//    NSLog(@"+ %lu", (unsigned long)existingControllers.count);
//    [self showExistingControllers];

//    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
//    [self removeFromParentViewController];
    
    sectionParent = nil;
    
    [closeSubject sendNext:self];
    
    [self prepareForReuse];
    [self setOpen:NO];
}

- (void) dealloc
{
#if LOG_LIFECYCLE
    NSLog(@"%p . Deallocing %@", self, self);
#endif
    for ( UIGestureRecognizer* rec in [self.view.gestureRecognizers copy] )
    {
        [self.view removeGestureRecognizer:rec];
    }
}

- (BOOL) open
{
    return _open;
}

- (void) setOpen:(BOOL)open
{
    [self willChangeValueForKey:@"open"];
    _open = open;
    [self didChangeValueForKey:@"open"];
}

+ (BOOL)automaticallyNotifiesObserversOfOpen
{
    return NO;
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

- (id<AB_SideBarProtocol>) addSidebarAndOpen:(id)name
{
    id<AB_SideBarProtocol> sidebar = [self addSidebar:name];
    sidebar.sliderOpen = YES;
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
    AB_Controller sectionController = [[AB_Controllers get] controllerForTag:name];
    
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

- (void) attemptToReopen
{
    
}

- (void) addRetainObject:(id)obj
{
    retainObjects = retainObjects ? retainObjects : @[];
    
    if ([retainObjects containsObject:obj])
    {
        return;
    }
    
    NSMutableArray* mutableRetainObjects = [retainObjects mutableCopy];
    if (!mutableRetainObjects)
    {
        mutableRetainObjects = [@[] mutableCopy];
    }
    
    [mutableRetainObjects addObject:obj];
    retainObjects = [NSArray arrayWithArray:mutableRetainObjects];
}

- (IBAction) back:(id)sender
{
    [sectionParent popController];
}

- (IBAction) debugLayout:(id)sender
{
    printAllSubviews(self.view, 0);
}

- (void) allowChangeController:(ConfirmBlock)confirmBlock
                  toController:(AB_Controller)newController
{
    confirmBlock(YES);//![self.key isEqual:newController.key]);
}

- (void) allowPopController:(ConfirmBlock)confirmBlock
{
    confirmBlock(YES);
}


- (NSDictionary*) getDescription
{
    return @{
             @"tag": self.key,
             };
}

- (void) applyDescription:(NSDictionary*)dictionary
{
}

- (AB_Section) sectionParent
{
    return sectionParent;
}

- (NSArray*) sidebars
{
    return sidebars;
}

- (RACSignal*) openSignal
{
    return openSubject;
}

- (RACSignal*) closeSignal
{
    return closeSubject;
}

@end

