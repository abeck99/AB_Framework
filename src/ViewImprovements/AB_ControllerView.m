//
//  AB_ControllerView.m
//  PPA
//
//  Created by Andrew Beck on 12/2/15.
//  Copyright © 2015 Prospect Park Alliance. All rights reserved.
//

#import "AB_ControllerView.h"
#import "ReactiveCocoa.h"

@interface AB_ControllerView()

@property(strong) AB_Controller internalController;

@end

@implementation AB_ControllerView

- (instancetype) init
{
    if (self = [super init])
    {
        [self setup];
    }
    return self;
}

- (void) awakeFromNib
{
    [self setup];
}

- (void) setup
{
    @weakify(self)
    [RACObserve(self, controller)
     subscribeNext:^(AB_Controller newController)
     {
         @strongify(self)
         [self.internalController closeView];
         [self.internalController.view removeFromSuperview];

         [newController openInView:self
                    withViewParent:self.parentController
                         inSection:self.parentSectionController];
         
         [self sendSubviewToBack:newController.view];

         self.internalController = newController;
     }];
}

- (void) dealloc
{
    self.controller = nil;
}

- (AB_Controller) parentController
{
    return (AB_Controller) parentController;
}

- (void) setParentController:(AB_Controller)parentController_
{
    parentController = parentController_;
}

- (AB_Section) parentSectionController
{
    return (AB_Section) parentSectionController;
}

- (void) setParentSectionController:(AB_Section)parentSectionController_
{
    parentSectionController = parentSectionController_;
}

@end
