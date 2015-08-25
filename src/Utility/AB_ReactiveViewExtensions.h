//
//  AB_ReactiveViewExtensions.h
//  Eastern
//
//  Created by phoebe on 7/8/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"

@interface UIGestureRecognizer(AB_ReactiveViewExtensions)

+ (UIGestureRecognizer*) addGestureCommand:(RACCommand*)command toView:(UIView*)view;

@end
