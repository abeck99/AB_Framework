//
//  AB_SectionViewController.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_SectionViewController.h"
#import "AB_Controllers.h"
#import "AB_WrappedViewController.h"

@interface AB_SectionViewController ()

@end

@implementation AB_SectionViewController

@synthesize contentView;

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
     defaultController:(AB_Controller)defaultController
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        [self initData];
        if ( defaultController )
        {
            [contentControllers addObject:defaultController];
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
            
            NSNumber* controllerName = [NSNumber numberWithInt:button.tag];
            
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
        int currentTag = [getController() tagForController:[self currentController]];
        [self setHighlightedWithTag:currentTag];
        currentlyLoading = nil;
    }
    else
    {
        [self replaceControllerWithName:controllerName];
        if ( [controllerName isKindOfClass:[NSNumber class]] )
        {
            [self setHighlightedWithTag:[controllerName intValue]];
        }
    }
}

- (AB_Controller) currentController
{
    return (AB_Controller) [contentControllers lastObject];
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

- (void) pushController:(AB_Controller)newController
{
    [self cancelCurrentLoading];
    [[self currentController] poppedAwayWhileStillOpen];
    [contentControllers addObject:newController];
    [[self currentController] openViewInView:contentView withParent:self];
    [self controllerDidChange];
}

- (void) popController
{
    [self popControllerAnimated:YES];
}

- (void) dealloc
{
    [self cancelCurrentLoading];
}

- (void) cancelCurrentLoading
{
    [controllerLoadQueue cancelAllOperations];
}

- (void) pushControllerWithName:(id)name
{
    [self pushControllerWithName:name withCompletion:nil];
}

- (void) pushControllerWithName:(id)controllerName
                 withCompletion:(CreateControllerBlock)completionBlock
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
    
    CGRect frame = self.contentView.frame;
    frame.origin = CGPointZero;

    [loadControllerOp addExecutionBlock:^{
        __block AB_Controller sectionController = nil;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            sectionController = [getController() controllerForTag:controllerName];
        }];
        if ( [weakLoadControllerOp isCancelled] )
        {
            return;
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [sectionController setupWithFrame:frame];
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
            
            currentlyLoading = nil;
            
        
            [self pushController:sectionController];
            if ( completionBlock )
            {
                completionBlock(sectionController);
            }
        }];
    }];

    [controllerLoadQueue addOperation:loadControllerOp];
}

- (void) forceReplaceControllerWithName:(id)controllerName
{
    CGRect frame = self.contentView.frame;
    frame.origin = CGPointMake(0.f, 0.f);
    
    AB_Controller sectionController = [getController() controllerForTag:controllerName];
    [sectionController setupWithFrame:frame];
    [self replaceController:sectionController];
}

- (void) replaceControllerWithName:(id)controllerName
{
    NSBlockOperation* loadControllerOp = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation* weakLoadControllerOp = loadControllerOp;
    
    CGRect frame = self.contentView.frame;
    frame.origin = CGPointMake(0.f, 0.f);
    
    [loadControllerOp addExecutionBlock:^{
        __block AB_Controller sectionController = nil;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            sectionController = [getController() controllerForTag:controllerName];
        }];

        if ( [weakLoadControllerOp isCancelled] )
        {
            return;
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [sectionController setupWithFrame:frame];
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
            
            currentlyLoading = nil;
        
            [self replaceController:sectionController];
        }];
    }];
    
    [controllerLoadQueue addOperation:loadControllerOp];
}

- (void) pushOnNavigationController:(id)controllerName withCompletion:(CreateControllerBlock)completionBlock animated:(BOOL)animated
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
            [self.navigationController pushViewController:wrappedController animated:animated];
            
            if ( completionBlock )
            {
                completionBlock(newController);
            }
        }];
    }];
    
    [controllerLoadQueue addOperation:loadControllerOp];
}

- (void) popControllerAnimated:(BOOL)animated
{
    [[self currentController] closeView];
    [contentControllers removeLastObject];
    assert( [contentControllers count] > 0 );
    [[self currentController] poppedBackWhileStillOpen];
    [self controllerDidChange];
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

- (int) numPushedViews
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
