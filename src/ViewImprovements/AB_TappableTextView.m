//
//  AB_TappableTextView.m
//  GoHeroClient
//
//  Created by phoebe on 15/1/5.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import "AB_TappableTextView.h"

@interface AB_TappableTextView()
{
    UITapGestureRecognizer* tapGesture;
    __weak id<UITextViewDelegate> realDelegate;
    int _maxCharacterCount;
}

@end

@implementation AB_TappableTextView

@synthesize disabled;

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    if ( self = [super initWithFrame:frame textContainer:textContainer] )
    {
        [self customInit];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self customInit];
}

- (void) customInit
{
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)];
    [self addGestureRecognizer:tapGesture];
    [super setDelegate:self];
}

- (void) buttonTapped:(UITapGestureRecognizer*)rec
{
    if ( ![self.disabled boolValue] )
    {
        if ( ![self isFirstResponder] )
        {
            self.editable = YES;
            [self becomeFirstResponder];
        }
    }
}

- (void)dealloc
{
    for ( UIGestureRecognizer* rec in [self.gestureRecognizers copy] )
    {
        [self removeGestureRecognizer:rec];
    }
    
    self.delegate = nil;
}

- (void) setDelegate:(id<UITextViewDelegate>)delegate
{
    [super setDelegate:nil];
    realDelegate = delegate != self ? delegate : nil;
    [super setDelegate:delegate ? self : nil];
}

- (void) textViewDidBeginEditing:(UITextView*)textView
{
    tapGesture.enabled = NO;
    
    if ( [realDelegate respondsToSelector:_cmd] )
    {
        [realDelegate textViewDidBeginEditing:textView];
    }
}

- (void) textViewDidEndEditing:(UITextView*)textView
{
    tapGesture.enabled = NO;
    
    if ( [realDelegate respondsToSelector:_cmd] )
    {
        [realDelegate textViewDidEndEditing:textView];
    }
}

- (void) setMaxCharacterCount:(int)maxCharacterCount
{
    _maxCharacterCount = maxCharacterCount;
    [self showLabel];
}

- (int) maxCharacterCount
{
    return _maxCharacterCount;
}

- (void) showLabel
{
    characterCountLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)self.text.length, _maxCharacterCount];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self showLabel];

    if ( [realDelegate respondsToSelector:_cmd] )
    {
        [realDelegate textViewDidChange:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString* newString = textView.text;
    newString = [newString stringByReplacingCharactersInRange:range withString:text];
    if ( _maxCharacterCount > 0 && newString.length > _maxCharacterCount )
    {
        return NO;
    }

    if ( [realDelegate respondsToSelector:_cmd] )
    {
        return [realDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }

    return YES;
}

- (BOOL) isEditable
{
    return YES;
}

- (BOOL)respondsToSelector:(SEL)s
{
    return [super respondsToSelector:s] || [realDelegate respondsToSelector:s];
}

- (id)forwardingTargetForSelector:(SEL)s
{
    return [realDelegate respondsToSelector:s] ? realDelegate : [super forwardingTargetForSelector:s];
}

- (BOOL) canBecomeFirstResponder
{
    if ( [self.disabled boolValue] )
    {
        return NO;
    }
    
    return [super canBecomeFirstResponder];
}

@end
