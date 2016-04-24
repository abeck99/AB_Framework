//
//  AB_Controllers.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_Controllers.h"
#import "AB_SectionViewController.h"
#import "ReactiveCocoa.h"
#import "AB_ReactiveCocoaExtensions.h"

#define DEBUG_NUM_CONTROLLERS 0

@interface AB_Controllers()
{
    NSDictionary* controllers;
    NSMutableDictionary* nibs;
    NSMutableDictionary* controllerPool;
    
    NSDictionary* preloadControllers;

#if DEBUG_NUM_CONTROLLERS
    NSMutableDictionary* controllerCount;
#endif
    
    
}

@end

// TODO: Make this into something that each controller keeps a reference to the controller factory, this global call is not good
AB_Controllers* gControllers = nil;

@implementation AB_Controllers

+ (AB_Controllers*) get
{
    return gControllers;
}

+ (void) set:(AB_Controllers*)newControllers
{
    gControllers = newControllers;
}

- (id) init
{
    if ( self = [super init] )
    {
/*
        @"name": {
                @"class": [SomeController class],
                @"nib": @"xibName",
                },
 */
        controllers = [self getControllers];
        controllerPool = [@{} mutableCopy];
#if DEBUG_NUM_CONTROLLERS
        controllerCount = [@{} mutableCopy];
#endif
        [self loadNibs];
        
        [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void) loadNibs
{
    NSMutableDictionary* mutableNibs = [NSMutableDictionary dictionaryWithCapacity:[controllers count]];
    
    for ( id key in [controllers allKeys] )
    {
        NSDictionary* viewDict = [controllers objectForKey:key];
        NSString* nibName = viewDict[@"nib"];
        if ( ![mutableNibs objectForKey:nibName] )
        {
            mutableNibs[nibName] = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
        }
    }
    
    nibs = [NSMutableDictionary dictionaryWithDictionary:mutableNibs];
}

- (AB_Controller) controllerForTag:(id)key
{
    return [self controllerForTag:key source:nil];
}

- (AB_Controller) controllerForTag:(id)key source:(NSString*)sourceString
{
    NSDictionary* controllerDesc = controllers[key];

    if ( !controllerDesc )
    {
        controllerDesc = controllers[@"default"];
    }

    id defaultKey = [controllerDesc objectForKey:@"defaultController"];

    @synchronized(controllerPool)
    {
        NSMutableSet* pool = controllerPool[key];
        if (pool.count > 0)
        {
            AB_Controller retController = [pool anyObject];
            [pool removeObject:retController];
            retController.sourceString = sourceString;
            
            if ([retController conformsToProtocol:@protocol(AB_SectionContainer)])
            {
                AB_Section section = (AB_Section)retController;
                
                [section clearBackHistory];
                
                if (defaultKey)
                {
                    AB_Controller subcontroller = [self controllerForTag:defaultKey];
                    [section pushController:subcontroller];
                }
            }
            
            return retController;
        }
    }
    
    Class class = controllerDesc[@"class"];
    NSString* nibName = controllerDesc[@"nib"];
    
    if ( !class || !nibName )
    {
//        [NSException
//         raise:NSInvalidArgumentException
//         format:@"%@ is not a valid controller!", key];
        return nil;
    }

    UINib* nib = nibs[nibName];
    if ( !nib )
    {
//        [NSException
//         raise:NSInvalidArgumentException
//         format:@"%@ does not have a valid nib!", key];
        return nil;
    }
    
    AB_Controller retController = nil;
    
    if ( defaultKey )
    {
        AB_Controller defaultController = [self controllerForTag:defaultKey];
        retController = [[class alloc] initWithNibName:nil bundle:[NSBundle mainBundle] defaultController:defaultController];
    }
    else
    {
        retController = [[class alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    }
    retController.key = key;
    
    NSArray* objs = [nib instantiateWithOwner:retController options:@{}];
    for (id obj in objs)
    {
        [retController addRetainObject:obj];
    }
    
    
    if (!retController.view)
    {
        [NSException
         raise:NSInvalidArgumentException
         format:@"%@ probably didn't set it's view in %@", key, nibName];
        return nil;
    }
    
    retController.sourceString = @"initial-setup";
    [retController bind];
    retController.sourceString = sourceString;
    
    [self addDebugLabelToView:retController.view withKey:key];
    
#if DEBUG_NUM_CONTROLLERS
    controllerCount[key] = @([controllerCount[key] intValue] + 1);
    NSLog(@"Current controller count:");
    for (id k in [controllerCount allKeys])
    {
        id v = controllerCount[k];
        NSLog(@"\t%@: %@", k, v);
    }
#endif
    
    if ([[retController class] shouldCache])
    {
        __weak AB_Controller weakController = retController;
        __weak NSMutableDictionary* weakControllerPool = controllerPool;
        [[[retController
           rac_valuesAndChangesForKeyPath:@"open" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld observer:self]
          takeUntil:retController.rac_willDeallocSignal]
         subscribeNext:^(RACTuple *value)
         {
             AB_Controller strongController = weakController;
             NSMutableDictionary* strongControllerPool = weakControllerPool;
             
             if (!strongController || !strongControllerPool)
             {
                 return;
             }
             
             NSDictionary* changes = value[1];
             
             NSNumber* old = changes[@"old"];
             NSNumber* new = changes[@"new"];
             if (old && new && [old isValid] && [new isValid])
             {
                 BOOL wasOpen = [old boolValue];
                 BOOL isOpen = [new boolValue];
                 if (wasOpen && !isOpen)
                 {
                     @synchronized(strongControllerPool)
                     {
                         NSMutableSet* pool = strongControllerPool[key];

                         if (!pool)
                         {
                             pool = [NSMutableSet set];
                             controllerPool[key] = pool;
                         }
                         
                         [pool addObject:strongController];

                     }
                 }
             }
         }];
    }

    return retController;
}

- (void) addDebugLabelToView:(UIView*)view withKey:(NSString*)key
{
    UILabel* debugLabel = [[UILabel alloc] init];
    debugLabel.text = key;
    debugLabel.numberOfLines = 0;
    debugLabel.translatesAutoresizingMaskIntoConstraints = NO;
    debugLabel.userInteractionEnabled = NO;
    [view addSubview:debugLabel];
    debugLabel.textColor = [UIColor redColor];
    debugLabel.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5f];
    
    RAC(debugLabel, hidden) = [RACObserve(self, showDebugLabels) not];
    
    [view addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:debugLabel
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:view
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.f constant:0.f],
                           [NSLayoutConstraint constraintWithItem:debugLabel
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:view
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.f constant:0.f],
                           ]];
}

- (NSDictionary*) getControllers
{
    return @{};
}

- (NSInteger) tagForController:(AB_Controller)controller
{
    if ( [controller.key isKindOfClass:[NSNumber class]] )
    {
        return [(NSNumber*)(controller.key) integerValue];
    }
    
    return -1;
}

- (void) cleanPool
{
    @synchronized(controllerPool)
    {
        for (id controllerKey in [controllerPool allKeys])
        {
            if ([preloadControllers objectForKey:controllerKey])
            {
                continue;
            }
            
            NSMutableSet* mutableSet = controllerPool[controllerKey];
            if (mutableSet.count)
            {
                NSLog(@"Removing: %@", mutableSet);
                [mutableSet removeAllObjects];
            }
        }
    }
}


- (void) preloadControllers:(NSDictionary*)controllerPreloads
{
    @synchronized(controllerPool)
    {
        preloadControllers = controllerPreloads;
        
        
        for (NSString* key in [preloadControllers allKeys])
        {
            NSNumber* preloadCountObject = [preloadControllers objectForKey:key];
            int preloadCount = [preloadCountObject intValue];
            
            NSMutableSet* pool = controllerPool[key];
            if (!pool)
            {
                pool = [NSMutableSet set];
                controllerPool[key] = pool;
            }

            for (int i=0; i<preloadCount; i++)
            {
                [pool addObject:[self controllerForTag:key]];
            }
        }
    }
}

- (void) checkForRetainCycles
{
    NSMutableDictionary* backupPool = controllerPool;
    
    @synchronized(backupPool)
    {
        controllerPool = nil;

        NSDictionary* controllerDescriptions = [self getControllers];
        for (NSString* k in [controllerDescriptions allKeys])
        {
            AB_Controller c = [self controllerForTag:k];
            [[RACScheduler mainThreadScheduler] afterDelay:0.1f schedule:^
             {
                 __weak AB_Controller weakC = c;
                 [[RACScheduler mainThreadScheduler] afterDelay:0.1f schedule:^
                  {
                      if (weakC)
                      {
                          NSLog(@"%@ has a retain cycle!", k);
                      }
                      else
                      {
                          NSLog(@"%@ DOES NOT have a retain cycle", k);
                      }
                  }];
             }];
        }
        
        controllerPool = backupPool;
    }
}

- (BOOL) isInPool:(AB_Controller)controller
{
    @synchronized(controllerPool)
    {
        NSMutableSet* pool = controllerPool[controller.key];
        if (pool.count > 0)
        {
            if ([pool containsObject:controller])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
