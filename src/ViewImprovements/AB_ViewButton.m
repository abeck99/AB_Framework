//
//  AB_ViewButton.m
//  Eastern
//
//  Created by phoebe on 7/4/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ViewButton.h"
#import "ReactiveCocoa.h"
#import "Underscore.h"

@interface AB_ViewButton()
{
    UIView* currentView_;
}

@end

@implementation AB_ViewButton

- (NSDictionary*) statesToViews
{
    return
    @{
        @(UIControlStateNormal): normalView,
        @(UIControlStateHighlighted): normalHighlightedView,
        @(UIControlStateHighlighted | UIControlStateDisabled): normalHighlightedDisabledView,
        @(UIControlStateHighlighted | UIControlStateSelected): selectedHighlightedView,
        @(UIControlStateHighlighted | UIControlStateDisabled | UIControlStateSelected): selectedHighlightedDisabledView,
        @(UIControlStateDisabled): normalDisabledView,
        @(UIControlStateDisabled | UIControlStateSelected): selectedDisabledView,
        @(UIControlStateSelected): selectedView,
        };
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setupViewButton];
}

- (void) prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    [self setTitle:@"Temp Label..." forState:UIControlStateNormal];
}

- (void) setupViewButton
{
    NSDictionary* statesToViews = [self statesToViews];
    
    Underscore.array([statesToViews allValues])
    .each(^(UIView* buttonView)
          {
              buttonView.userInteractionEnabled = NO;
          });

    @weakify(self)
    RACSignal* controlStateSignal = [[RACSignal merge:@[
                                                        RACObserve(self, selected),
                                                        RACObserve(self, highlighted),
                                                        RACObserve(self, enabled)
                                                        ]
                                      ]
                                     map:^(id _)
                                     {
                                         // Looks like self.state is not KVO compliant...
                                         @strongify(self)
                                         return @(self.state);
                                     }];
    
    [self rac_liftSelector:@selector(displayView:)
      withSignalsFromArray:@[[controlStateSignal
                              map:^(NSNumber* stateObject)
                              {
                                  return statesToViews[stateObject];
                              }]
                             ]
     ];
}

- (void) displayView:(UIView*)view
{
    if (view == currentView_)
    {
        return;
    }
    [currentView_ removeFromSuperview];
    currentView_ = view;
    CGRect newFrame = self.bounds;
    
    if (!self.stretchesView)
    {
        newFrame = CGRectMake(
                              self.bounds.size.width/2.f - view.frame.size.width/2.f,
                              self.bounds.size.height/2.f - view.frame.size.height/2.f,
                              view.frame.size.width,
                              view.frame.size.height
                              );
    }

    currentView_.frame = newFrame;
    [self addSubview:currentView_];
}

- (UIView*) currentView
{
    return currentView_;
}

@end
