//
//  AB_Popup.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_Popup.h"

static void* textUpdateContext = &textUpdateContext;

@implementation AB_Popup

@synthesize viewController;
@synthesize blockingView;

// Overrides
+ (UINib*) baseNib
{
    return nil;
}

+ (void) load
{
    [[self class] baseNib];
}

- (void) setup
{
    for ( UIView* view in roundedViews )
    {
        view.layer.cornerRadius = 10.f;
    }
    
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
        
        CGSize expectedLabelSize = [contentString boundingRectWithSize:
                                    CGSizeMake(expandableText.frame.size.width - 10.f, CGFLOAT_MAX)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                     attributes:stringAttributes context:nil].size;
        
        CGRect expandableTextFrame = expandableText.frame;
        
        CGFloat oldExpandableSize = expandableTextFrame.size.height;
        expandableTextFrame.size.height = expectedLabelSize.height;
        
        dif = expandableTextFrame.size.height - oldExpandableSize;
    }

    [self recursivelyAdjustView:expandableText by:dif];
    
    expandableText.attributedText = [[NSAttributedString alloc] initWithString:contentString
                                                                    attributes:stringAttributes];
    
    
    [self animateToCenter];
}

- (void) recursivelyAdjustView:(UIView*)viewToAdjust by:(CGFloat)dif
{
    CGRect f = viewToAdjust.frame;
    f.size.height += dif;
    
    UIViewAutoresizing mask = viewToAdjust.autoresizingMask;
    viewToAdjust.autoresizingMask = UIViewAutoresizingNone;
    if (viewToAdjust.superview && viewToAdjust != self)
    {
        [self recursivelyAdjustView:viewToAdjust.superview by:dif];
    }

    viewToAdjust.frame = f;
    viewToAdjust.autoresizingMask = mask;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

+ (instancetype) get
{
    UINib* nib = [[self class] baseNib];
    NSArray* arrayOfViews = [nib instantiateWithOwner:nil options:nil];
    AB_Popup* view = [arrayOfViews objectAtIndex:0];
    return view;
}

- (IBAction) closeSelf:(id)sender
{
    [self closeExpandableViews];
    [viewController dismissPopup:self];
}

- (void) closeFromBackgroundTap:(id)sender
{
    [self closeExpandableViews];
    [self closeSelf:sender];
}

- (void) animateToCenter
{
    CGRect popupFrame = self.frame;
    popupFrame.origin.y = self.superview.frame.size.height / 2.f - popupFrame.size.height / 2.f;
    [UIView animateWithDuration:0.4f
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                                     self.frame = popupFrame;
                                     self.alpha = 1.f;
                                 }
                                 completion:nil];
}

- (BOOL) allowMultipleOpens
{
    return YES;
}

@end


@implementation AB_BaseViewController (PopupExtension)

- (AB_Popup*) showPopup:(Class)popupClass
{
    AB_Popup* newPopup = [popupClass get];
    newPopup.viewController = self;
    
    if (![newPopup allowMultipleOpens])
    {
        for (UIView* subview in self.view.subviews)
        {
            if ([subview class] == popupClass)
            {
                return nil;
            }
        }
    }
    
    CGRect blockingFrame = self.view.frame;
    blockingFrame.origin = CGPointZero;
    UIView* blockingView = [[UIView alloc] initWithFrame:blockingFrame];
    [self.view addSubview:blockingView];
    blockingView.backgroundColor = [UIColor colorWithRed:21.f/255.f
                                                   green:21.f/255.f
                                                    blue:21.f/255.f
                                                   alpha:0.25f];
    blockingView.userInteractionEnabled = YES;
    blockingView.alpha = 0.f;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:newPopup action:@selector(closeFromBackgroundTap:)];
    [blockingView addGestureRecognizer:tap];
    
    newPopup.blockingView = blockingView;
    
    
    CGRect popupFrame = newPopup.frame;
    popupFrame.origin.x = self.view.frame.size.width / 2.f - newPopup.frame.size.width / 2.f;
    popupFrame.origin.y = self.view.frame.size.height;
    newPopup.alpha = 0.f;
    newPopup.frame = popupFrame;
    
    [self.view addSubview:newPopup];
    
    [newPopup animateToCenter];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         blockingView.alpha = 1.f;
                     }];
    
    return newPopup;
}

- (void) dismissPopup:(AB_Popup*)popup
{
    CGRect popupFrame = popup.frame;
    popupFrame.origin.y = 0.f - popupFrame.size.height;
    [UIView animateWithDuration:0.4f
                     animations:^{
                         popup.frame = popupFrame;
                         popup.alpha = 0.f;
                         popup.blockingView.alpha = 0.f;
                     }
                     completion:^(BOOL finished){
                         [popup removeFromSuperview];
                         [popup.blockingView removeFromSuperview];
                         for ( UIGestureRecognizer* rec in [popup.blockingView.gestureRecognizers copy] )
                         {
                             [popup.blockingView removeGestureRecognizer:rec];
                         }
                     }];
    
}


@end
