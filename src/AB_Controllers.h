//
//  AB_Controllers.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AB_DataContainer.h"
#import "AB_BaseViewController.h"

@interface AB_Controllers : NSObject

- (AB_Controller) controllerForTag:(id)tag;
- (AB_Controller) controllerForTag:(id)tag withData:(id)data;
- (NSInteger) tagForController:(AB_Controller)controller;

- (NSDictionary*) getControllers;

@end

AB_Controllers* getController();
