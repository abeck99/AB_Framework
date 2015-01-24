//
//  AB_BlockCallbackView.m
//  GoHeroClient
//
//  Created by phoebe on 15/1/10.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import "AB_BlockCallbackView.h"

@implementation AB_BlockCallbackView

@synthesize callbackBlock;

- (id) initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        [self setup];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void) setup
{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tap];
}

- (void) tapped:(UITapGestureRecognizer*)tapRec
{
    if ( self.callbackBlock )
    {
        self.callbackBlock();
    }
}

- (void) dealloc
{
    for ( UIGestureRecognizer* rec in [self.gestureRecognizers copy] )
    {
        [self removeGestureRecognizer:rec];
    }
}

@end
