//
//  AB_ExpandableTextWatcher.m

//
//  Created by phoebe on 6/1/15.
//  Copyright (c) 2015 Hero. All rights reserved.
//

#import "AB_ExpandableTextWatcher.h"

static void* textUpdateContext = &textUpdateContext;

@implementation AB_ExpandableTextWatcher

- (void) awakeFromNib
{
    [self setupInitialSizes];
}

- (void) setupInitialSizes
{
    for (UITextView* textView in expandableTextViews)
    {
        [textView addObserver:self
                   forKeyPath:@"text"
                      options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                      context:textUpdateContext];
        
        [self sizeExpandableTextView:textView];
    }
}

- (void) dealloc
{
    [self closeExpandableViews];
}

- (void) closeExpandableViews
{
    for (UITextView* textView in expandableTextViews)
    {
        [textView removeObserver:self
                      forKeyPath:@"text"
                         context:textUpdateContext];
    }
    
    expandableTextViews = @[];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (textUpdateContext == context)
    {
        UITextView* textView = (UITextView*) object;
        [self sizeExpandableTextView:textView];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void) sizeExpandableTextView:(UITextView*)expandableText
{
    BOOL originallySelected = expandableText.selectable;
    expandableText.selectable = YES;
    CGFloat dif = 0.f;
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = expandableText.textAlignment;
    
    NSString* contentString = expandableText.text;
    NSDictionary* stringAttributes = @{
                                       NSFontAttributeName: expandableText.font,
                                       NSParagraphStyleAttributeName: paragraphStyle,
                                       NSForegroundColorAttributeName: expandableText.textColor ? expandableText.textColor : [UIColor blackColor],
                                       };
    
    if (expandableText.text.length > 0)
    {
        expandableText.contentInset = UIEdgeInsetsMake(0.0, 0, 0.0, 0);
        expandableText.contentOffset = CGPointMake(0.f, 0.f);
        expandableText.textContainerInset = UIEdgeInsetsMake(0.0, 0, 0.0, 0);
        expandableText.textContainer.lineFragmentPadding = 0.f;
        
        CGSize expectedLabelSize = [contentString boundingRectWithSize:
                                    CGSizeMake(expandableText.frame.size.width - 10.f, CGFLOAT_MAX)
                                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                            attributes:stringAttributes context:nil].size;
        
        CGRect expandableTextFrame = expandableText.frame;
        
        CGFloat oldExpandableSize = expandableTextFrame.size.height;
        expandableTextFrame.size.height = MAX(self.minimumSize, expectedLabelSize.height);
        
        dif = expandableTextFrame.size.height - oldExpandableSize;
    }

    if (self.resizeAll)
    {
        [self recursivelyAdjustView:expandableText by:dif];
    }
    else
    {
        CGRect f = expandableText.frame;
        f.size.height += dif;
        expandableText.frame = f;
    }
    
    expandableText.attributedText = [[NSAttributedString alloc] initWithString:contentString
                                                                    attributes:stringAttributes];
    
    
    expandableText.selectable = originallySelected;
    expandableText.contentOffset = CGPointZero;
    [self.delegate textViewsChangedSize:self];
}

- (void) recursivelyAdjustView:(UIView*)viewToAdjust by:(CGFloat)dif
{
    CGRect f = viewToAdjust.frame;
    f.size.height += dif;
    
    UIViewAutoresizing mask = viewToAdjust.autoresizingMask;
    viewToAdjust.autoresizingMask = UIViewAutoresizingNone;
    if (viewToAdjust.superview && viewToAdjust != self.rootView)
    {
        [self recursivelyAdjustView:viewToAdjust.superview by:dif];
    }
    
    viewToAdjust.frame = f;
    viewToAdjust.autoresizingMask = mask;
}

@end
