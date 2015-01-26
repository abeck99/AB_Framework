//
//  AB_SlidingSectionViewController.m
//  AnsellInterceptApp
//
//  Created by phoebe on 15/1/26.
//  Copyright (c) 2015年 Ansell. All rights reserved.
//

#import "AB_SlidingSectionViewController.h"

@interface AB_SlidingSectionViewController ()

@end

@implementation AB_SlidingSectionViewController

- (void) openViewInView:(UIView *)insideView withParent:(AB_SectionViewController *)setParent
{
    [super openViewInView:insideView withParent:setParent];
    
    UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    
    [self.view addSubview:allViews];
    CGRect allViewsFrame = allViews.frame;
    allViewsFrame.origin.x = -1.f * sliderView.frame.size.width;
    allViews.frame = allViewsFrame;
    
    [self animateSliderOpen:NO inTime:0.f];

    searchForFonts(self.view);
    searchForFonts(allViews);
}

- (void) swipeLeft:(UISwipeGestureRecognizer*)swipe
{
    [self animateSliderOpen:NO inTime:0.2f];
}

- (void) animateSliderOpen:(BOOL)open inTime:(CGFloat) animTime
{
    CGRect allViewsFrame = allViews.frame;
    CGFloat checkSize = open ?
            fabs(allViewsFrame.origin.x) :
            fabs(allViewsFrame.origin.x + sliderView.frame.size.width);
    
    CGFloat destinationSize = open ?
            0.f :
            -1.f * sliderView.frame.size.width;
    
    if ( checkSize > 1.f )
    {
        allViewsFrame.origin.x = destinationSize;
        [allViews.layer removeAllAnimations];
        void (^animations)() = ^{
            allViews.frame = allViewsFrame;
        };
        
        if ( animTime > 0.f )
        {
            [UIView animateWithDuration:animTime animations:animations];
        }
        else
        {
            animations();
        }
    }
}

- (void) swipeRight:(UISwipeGestureRecognizer*)swipe
{
    [self animateSliderOpen:YES inTime:0.2f];
}

@end
