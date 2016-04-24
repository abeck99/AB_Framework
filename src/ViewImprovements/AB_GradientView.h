//
//  AB_GradientView.h
//  PPA
//
//  Created by Andrew Beck on 12/3/15.
//  Copyright © 2015 Prospect Park Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AB_GradientView : UIView

@property(assign) IBInspectable CGPoint gradientStartPoint;
@property(assign) IBInspectable CGPoint gradientEndPoint;

@property(strong) IBInspectable UIColor* a;
@property(strong) IBInspectable UIColor* b;
@property(strong) IBInspectable UIColor* c;
@property(strong) IBInspectable UIColor* d;
@property(strong) IBInspectable UIColor* e;
@property(strong) IBInspectable UIColor* f;

@end
