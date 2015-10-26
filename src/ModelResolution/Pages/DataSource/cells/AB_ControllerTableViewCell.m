//
//  AB_ControllerTableViewCell.m
//  AB
//
//  Created by Andrew on 09/15/2015.
//

#import "AB_ControllerTableViewCell.h"
#import "AB_ControllerResolver.h"

@interface AB_ControllerTableViewCell()
{
    AB_Controller _controller;
    UIView* _view;
}

@end

@implementation AB_ControllerTableViewCell

- (void) setController:(AB_Controller)controller
    withViewController:(AB_Controller)viewController
               section:(AB_Section)section
{
    _controller = controller;
    _view = controller.view;
    
    CGRect viewFrame = _view.frame;
    viewFrame.origin = CGPointMake(0.f, 0.f);
    viewFrame.size.width = self.bounds.size.width;

    _view.autoresizingMask = UIViewAutoresizingNone;
//    UIViewAutoresizingFlexibleLeftMargin |
//    UIViewAutoresizingFlexibleRightMargin |
//    UIViewAutoresizingFlexibleWidth |
//    UIViewAutoresizingFlexibleTopMargin |
//    UIViewAutoresizingFlexibleHeight |
//    UIViewAutoresizingFlexibleBottomMargin;

    [controller openInView:self
            withViewParent:viewController
                 inSection:section];
    
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    _view.frame = self.bounds;
}

- (void) prepareForReuse
{
    [_controller closeView];
    [_controller.view removeFromSuperview];
    _controller = nil;
}

- (void) dealloc
{
    [self prepareForReuse];
}

@end