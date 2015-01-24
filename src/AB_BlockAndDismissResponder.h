//
//  AB_BlockAndDismissResponder.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AB_BlockAndDismissResponder : UIView<UIGestureRecognizerDelegate>
{
    NSArray* ignoreViews;
}

- (id) initInView:(UIView*)view withResponder:(UIResponder*)responder;

@property(weak) UIResponder* responder;


- (void) addIgnoreView:(UIView*) view;

- (void) close;

@end
