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

    [controller openInView:self
            withViewParent:viewController
                 inSection:section];
    
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = controller.height;
    self.frame = selfFrame;
    
    self.backgroundColor = _view.backgroundColor;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    _view.frame = self.bounds;
    _view.hidden = self.frame.size.height <= 1.00001f;

//    if ([_controller isKindOfClass:[AB_BaseCellViewController class]])
//    {
//        AB_BaseCellViewController* c = (AB_BaseCellViewController*)_controller;
//        
//        c.isExpanded = self.frame.size.height > 1.00001f;
//        _view.hidden = self.frame.size.height <= 1.00001f;
//    }
//    else
//    {
//        _view.hidden = self.frame.size.height <= 1.00001f;
//    }
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

- (CGSize) sizeThatFits:(CGSize)size
{
    [_view layoutIfNeeded];
    if (self.header)
    {
        size.height = self.header.openAmount * _controller.height;
        size.height = MAX(size.height, 1.f);
    }
    else
    {
        size.height = _controller.height;
    }
    return size;
}

@end

@implementation AB_BaseCellViewController

//- (void) bind
//
//{
//    [super bind];
//    
//    NSArray* capturedOpenViews = openViews;
//    NSArray* capturedClosedViews = closedViews;
//    
//    
//    [[RACObserve(self, isExpanded) distinctUntilChanged]
//     subscribeNext:^(NSNumber* isExpandedO)
//     {
//         BOOL isExpanded = [isExpandedO boolValue];
//         
//         for (UIView* v in capturedOpenViews)
//         {
//             v.hidden = !isExpanded;
//         }
//
//         for (UIView* v in capturedClosedViews)
//         {
//             v.hidden = isExpanded;
//         }
//     }];
//}

@end