//
//  AB_MixGesturesDelegate.m
//  Eastern
//
//  Created by phoebe on 7/3/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_MixGesturesDelegate.h"

@implementation AB_MixGesturesDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}


@end
