//
//  AB_SectionViewController.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_SectionViewController.h"
#import "AB_Controllers.h"
#import "AB_WrappedViewController.h"
#import "AB_TransitionContextObject.h"

#define MAX_BACK_MEMORY 200

@interface AB_SectionViewController ()

@end

@implementation AB_SectionViewController

@synthesize contentView;

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        [self initData];
        [self controllerDidChange];
    }
    
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
     defaultController:(AB_Controller)defaultController
{
    if ( self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        if ( defaultController )
        {
            [contentControllers addObject:defaultController];
            controllerDataStack = @[@{
                                        @"tag": defaultController.key,
                                        @"data": [NSNull null],
                                        }];
            [self controllerDidChange];
        }
    }
    
    return self;
}

- (void) awakeFromNib
{
    [self initData];
}

- (void) initData
{
    controllerDataStack = @[];
    contentControllers = [NSMutableArray arrayWithCapacity:1];
    controllerLoadQueue = [[NSOperationQueue alloc] init];
    sectionSyncObject = [[NSObject alloc] init];
}

- (IBAction) changeController:(id)sender
{
    [self changeController:sender forced:NO];
}

- (IBAction) changeControllerForced:(id)sender
{
    [self changeController:sender forced:YES];
}

- (IBAction) changeController:(id)sender forced:(BOOL)forced
{
    UIButton* button = (UIButton*) sender;
    
    AB_Controller currentController = [self currentController];
    
    
    ConfirmBlock confirmBlock = ^(BOOL confirmed){
        if ( confirmed )
        {
            NSInteger currentTag = [getController() tagForController:[self currentController]];
            if ( currentTag == button.tag )
            {
                [[self currentController] attemptToReopen];
                return;
            }
            
            NSNumber* controllerName = [NSNumber numberWithLong:button.tag];
            
            [self changeControllerName:controllerName forced:forced];
        }
    };
    
    if ( currentController && [currentController isKindOfClass:[AB_BaseViewController class]] )
    {
        [(AB_BaseViewController*) currentController allowChangeController:confirmBlock];
    }
    else
    {
        confirmBlock(YES);
    }
}

- (void) changeControllerName:(id)controllerName forced:(BOOL)forced
{
    if ( currentlyLoading &&
        [currentlyLoading class] == [controllerName class] &&
        [controllerName compare:currentlyLoading] == NSOrderedSame )
    {
        return;
    }
    
    currentlyLoading = controllerName;
    
    if ( forced )
    {
        [self forceReplaceControllerWithName:controllerName];
        NSInteger currentTag = [getController() tagForController:[self currentController]];
        [self setHighlightedWithTag:currentTag];
        currentlyLoading = nil;
    }
    else
    {
        [self pushControllerWithName:controllerName];
        if ( [controllerName isKindOfClass:[NSNumber class]] )
        {
            [self setHighlightedWithTag:[controllerName intValue]];
        }
    }
}

- (AB_Controller) currentController
{
    return contentControllers.count > 0
        ? (AB_Controller) [contentControllers lastObject]
        : nil;
}

- (void) setupWithFrame:(CGRect)frame
{
    [super setupWithFrame:frame];

    CGRect contentFrame = contentView.frame;
    contentFrame.origin = CGPointMake(0.f, 0.f);
    [[self currentController] setupWithFrame:contentFrame];
}

- (void) openViewInView:(UIView*)insideView withParent:(AB_SectionViewController*)setParent
{
    [self cancelCurrentLoading];
    [super openViewInView:insideView withParent:setParent];
    [[self currentController] openViewInView:contentView withParent:self];
    [self setHighlighted];
}

- (void) closeView
{
    [self cancelCurrentLoading];
    [super closeView];
    [[self currentController] closeView];
}

- (void) popController
{
    [self popControllerWithAnimation:nil];
}

- (void) dealloc
{
    [self cancelCurrentLoading];
}

- (void) cancelCurrentLoading
{
    [controllerLoadQueue cancelAllOperations];
    [currentTransitionObject cancelInteractiveTransition];
    currentTransitionObject = nil;
}

- (void) pushControllerWithName:(id)name
{
    [self pushControllerWithName:name withConfigBlock:nil withAnimation:nil];
}

- (void) pushControllerWithName:(id)name withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self pushControllerWithName:name withConfigBlock:nil withAnimation:animation];
}

- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock
{
    [self pushControllerWithName:name withConfigBlock:configurationBlock withAnimation:nil];
}

    
- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    AB_Controller sectionController = [getController() controllerForTag:name];
    [sectionController setupWithFrame:self.contentView.bounds];
    
    if ( animation )
    {
        [self replaceController:sectionController withAnimation:animation completeBlock:^{
            NSMutableArray* newArray = [controllerDataStack mutableCopy];
            [newArray addObject:@{
                                  @"tag": name,
                                  @"data": sectionController.data ? sectionController.data : [NSNull null],
                                  }];
            
            if ( newArray.count > MAX_BACK_MEMORY )
            {
                [newArray removeObjectAtIndex:0];
            }
            
            controllerDataStack = [NSArray arrayWithArray:newArray];
        }];

        if (configurationBlock)
        {
            configurationBlock(sectionController);
        }
    }
    else
    {
        [self replaceController:sectionController];

        if (configurationBlock)
        {
            configurationBlock(sectionController);
        }
        
        NSMutableArray* newArray = [controllerDataStack mutableCopy];
        [newArray addObject:@{
                              @"tag": name,
                              @"data": sectionController.data ? sectionController.data : [NSNull null],
                              }];
        
        if ( newArray.count > MAX_BACK_MEMORY )
        {
            [newArray removeObjectAtIndex:0];
        }
        
        controllerDataStack = [NSArray arrayWithArray:newArray];
    }
}

- (void) popControllerWithAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    if ( controllerDataStack.count > 1 )
    {
        NSMutableArray* newArray = [controllerDataStack mutableCopy];
        
        [newArray removeLastObject];
        NSDictionary* lastViewDict = [newArray lastObject];
        [newArray removeLastObject];
        controllerDataStack = [NSArray arrayWithArray:newArray];
        
        id viewData = lastViewDict[@"data"];
        viewData = viewData == [NSNull null] ? nil : viewData;
        
        [self pushControllerWithName:lastViewDict[@"tag"]
                     withConfigBlock:^(AB_Controller controller) {
                         controller.data = viewData;
                     }
                       withAnimation:animation];
    }
}

- (void) forceReplaceControllerWithName:(id)controllerName
{
    CGRect frameTest = self.contentView.bounds;
    NSLog(@"Bounds width: %g", frameTest.size.width);
    
    CGRect frame = self.contentView.bounds;
    AB_Controller sectionController = [getController() controllerForTag:controllerName];
    [sectionController setupWithFrame:frame];
    [self replaceController:sectionController];
}

- (void) pushOnNavigationController:(id)controllerName withConfigBlock:(CreateControllerBlock)configurationBlock animated:(BOOL)animated
{
    if ( currentlyLoading &&
        [currentlyLoading class] == [controllerName class] &&
        [controllerName compare:currentlyLoading] == NSOrderedSame )
    {
        return;
    }
    
    currentlyLoading = controllerName;
    NSBlockOperation* loadControllerOp = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation* weakLoadControllerOp = loadControllerOp;
    
    CGRect frame = self.view.frame;
    
    [loadControllerOp addExecutionBlock:^{
        __block AB_Controller newController = nil;
        __block AB_WrappedViewController* wrappedController = nil;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            newController = [getController() controllerForTag:controllerName];
            wrappedController = [[AB_WrappedViewController alloc] initWithNibName:@"EmptyWrapperView" bundle:[NSBundle mainBundle] defaultController:nil];
            wrappedController.lastSectionController = self;
            
        }];

        if ( [weakLoadControllerOp isCancelled] )
        {
            return;
        }
    
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [wrappedController setupWithFrame:frame];
            CGRect contentFrame = wrappedController.contentView.frame;
            contentFrame.origin = CGPointMake(0.f, 0.f);
            [newController setupWithFrame:contentFrame];
            wrappedController.view.userInteractionEnabled = YES;
            [wrappedController replaceController:newController];
        }];
        
        
        if ( [weakLoadControllerOp isCancelled] )
        {
            return;
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ( [weakLoadControllerOp isCancelled] )
            {
                return;
            }
            
            [self poppedAwayWhileStillOpen];
            
            currentlyLoading = nil;
            
            if ( configurationBlock )
            {
                configurationBlock(newController);
            }

            [self.navigationController pushViewController:wrappedController animated:animated];
        }];
    }];
    
    [controllerLoadQueue addOperation:loadControllerOp];
}

- (void) replaceController:(AB_Controller)newController
{
    [self cancelCurrentLoading];
    if ( [contentControllers count] > 0 )
    {
        [[self currentController] closeView];        
    }
    [contentControllers removeAllObjects];
    [contentControllers addObject:newController];
    [[self currentController] openViewInView:contentView withParent:self];
    [self controllerDidChange];
}

- (void) replaceController:(AB_Controller)newController withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self replaceController:newController withAnimation:animation completeBlock:nil];
}

- (void) replaceController:(AB_Controller)newController withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation completeBlock:(void (^)())completeBlock
{
    [self cancelCurrentLoading];
    
    AB_TransitionContextObject* transitionObject = nil;
    
    transitionObject = [[AB_TransitionContextObject alloc] initWithFromController:[self currentController]
                                                                     toController:newController
                                                                    inContentView:self.contentView
                                                                    withAnimation:animation
                                                                  withCancelBlock:^{
                                                                      // Ensure animation really removed the view
                                                                      [newController.view removeFromSuperview];
                                                                         }
                                                                  withFinishBlock:^(AB_TransitionContextObject* contextObject){
                                                                     if ( [contentControllers count] > 0 )
                                                                     {
                                                                         [[self currentController] closeView];
                                                                     }
                                                                     [contentControllers removeAllObjects];
                                                                     [newController openViewInView:nil withParent:self];
                                                                     [contentControllers addObject:newController];
                                                                      if ( currentTransitionObject == contextObject )
                                                                      {
                                                                          currentTransitionObject = nil;
                                                                      }
                                                                      if ( completeBlock )
                                                                      {
                                                                          completeBlock();
                                                                      }
                                                                      [self controllerDidChange];
                                                                         }];
    
    currentTransitionObject = transitionObject;
    [animation animateTransition:currentTransitionObject];
}


- (void) setupFromData
{
    [super setupFromData];
    [self currentController].data = self.data;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setHighlighted];
}

- (void) setButton:(UIButton*)button selected:(BOOL)selected
{
    button.selected = selected;
}

- (void) setHighlighted
{
    NSInteger currentTag = [getController() tagForController:[self currentController]];
    [self setHighlightedWithTag:currentTag];
}

- (void) setHighlightedWithTag:(NSInteger)currentTag
{
    UIButton* highlightedButton = nil;
    for ( UIView* themeView in themeViews )
    {
        for ( UIView* subview in themeView.subviews )
        {
            if ( [subview isKindOfClass:[UIButton class]] )
            {
                UIButton* button = (UIButton*) subview;
                [self setButton:button selected:button.tag == currentTag];
                if ( button.tag == currentTag )
                {
                    highlightedButton = button;
                }
            }
        }
    }
    
    if ( highlightedButton )
    {
        CGRect triangleFrame = triangleView.frame;
        triangleFrame.origin.x = highlightedButton.frame.origin.x;
        
        CGFloat animateTime = triangleView.alpha == 0.f ? 0.f : 0.3f;
        
        [UIView animateWithDuration:animateTime animations:^{
            triangleView.alpha = 1.f;
            triangleView.frame = triangleFrame;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            triangleView.alpha = 0.f;
        }];
    }
}

- (NSUInteger) numPushedViews
{
    return contentControllers.count;
}

- (void) controllerDidChange
{
    
}

- (void) requestFullScreen
{
    [parent requestFullScreen];
}

- (void) requestEmbeddedScreen
{
    [parent requestEmbeddedScreen];
}

- (void) poppedAwayWhileStillOpen
{
    [[self currentController] poppedAwayWhileStillOpen];
}

- (void) poppedBackWhileStillOpen
{
    [[self currentController] poppedBackWhileStillOpen];
}

@end
