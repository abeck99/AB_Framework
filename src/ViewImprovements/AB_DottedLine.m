//
//  AB_DottedLine.m
//  PPA
//
//  Created by Andrew Beck on 3/6/16.
//  Copyright © 2016 Prospect Park Alliance. All rights reserved.
//

#import "AB_DottedLine.h"
#import "AB_Funcs.h"

@interface AB_DottedLine()
{
    CAShapeLayer* shapeLayer;
}

@end

@implementation AB_DottedLine

- (void) awakeFromNib
{
    [self setup];
}

- (void) prepareForInterfaceBuilder
{
    [self setup];
}

- (void) setup
{
    [self ensureShapeLayer];
    
    CGRect rect = self.bounds;
    UIBezierPath*  path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.f, self.lineWidth/2.f)];
    [path addLineToPoint:CGPointMake(rect.size.width, self.lineWidth/2.f)];

    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = self.lineColor.CGColor;
    shapeLayer.lineWidth = self.lineWidth;
    
    NSMutableArray* mutableLineDash = [@[] mutableCopy];
    if (self.aDashLength)
    {
        [mutableLineDash addObject:@(self.aDashLength)];
    }
    if (self.bDashLength)
    {
        [mutableLineDash addObject:@(self.bDashLength)];
    }
    if (self.cDashLength)
    {
        [mutableLineDash addObject:@(self.cDashLength)];
    }
    if (self.dDashLength)
    {
        [mutableLineDash addObject:@(self.dDashLength)];
    }
    if (self.eDashLength)
    {
        [mutableLineDash addObject:@(self.eDashLength)];
    }
    shapeLayer.lineDashPattern = mutableLineDash;
    shapeLayer.lineDashPhase = self.dashPhase;
    
    shapeLayer.path = path.CGPath;
    
    [shapeLayer setNeedsDisplay];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self setup];
}

- (void) ensureShapeLayer
{
    if (shapeLayer != nil)
    {
        [shapeLayer removeFromSuperlayer];
    }
    
    shapeLayer = [CAShapeLayer layer];
    [self.layer addSublayer:shapeLayer];
}

@end
