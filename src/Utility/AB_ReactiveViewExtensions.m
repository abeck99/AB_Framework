//
//  AB_ReactiveViewExtensions.m
//  Eastern
//
//  Created by phoebe on 7/8/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ReactiveViewExtensions.h"

@implementation UIGestureRecognizer(AB_ReactiveViewExtensions)

+ (UIGestureRecognizer*) addGestureCommand:(RACCommand*)command toView:(UIView*)view;
{
    UIGestureRecognizer* gesture = [[[self class] alloc] init];
    [view addGestureRecognizer:gesture];
    
    [command
     rac_liftSelector:@selector(execute:)
     withSignalsFromArray:@[
                             [gesture.rac_gestureSignal filter:^BOOL(UIGestureRecognizer* gesture)
                             {
                                 return gesture.state == UIGestureRecognizerStateRecognized;
                             }]
                            ]
     ];
    
    return gesture;
}

@end
