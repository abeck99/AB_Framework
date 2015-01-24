//
//  AB_BlockAndDismissResponder.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_BlockAndDismissResponder.h"

@implementation AB_BlockAndDismissResponder

@synthesize responder;

- (id) initInView:(UIView*)view withResponder:(UIResponder*)setResponder
{
    CGRect viewFrame = view.frame;
    viewFrame.origin = CGPointMake(0.f, 0.f);
    self = [super initWithFrame:viewFrame];
    if (self) {
        self.responder = setResponder;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        [self addGestureRecognizer:tap];
        
        tap.delegate = self;
        
        [view addSubview:self];
        ignoreViews = @[];
    }
    return self;
}

- (void) addIgnoreView:(UIView*) view
{
    NSMutableArray* mutableIgnores = [ignoreViews mutableCopy];
    [mutableIgnores addObject:view];
    ignoreViews = [NSArray arrayWithArray:mutableIgnores];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    for ( UIView* ignoreView in ignoreViews )
    {
        CGPoint pointInMyself = [touch locationInView:ignoreView];
        
        if ( pointInMyself.x >= 0 && pointInMyself.y >= 0 && pointInMyself.x < self.frame.size.width && pointInMyself.y < self.frame.size.height )
        {
            return NO;
        }
    }
    
    return YES;
}

- (void) close
{
    [self.responder resignFirstResponder];
    [self removeFromSuperview];
    
    for ( UIGestureRecognizer* rec in [self.gestureRecognizers copy] )
    {
        [self removeGestureRecognizer:rec];
    }
}

@end
