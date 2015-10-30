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
#import "AB_Popup.h"
#import "ReactiveCocoa.h"

#define MAX_BACK_MEMORY 200

@interface AB_SectionViewController ()
{
    RACSubject* finishedTransitionSubject;
    AB_Controller _internalCurrentController;
}

@property(strong) NSArray* controllerDataStack;
@property(assign) BOOL internal_canPopController;

@end

@implementation AB_SectionViewController

- (void) internalSetCurrentController:(AB_Controller)_newCurrentController
{
    [self willChangeValueForKey:@"currentController"];
    _internalCurrentController = _newCurrentController;
    [self didChangeValueForKey:@"currentController"];
}

+ (BOOL) automaticallyNotifiesObserversOfCurrentController
{
    return NO;
}

- (AB_Controller) currentController
{
    return _internalCurrentController;
}

@synthesize contentView;

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        [self initData];
        [self controllerWillChange:nil];
        [self controllerDidChange];
    }
    
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil
                bundle:(NSBundle *)nibBundleOrNil
     defaultController:(AB_Controller)defaultController
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        [self initData];
        [self controllerWillChange:defaultController];
        if ( defaultController )
        {
            [self internalSetCurrentController:defaultController];
            self.controllerDataStack = @[];
        }
        [self controllerDidChange];
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
     } withAnimation:button.animation];
}

- (void) initData
{
    finishedTransitionSubject = [RACSubject subject];
    self.controllerDataStack = @[];
    sectionSyncObject = [[NSObject alloc] init];

    @weakify(self)
    [[[RACObserve(self, controllerDataStack)
     map:^(NSArray* stack)
     {
         return @(stack.count > 0);
     }]
     distinctUntilChanged]
    subscribeNext:^(NSNumber* canPop)
     {
         @strongify(self)
         [self willChangeValueForKey:@"canPopController"];
         self.internal_canPopController = [canPop boolValue];
         [self didChangeValueForKey:@"canPopController"];
     }];
}

+ (BOOL)automaticallyNotifiesObserversOfCanPopController
{
    return NO;
}

- (void) bind
{
    [super bind];

    NSMutableDictionary* mutableSectionButtons = [@{} mutableCopy];
    [self recursivelyFindButtons:self.view andAddToDictionary:mutableSectionButtons];
    sectionButtons = [NSDictionary dictionaryWithDictionary:mutableSectionButtons];
}

- (void) openInView:(UIView*)insideView
     withViewParent:(AB_Controller)viewParent_
          inSection:(AB_Section)sectionParent_;
{
    [super openInView:insideView withViewParent:viewParent_ inSection:sectionParent_];
    
    AB_Controller currentController = [self currentController];
    
    if (currentController)
    {
        [self controllerWillChange:currentController];
        [currentController openInView:contentView withViewParent:self inSection:self];
        [self controllerDidChange];
    }
}

- (void) closeView
{
    [super closeView];
    [[self currentController] closeView];
}

- (BOOL) canPopController
{
    return self.internal_canPopController;
}

- (void) popController
{
    [self popControllerWithAnimation:nil];
}

- (void) dealloc
{
}

- (void) pushControllerWithName:(id)name
{
    [self
     pushControllerWithName:name
     withConfigBlock:nil
     withAnimation:nil
     forceOpen:NO
     pushOnState:YES];
}

- (void) pushControllerWithName:(id)name withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self
     pushControllerWithName:name
     withConfigBlock:nil
     withAnimation:animation
     forceOpen:NO
     pushOnState:YES];
}

- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock
{
    [self
     pushControllerWithName:name
     withConfigBlock:configurationBlock
     withAnimation:nil
     forceOpen:NO
     pushOnState:YES];
}

- (void) pushControllerWithName:(id)name
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                    pushOnState:(BOOL)shouldPushOnState
{
    [self
     pushControllerWithName:name
     withConfigBlock:nil
     withAnimation:animation
     forceOpen:NO
     pushOnState:shouldPushOnState];
}

- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self
     pushControllerWithName:name
     withConfigBlock:configurationBlock
     withAnimation:animation
     forceOpen:NO
     pushOnState:YES];
}

- (void) pushControllerWithName:(id)name
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                shouldPushState:(BOOL)shouldPushState
{
    [self
     pushControllerWithName:name
     withConfigBlock:nil
     withAnimation:animation
     forceOpen:NO
     pushOnState:shouldPushState];
}

- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                shouldPushState:(BOOL)shouldPushState
{
    [self
     pushControllerWithName:name
     withConfigBlock:configurationBlock
     withAnimation:animation
     forceOpen:NO
     pushOnState:shouldPushState];
}

- (void) pushStateOnStack:(NSDictionary*)state
{
    NSMutableArray* newArray = [self.controllerDataStack mutableCopy];
    if (state)
    {
        [newArray addObject:state];
    }
    
    if ( newArray.count > MAX_BACK_MEMORY )
    {
        [newArray removeObjectAtIndex:0];
    }
    
    self.controllerDataStack = [NSArray arrayWithArray:newArray];
}

- (void) clearBackHistory
{
    self.controllerDataStack = @[];
}

- (NSDictionary*) popStateFromStack
{
    if (self.controllerDataStack.count == 0)
    {
        return nil;
    }
    
    NSDictionary* state = [self.controllerDataStack lastObject];
    NSMutableArray* newArray = [self.controllerDataStack mutableCopy];
    [newArray removeLastObject];
    self.controllerDataStack = [NSArray arrayWithArray:newArray];
    
    return state;
}

- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                      forceOpen:(BOOL)forceOpen
                    pushOnState:(BOOL)shouldPushOnState
{
    AB_Controller sectionController = [getController() controllerForTag:name];
    [self pushController:sectionController
         withConfigBlock:configurationBlock
           withAnimation:animation
               forceOpen:forceOpen
             pushOnState:shouldPushOnState];
}

- (void) pushController:(AB_Controller)sectionController
              forceOpen:(BOOL)forceOpen
            pushOnState:(BOOL)shouldPushOnState
{
    [self pushController:sectionController
         withConfigBlock:nil
           withAnimation:nil
               forceOpen:forceOpen
             pushOnState:shouldPushOnState];
}

- (void) pushController:(AB_Controller)sectionController
{
    [self pushController:sectionController
         withConfigBlock:nil
           withAnimation:nil
               forceOpen:NO
             pushOnState:YES];
}

- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock
{
    [self pushController:sectionController
         withConfigBlock:configurationBlock
           withAnimation:nil
               forceOpen:NO
             pushOnState:YES];
}

- (void) pushController:(AB_Controller)sectionController
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self pushController:sectionController
         withConfigBlock:nil
           withAnimation:animation
               forceOpen:NO
             pushOnState:YES];
}

- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self pushController:sectionController
         withConfigBlock:configurationBlock
           withAnimation:animation
               forceOpen:NO
             pushOnState:YES];
}

- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
              forceOpen:(BOOL)forceOpen
            pushOnState:(BOOL)shouldPushOnState
{
    id name = sectionController.key;
    
    if (configurationBlock)
    {
        configurationBlock(sectionController);
    }
    
    ConfirmBlock switchBlock = ^(BOOL confirmed)
    {
        if (!confirmed)
        {
            return;
        }

        NSDictionary* lastState = shouldPushOnState
            ? [[self currentController] getDescription]
            : nil;
        
        id<UIViewControllerAnimatedTransitioning>
        finalAnimation = animation ? animation : [self defaultAnimationTransitioningTo:name];
        [self pushStateOnStack:lastState];

        if (finalAnimation)
        {
            [self replaceController:sectionController
                      withAnimation:finalAnimation];
        }
        else
        {
            [self replaceController:sectionController];
        }
    };
    
    if (forceOpen)
    {
        switchBlock(YES);
    }
    else
    {
        AB_Controller currentController = [self currentController];
        if (currentController)
        {
            [currentController
             allowChangeController:switchBlock
             toController:sectionController];
        }
        else
        {
            switchBlock(YES);
        }
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
        }
                       withAnimation:animation
                           forceOpen:YES
                         pushOnState:NO];
    }
}

- (void) forceReplaceControllerWithName:(id)controllerName
{
    CGRect frameTest = self.contentView.bounds;
    NSLog(@"Bounds width: %g", frameTest.size.width);
    
    AB_Controller sectionController = [getController() controllerForTag:controllerName];
    [self replaceController:sectionController];
}

- (void) replaceController:(AB_Controller)newController
{
    [self controllerWillChange:newController];
    AB_Controller lastController = self.currentController;
    [self internalSetCurrentController:newController];
    [[self currentController] openInView:contentView
                          withViewParent:self
                               inSection:self];
    [lastController closeView];
    [self controllerDidChange];
}

- (void) momentOfOverlapInView:(UIView*)parentView
{
    
}

- (void) replaceController:(AB_Controller)newController
             withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    AB_Controller oldController = currentTransitionObject && [currentTransitionObject isKindOfClass:[AB_TransitionContextObject class]]
    ? ((AB_TransitionContextObject*)currentTransitionObject).toController
    : [self currentController];

    AB_TransitionContextObject* transitionObject =
    [[AB_TransitionContextObject alloc]
     initWithFromController:oldController
     toController:newController
     inContentView:self.contentView
     withAnimation:animation
     withCancelBlock:^
     {
         // Ensure animation really removed the view
         [newController.view removeFromSuperview];
         [finishedTransitionSubject sendNext:@YES];
     }
     withFinishBlock:^(AB_TransitionContextObject* contextObject)
     {
         if (oldController)
         {
             [oldController closeView];
         }

         if (currentTransitionObject == contextObject)
         {
             currentTransitionObject = nil;
         }

         [finishedTransitionSubject sendNext:@YES];
    }];
    
    AB_TransitionContextObject* lastTransition = currentTransitionObject;
    currentTransitionObject = transitionObject;

    // TODO: Remove this copy/paste...
    if (lastTransition)
    {
        [lastTransition
         addCompleteBlock:^(AB_TransitionContextObject* contextObject)
         {
             [self controllerWillChange:newController];
             
             [newController openInView:self.contentView
                        withViewParent:self
                             inSection:self];
             [self momentOfOverlapInView:self.contentView];
             newController.view.hidden = YES;
             
             [self internalSetCurrentController:newController];
             [self controllerDidChange];

             [animation animateTransition:transitionObject];
         }];
        [lastTransition
         addCancelBlock:^(AB_TransitionContextObject* contextObject)
         {
             [self controllerWillChange:newController];
             
             [newController openInView:self.contentView
                        withViewParent:self
                             inSection:self];
             [self momentOfOverlapInView:self.contentView];
             newController.view.hidden = YES;

             [self internalSetCurrentController:newController];
             [self controllerDidChange];

             [animation animateTransition:transitionObject];
         }];
    }
    else
    {
        [self controllerWillChange:newController];
        
        [newController openInView:self.contentView
                   withViewParent:self
                        inSection:self];
        [self momentOfOverlapInView:self.contentView];
        newController.view.hidden = YES;

        [self internalSetCurrentController:newController];
        [self controllerDidChange];

        [animation animateTransition:transitionObject];
    }
}

- (void) setButton:(UIButton*)button selected:(BOOL)selected
{
    button.selected = selected;
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

- (NSDictionary*) getDescription
{
    // TODO: Do dict namespacing or something so it's easy to add functionality to this serialization

    NSMutableDictionary* description = [[super getDescription] mutableCopy];
    
    
    NSDictionary* currentChildDescription = [[self currentController] getDescription];
    NSMutableArray* newArray = [self.controllerDataStack mutableCopy];
    
    // TODO: Copy/paste, need a "update data stack..."
    if (currentChildDescription)
    {
        [newArray removeLastObject];
        [newArray addObject:currentChildDescription];
    }
    
    description[@"controllerDataStack"] = newArray;
    
    return [NSDictionary dictionaryWithDictionary:description];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
//    if ([[self currentController] shouldFillSuperview])
//    {
//        [self currentController].view.frame = contentView.bounds;
//    }
}

- (void) applyDescription:(NSDictionary*)dictionary
{
    [super applyDescription:dictionary];

    [self initData];
    
    // TODO: this will load things twice... the default from the controller definition, then the actual one...
    NSArray* previousControllerDataStack = dictionary[@"controllerDataStack"];
    
    if (previousControllerDataStack.count > 0)
    {
        NSDictionary* childDescription = [previousControllerDataStack lastObject];
        
        
        // TODO: copy/pasteish
        NSMutableArray* newArray = [previousControllerDataStack mutableCopy];
        
        [newArray removeLastObject];
        self.controllerDataStack = [NSArray arrayWithArray:newArray];
        
        // TODO: Check that the order of execution here won't cause weird shit to happen
        [self pushControllerWithName:childDescription[@"tag"]
                     withConfigBlock:^(AB_Controller controller) {
                         [controller applyDescription:childDescription];
        }];
    }
}

@end
