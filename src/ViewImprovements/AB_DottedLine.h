//
//  AB_DottedLine.h
//  PPA
//
//  Created by Andrew Beck on 3/6/16.
//  Copyright © 2016 Prospect Park Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AB_DottedLine : UIView

@property(assign) IBInspectable CGFloat lineWidth;
@property(strong) IBInspectable UIColor* lineColor;
@property(assign) IBInspectable CGFloat aDashLength;
@property(assign) IBInspectable CGFloat bDashLength;
@property(assign) IBInspectable CGFloat cDashLength;
@property(assign) IBInspectable CGFloat dDashLength;
@property(assign) IBInspectable CGFloat eDashLength;
@property(assign) IBInspectable CGFloat dashPhase;

@end
