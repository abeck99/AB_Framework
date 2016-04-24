//
//  AB_GradientView.m
//  PPA
//
//  Created by Andrew Beck on 12/3/15.
//  Copyright © 2015 Prospect Park Alliance. All rights reserved.
//

#import "AB_GradientView.h"

@interface NSMutableArray(GradientCategory)

- (void) addObjectIfNotNil:(id)obj;

@end

@interface AB_GradientView()
{
    CAGradientLayer* gradientLayer;
}

@end

@implementation AB_GradientView

- (void) prepareForInterfaceBuilder
{
    [self setup];
}

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

- (void) layoutSubviews
{
    [super layoutSubviews];
    gradientLayer.frame = self.layer.bounds;
}

- (void) setup
{
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.layer.bounds;
    gradientLayer.startPoint = self.gradientStartPoint;
    gradientLayer.endPoint = self.gradientEndPoint;
    
    NSMutableArray* colors = [@[] mutableCopy];
    [colors addObjectIfNotNil:(id)self.a.CGColor];
    [colors addObjectIfNotNil:(id)self.b.CGColor];
    [colors addObjectIfNotNil:(id)self.c.CGColor];
    [colors addObjectIfNotNil:(id)self.d.CGColor];
    [colors addObjectIfNotNil:(id)self.e.CGColor];
    [colors addObjectIfNotNil:(id)self.f.CGColor];
    gradientLayer.colors = colors;

    self.backgroundColor = [UIColor clearColor];
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

@end

@implementation NSMutableArray(GradientCategory)

- (void) addObjectIfNotNil:(id)obj
{
    if (obj)
    {
        [self addObject:obj];
    }
}

@end
