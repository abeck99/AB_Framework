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
}

@end

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
    return [self controllerForTag:key withData:nil];
}

- (AB_Controller) controllerForTag:(id)key withData:(id)data
{
    NSDictionary* controllerDesc = controllers[key];

    if ( !controllerDesc )
    {
        controllerDesc = controllers[@"default"];
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
    
    id defaultKey = [controllerDesc objectForKey:@"defaultController"];
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
    
    [nib instantiateWithOwner:retController options:nil];
    
    if ( !retController.view )
    {
        [NSException
         raise:NSInvalidArgumentException
         format:@"%@ probably didn't set it's view in %@", key, nibName];
        return nil;
    }
        
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

@end
