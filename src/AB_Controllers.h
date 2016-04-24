//
//  AB_Controllers.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AB_DataContainer.h"
#import "AB_BaseViewController.h"

@interface AB_Controllers : NSObject

+ (AB_Controllers*) get;
+ (void) set:(AB_Controllers*)newControllers;

- (AB_Controller) controllerForTag:(id)key;
- (AB_Controller) controllerForTag:(id)key source:(NSString*)sourceString;
- (NSInteger) tagForController:(AB_Controller)controller;

- (NSDictionary*) getControllers;

- (void) preloadControllers:(NSDictionary*)controllerPreloads;

- (void) cleanPool;

@property(assign) BOOL showDebugLabels;

- (void) checkForRetainCycles;

- (BOOL) isInPool:(AB_Controller)controller;

@end
