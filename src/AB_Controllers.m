//
//  AB_Controllers.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_Controllers.h"
#import "AB_SectionViewController.h"

@interface AB_Controllers()
{
    NSDictionary* controllers;
    NSMutableDictionary* nibs;
    NSMutableDictionary* controllerPool;
}

@end

// TODO: Make this into something that each controller keeps a reference to the controller factory, this global call is not good
AB_Controllers* gControllers = nil;

AB_Controllers* getController()
{
    return gControllers;
}

void setController(AB_Controllers* newControllers)
{
    gControllers = newControllers;
}

@implementation AB_Controllers

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

    NSMutableArray* pool = controllerPool[key];
    if (pool.count > 0)
    {
        AB_Controller retController = pool[0];
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
    
    
    if ( !retController.view )
    {
        [NSException
         raise:NSInvalidArgumentException
         format:@"%@ probably didn't set it's view in %@", key, nibName];
        return nil;
    }
    
    retController.sourceString = @"initial-setup";
    [retController bind];
    retController.sourceString = sourceString;
    
    return retController;
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

- (void) returnControllerToPool:(AB_Controller)controller
{
    id key = controller.key;
    
    NSMutableArray* pool = controllerPool[key];
    if (!pool)
    {
        pool = [@[] mutableCopy];
        controllerPool[key] = pool;
    }
    
    [pool addObject:controller];
}

@end
