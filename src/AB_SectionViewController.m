//
//  AB_SectionViewController.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_SectionViewController.h"
#import "AB_Controllers.h"
#import "AB_WrappedViewController.h"
#import "AB_TransitionContextObject.h"
#import "AB_SelectControllerButton.h"

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
            controllerDataStack = @[];
        }
    }
    
    return self;
}

- (void) awakeFromNib
{
    [self initData];
}

- (void) recursivelyFindButtons:(UIView*)view
             andAddToDictionary:(NSMutableDictionary*)mutableSectionButtons
{
    if ([view isKindOfClass:[AB_SelectControllerButton class]])
    {
        AB_SelectControllerButton* button = (AB_SelectControllerButton*)view;
        [button addTarget:self
                   action:@selector(magicButtonSelect:)
         forControlEvents:UIControlEventTouchUpInside];
        
        NSArray* currentButtons = [mutableSectionButtons objectForKey:button.controllerName];
        NSMutableArray* newButtons = currentButtons ? [currentButtons mutableCopy] : [@[] mutableCopy];
        [newButtons addObject:button];
        mutableSectionButtons[button.controllerName] = [NSArray arrayWithArray:newButtons];
        
        [self handleMagicButton:button];
        
    }
    
    for (UIView* subview in view.subviews)
    {
        [self recursivelyFindButtons:subview andAddToDictionary:mutableSectionButtons];
    }
}

- (void) handleMagicButton:(AB_SelectControllerButton*)magicButton
{
    
}

- (void) showMagicButtonsForKey:(id)key
{
    for (NSString* buttonKey in [sectionButtons allKeys])
    {
        NSArray* selectButtons = sectionButtons[buttonKey];
        
        for (AB_SelectControllerButton* selectButton in selectButtons)
        {
            [selectButton
             setIsSelected:[key
                            isEqualToString:selectButton.controllerName]];
        }
    }
}

- (void) showMagicButtonsIfSelected
{
    id currentControllerName = [self currentController].key;
    [self showMagicButtonsForKey:currentControllerName];
}

- (void) magicButtonSelect:(AB_SelectControllerButton*)button
{
    if ([button.controllerName isEqual:[self currentController].key])
    {
        [[self currentController] attemptToReopen];
        return;
    }
    
    [self pushControllerWithName:button.controllerName withConfigBlock:^(AB_Controller c)
     {
         if (button.forwardData)
         {
             c.data = self.data;
         }
     } withAnimation:button.animation];
}

- (void) initData
{
    controllerDataStack = @[];
    contentControllers = [NSMutableArray arrayWithCapacity:1];
    controllerLoadQueue = [[NSOperationQueue alloc] init];
    sectionSyncObject = [[NSObject alloc] init];
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

    [[self currentController] setupWithFrame:contentView.bounds];

    NSMutableDictionary* mutableSectionButtons = [@{} mutableCopy];
    [self recursivelyFindButtons:self.view andAddToDictionary:mutableSectionButtons];
    sectionButtons = [NSDictionary dictionaryWithDictionary:mutableSectionButtons];
    
    [[self currentController] openInView:contentView withViewParent:self inSection:self];
    [self controllerDidChange];
}

- (void) openInView:(UIView*)insideView
     withViewParent:(AB_BaseViewController*)viewParent_
          inSection:(AB_SectionViewController*)sectionParent_;
{
    [self cancelCurrentLoading];
    [super openInView:insideView withViewParent:viewParent_ inSection:sectionParent_];
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

- (void) pushControllerWithName:(id)name allowReopen:(BOOL)allowReopen
{
    [self pushControllerWithName:name withConfigBlock:nil withAnimation:nil allowReopen:allowReopen];
}

- (void) pushControllerWithName:(id)name withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation allowReopen:(BOOL)allowReopen
{
    [self pushControllerWithName:name withConfigBlock:nil withAnimation:animation allowReopen:allowReopen];
}

- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock allowReopen:(BOOL)allowReopen
{
    [self pushControllerWithName:name withConfigBlock:configurationBlock withAnimation:nil allowReopen:allowReopen];
}

- (void) pushControllerWithName:(id)name
{
    [self pushControllerWithName:name withConfigBlock:nil withAnimation:nil allowReopen:NO];
}

- (void) pushControllerWithName:(id)name withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self pushControllerWithName:name withConfigBlock:nil withAnimation:animation allowReopen:NO];
}

- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock
{
    [self pushControllerWithName:name withConfigBlock:configurationBlock withAnimation:nil allowReopen:NO];
}

- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self pushControllerWithName:name withConfigBlock:configurationBlock withAnimation:animation allowReopen:NO];
}

- (void) pushStateOnStack:(NSDictionary*)state
{
    NSMutableArray* newArray = [controllerDataStack mutableCopy];
    if (state)
    {
        [newArray addObject:state];
    }
    
    if ( newArray.count > MAX_BACK_MEMORY )
    {
        [newArray removeObjectAtIndex:0];
    }
    
    controllerDataStack = [NSArray arrayWithArray:newArray];
}

- (NSDictionary*) popStateFromStack
{
    if (controllerDataStack.count == 0)
    {
        return nil;
    }
    
    NSDictionary* state = [controllerDataStack lastObject];
    NSMutableArray* newArray = [controllerDataStack mutableCopy];
    [newArray removeLastObject];
    controllerDataStack = [NSArray arrayWithArray:newArray];
    
    return state;
}

- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation allowReopen:(BOOL)allowReopen
{
    [self pushControllerWithName:name withConfigBlock:configurationBlock withAnimation:animation allowReopen:allowReopen pushOnState:YES];
}

- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation allowReopen:(BOOL)allowReopen pushOnState:(BOOL)shouldPushOnState
{
    if (!allowReopen && [[self currentController].key isEqual:name])
    {
        if (configurationBlock)
        {
            configurationBlock([self currentController]);
        }
        return;
    }
    
    animation = animation ? animation : [self defaultAnimationTransitioningTo:name];
    
    ConfirmBlock switchBlock = ^(BOOL confirmed)
    {
        if (!confirmed)
        {
            return;
        }
        
        NSDictionary* lastState = shouldPushOnState
        ? [[self currentController] getDescription]
        : nil;
        
        AB_Controller sectionController = [getController() controllerForTag:name];
        [sectionController setupWithFrame:self.contentView.bounds];
        
        if ( animation )
        {
            [self replaceController:sectionController withAnimation:animation completeBlock:^{
                [self pushStateOnStack:lastState];
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
            
            [self pushStateOnStack:lastState];
        }
    };
    
    AB_Controller currentController = [self currentController];
    if (currentController)
    {
        [currentController allowChangeController:switchBlock];
    }
    else
    {
        switchBlock(YES);
    }
}

- (void) popControllerWithAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    NSDictionary* state = [self popStateFromStack];
    if (state)
    {
        [self pushControllerWithName:state[@"tag"]
                     withConfigBlock:^(AB_Controller controller)
        {
            [controller applyDescription:state];
            [controller poppedBack];
        }
                       withAnimation:animation
         allowReopen:YES pushOnState:NO];
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
            wrappedController = [[AB_WrappedViewController alloc] initWithNibName:@"EmptyWrapperView" bundle:[NSBundle bundleForClass:[self class]] defaultController:nil];
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
    [self controllerWillChange:newController];
    if ( [contentControllers count] > 0 )
    {
        [[self currentController] closeView];        
    }
    [contentControllers removeAllObjects];
    [contentControllers addObject:newController];
    [[self currentController] openInView:contentView
                          withViewParent:self
                               inSection:self];
    [self controllerDidChange];
}

- (void) replaceController:(AB_Controller)newController withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self replaceController:newController withAnimation:animation completeBlock:nil];
}

- (void) replaceController:(AB_Controller)newController withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation completeBlock:(void (^)())completeBlock
{
    [self cancelCurrentLoading];
    [self controllerWillChange:newController];
    
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
                                                                      [contentControllers addObject:newController];
                                                                      [newController openInView:nil
                                                                                 withViewParent:self
                                                                                      inSection:self];
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

- (void) controllerWillChange:(AB_Controller)newController
{
    [self showMagicButtonsForKey:newController.key];
}

- (id<UIViewControllerAnimatedTransitioning>) defaultAnimationTransitioningTo:(id)key
{
    return nil;
}

- (void) controllerDidChange
{
    [self showMagicButtonsIfSelected];
}

- (void) poppedAwayWhileStillOpen
{
    [[self currentController] poppedAwayWhileStillOpen];
}

- (void) poppedBackWhileStillOpen
{
    [[self currentController] poppedBackWhileStillOpen];
}

- (NSDictionary*) getDescription
{
    // TODO: Do dict namespacing or something so it's easy to add functionality to this serialization

    NSMutableDictionary* description = [[super getDescription] mutableCopy];
    
    
    NSDictionary* currentChildDescription = [[self currentController] getDescription];
    NSMutableArray* newArray = [controllerDataStack mutableCopy];
    
    // TODO: Copy/paste, need a "update data stack..."
    if (currentChildDescription)
    {
        [newArray removeLastObject];
        [newArray addObject:currentChildDescription];
    }
    
    description[@"controllerDataStack"] = newArray;
    
    return [NSDictionary dictionaryWithDictionary:description];
}

- (void) applyDescription:(NSDictionary*)dictionary
{
    [super applyDescription:dictionary];

    // TODO: this will load things twice... the default from the controller definition, then the actual one...
    NSArray* previousControllerDataStack = dictionary[@"controllerDataStack"];
    
    if (previousControllerDataStack.count > 0)
    {
        NSDictionary* childDescription = [previousControllerDataStack lastObject];
        
        
        // TODO: copy/pasteish
        NSMutableArray* newArray = [previousControllerDataStack mutableCopy];
        
        [newArray removeLastObject];
        controllerDataStack = [NSArray arrayWithArray:newArray];
        
        // TODO: Check that the order of execution here won't cause weird shit to happen
        [self pushControllerWithName:childDescription[@"tag"]
                     withConfigBlock:^(AB_Controller controller) {
                         [controller applyDescription:childDescription];
                         [controller poppedBack];
        }];
    }
}

@end
