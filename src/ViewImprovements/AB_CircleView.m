//
//  AB_CircleView.m
//  GoHeroClient
//
//  Created by phoebe on 15/1/9.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import "AB_CircleView.h"

@interface AB_CircleView()
{
    CGFloat _progress;
}

@end

@implementation AB_CircleView

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.circleColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
}

- (void) setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (CGFloat) progress
{
    return _progress;
}

@synthesize circleColor;
@synthesize thickness;

- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat border = [self.thickness floatValue];
    
    if ( _progress > 0.f )
    {
        CGContextBeginPath(context);
        CGPoint center = CGPointMake(rect.size.width/2.f, rect.size.height/2.f);
        CGPoint start = CGPointMake(rect.size.width/2.f, border);
        CGFloat radius = (rect.size.width - border*2.f) / 2;
        CGFloat startAngle = -(float)M_PI / 2.f;
        CGFloat endAngle = ( _progress * 2 * (float)M_PI) + startAngle;
        
        [self.circleColor setStroke];
        CGContextMoveToPoint(context, start.x, start.y);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextSetLineWidth(context, border);
        CGContextStrokePath(context);
    }
}

@end
