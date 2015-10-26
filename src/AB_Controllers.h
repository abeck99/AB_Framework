//
//  AB_Controllers.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AB_DataContainer.h"
#import "AB_BaseViewController.h"

@interface AB_Controllers : NSObject

- (AB_Controller) controllerForTag:(id)key;
- (AB_Controller) controllerForTag:(id)key source:(NSString*)sourceString;
- (NSInteger) tagForController:(AB_Controller)controller;

- (NSDictionary*) getControllers;

- (void) returnControllerToPool:(AB_Controller)controller;

@end

AB_Controllers* getController();
void setController(AB_Controllers* newControllers);
