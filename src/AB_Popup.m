//
//  AB_Popup.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_Popup.h"
#import "Underscore.h"

#define POPUP_DEBUG 0

@interface AB_Popup()
{
}
@property(assign) PopupState popupState;

@end

@implementation AB_Popup

@synthesize viewController;

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
        expandableTextFrame.size.height = expectedLabelSize.height;
        
        dif = expandableTextFrame.size.height - oldExpandableSize;
    }

    RecursivelyAdjustView(self, expandableText, dif);
    
    expandableText.attributedText = [[NSAttributedString alloc] initWithString:contentString
                                                                    attributes:stringAttributes];
    
    
    expandableText.selectable = originallySelected;
    [self recalculateDestination];
}
        
- (void) recalculateDestination
{
    switch (self.popupState)
    {
        case PopupState_ReturningToPending:
            [self returnToPending];
            break;
        case PopupState_Pending:
            [self moveToPending];
            break;
        case PopupState_Closing:
        case PopupState_Closed:
            [self close];
            break;
        case PopupState_Opening:
        case PopupState_Opened:
            [self reentrySafeOpen];
            break;
    }
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.popupState = PopupState_Pending;
    
    for ( UIView* view in roundedViews )
    {
        view.layer.cornerRadius = 10.f;
    }
    
    for (UITextView* textView in expandableTextViews)
    {
        @weakify(self)
        [[RACObserve(textView, text)
          startWith:textView.text]
          subscribeNext:^(NSString* newText)
          {
              @strongify(self)
              [self sizeExpandableTextView:textView];
          }];
    }
}

+ (instancetype) get
{
    UINib* nib = [[self class] baseNib];
    NSArray* arrayOfViews = [nib instantiateWithOwner:nil options:nil];
    AB_Popup* view = [arrayOfViews objectAtIndex:0];
    return view;
}

- (CGRect) pendingFrame
{
    CGRect parentBounds = viewController.view.bounds;
    CGRect popupFrame = [self centerFrame];
    switch (self.revealDirection)
    {
        default:
        case None:
            break;
        case Top:
            popupFrame.origin.y -= parentBounds.size.height / 2.f;
            break;
        case Bottom:
            popupFrame.origin.y += parentBounds.size.height / 2.f + popupFrame.size.height / 2.f;
            break;
        case Left:
            popupFrame.origin.x -= parentBounds.size.width / 2.f;
            break;
        case Right:
            popupFrame.origin.x += parentBounds.size.width / 2.f + popupFrame.size.width / 2.f;
            break;
    }
    
    return popupFrame;
}

- (CGRect) centerFrame
{
    CGRect parentBounds = viewController.view.bounds;
    CGRect popupFrame = self.frame;
    popupFrame.origin.x = parentBounds.size.width / 2.f - popupFrame.size.width / 2.f;
    popupFrame.origin.y = parentBounds.size.height / 2.f - popupFrame.size.height / 2.f;
    return popupFrame;
}

- (CGRect) closedFrame
{
    CGRect parentBounds = viewController.view.bounds;
    CGRect popupFrame = [self centerFrame];
    switch (self.revealDirection)
    {
        default:
        case None:
            break;
        case Top:
            popupFrame.origin.y += parentBounds.size.height / 2.f + popupFrame.size.height / 2.f;
            break;
        case Bottom:
            popupFrame.origin.y -= parentBounds.size.height / 2.f;
            break;
        case Left:
            popupFrame.origin.x += parentBounds.size.width / 2.f + popupFrame.size.width / 2.f;
            break;
        case Right:
            popupFrame.origin.x -= parentBounds.size.width / 2.f;
            break;
    }
    
    return popupFrame;
}

- (void) animate:(void(^)())animateBlock
        complete:(void(^)(BOOL finished))completeBlock
        animated:(BOOL)isAnimated
{
    if (isAnimated)
    {
        [UIView animateWithDuration:[self animationSpeed]
                              delay:0.f
             usingSpringWithDamping:1.f
              initialSpringVelocity:0.f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:animateBlock
                         completion:completeBlock];
    }
    else
    {
        animateBlock();
        completeBlock(YES);
    }
}

- (void) moveToPending
{
    self.frame = [self pendingFrame];
    self.alpha = 0.f;
    self.popupState = PopupState_Pending;
}

- (void) returnToPending
{
    UIView* curBlockingView = blockingView;
    for ( UIGestureRecognizer* rec in [blockingView.gestureRecognizers copy] )
    {
        [blockingView removeGestureRecognizer:rec];
    }
    blockingView = nil;

    self.popupState = PopupState_ReturningToPending;
    
    [self
     animate:^{
         curBlockingView.alpha = 0.f;
     }complete:^(BOOL finished){
         // TODO: This will skip if moving to pending and the destination is recalculated...
         [curBlockingView removeFromSuperview];
     }animated:YES];
    
    [self
     animate:^
     {
         self.frame = [self closedFrame];
         self.alpha = 0.f;
     }
     complete:^(BOOL finished)
     {
         if (finished && self.popupState == PopupState_ReturningToPending)
         {
             self.frame = [self pendingFrame];
             self.popupState = PopupState_Pending;
         }
     }
     animated:YES];
}

- (void) open
{
    UIView* containerView = viewController.view;
    CGRect blockingFrame = containerView.bounds;
    blockingView = [[UIView alloc] initWithFrame:blockingFrame];
    
    [containerView insertSubview:blockingView belowSubview:self];

    blockingView.backgroundColor = self.blockingViewColor
        ? self.blockingViewColor
        : [UIColor colorWithRed:21.f/255.f
                      green:21.f/255.f
                       blue:21.f/255.f
                      alpha:0.25f];
    blockingView.userInteractionEnabled = YES;
    blockingView.alpha = 0.f;
    blockingView.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin    |
    UIViewAutoresizingFlexibleWidth         |
    UIViewAutoresizingFlexibleRightMargin   |
    UIViewAutoresizingFlexibleTopMargin     |
    UIViewAutoresizingFlexibleHeight        |
    UIViewAutoresizingFlexibleBottomMargin;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(closeFromBackgroundTap:)];
    [blockingView addGestureRecognizer:tap];
 
    [self reentrySafeOpen];
}

- (void) reentrySafeOpen
{
    self.popupState = PopupState_Opening;
    [self
     animate:^
     {
         blockingView.alpha = 1.f;
     }
     complete:nil animated:YES];

    [self
    animate:^
    {
        self.frame = [self centerFrame];
        self.alpha = 1.f;
    }
    complete:^(BOOL finished)
     {
        if (finished && self.popupState == PopupState_Opening)
        {
            self.popupState = PopupState_Opened;
        }
     }
     animated:YES];
}

- (void) close
{
    BOOL wasClosed = self.popupState == PopupState_Closed || self.popupState == PopupState_Closing;
    if (wasClosed)
    {
        return;
    }

    BOOL wasOpen = self.popupState == PopupState_Opening || self.popupState == PopupState_Opened;
    if (!wasOpen)
    {
        self.popupState = PopupState_Closed;
        [self removeFromSuperview];
    }
    else
    {
        self.popupState = PopupState_Closing;

        [self
         animate:^
         {
             blockingView.alpha = 0.f;
         }
         complete:^(BOOL finished)
         {
             if (finished)
             {
                 [blockingView removeFromSuperview];
                 for ( UIGestureRecognizer* rec in [blockingView.gestureRecognizers copy] )
                 {
                     [blockingView removeGestureRecognizer:rec];
                 }
                 blockingView = nil;
             }
         }
         animated:YES];

        [self
         animate:^
         {
             self.frame = [self closedFrame];
             self.alpha = 0.f;
         }
         complete:^(BOOL finished)
         {
             if (finished && self.popupState == PopupState_Closing)
             {
                 self.popupState = PopupState_Closed;
                 [self removeFromSuperview];
             }
         }
         animated:YES];
    }
}

- (IBAction) closeSelf:(id)sender
{
    [self close];
}

- (void) closeFromBackgroundTap:(id)sender
{
    [self close];
}

- (CGFloat) animationSpeed
{
    return 0.4f;
}

- (BOOL) isOverlayPopup
{
    return NO;
}

- (int) popupPriority
{
    return 0;
}

- (RACSignal*) stateSignal
{
    return [RACObserve(self, popupState) startWith:@(self.popupState)];
}

- (void) dealloc
{
#if POPUP_DEBUG
    NSLog(@"%@ Dealloced!", [self class]);
#endif
}

@end

@implementation UIView(PopupExtension)

- (USArrayWrapper*) popups
{
    return
    Underscore.array(self.subviews)
    .filter(^BOOL(AB_Popup* popup)
            {
                return
                [popup isKindOfClass:[AB_Popup class]]
                && popup.popupState != PopupState_Closing
                && popup.popupState != PopupState_Closed;
            });
}

@end

@implementation UIViewController (PopupExtension)

- (USArrayWrapper*) popups
{
    return
    Underscore.array(self.view.subviews)
    .filter(^BOOL(AB_Popup* popup)
            {
                return
                [popup isKindOfClass:[AB_Popup class]]
                && popup.viewController == self
                && popup.popupState != PopupState_Closing
                && popup.popupState != PopupState_Closed;
            });
}

- (USArrayWrapper*) blockingPopups
{
    return
    [self popups]
    .filter(^BOOL(AB_Popup* popup)
            {
                return ![popup isOverlayPopup];
            });
}

- (USArrayWrapper*) overlayPopups
{
    return
    [self popups]
    .filter(^BOOL(AB_Popup* popup)
            {
                return [popup isOverlayPopup];
            });
}

- (NSString*)popupStateDisplayName:(PopupState)state
{
    return @{
             @(PopupState_Pending): @"Pending",
             @(PopupState_ReturningToPending): @"ReturningToPending",
             @(PopupState_Opening): @"Opening",
             @(PopupState_Opened): @"Opened",
             @(PopupState_Closing): @"Closing",
             @(PopupState_Closed): @"Closed",
             }[@(state)];
}

- (void) dispatchPopups
{
    AB_Popup* currentPopup = [self blockingPopups].first;
    if (currentPopup.popupState == PopupState_Pending ||
        currentPopup.popupState == PopupState_ReturningToPending)
    {
        [currentPopup open];
    }
    
    [self blockingPopups]
    .filter(^BOOL(AB_Popup* popup)
            {
                return
                popup != currentPopup &&
                (
                     popup.popupState == PopupState_Opening ||
                     popup.popupState == PopupState_Opened
                );
            })
    .each(^(AB_Popup* popup)
            {
                [popup returnToPending];
            });
}

- (AB_Popup*) showPopup:(Class)popupClass
{
    AB_Popup* newPopup = [popupClass get];
    newPopup.viewController = self;
    
    AB_Popup* popupAboveNew =
    [self popups]
    .filter(^BOOL(AB_Popup* popup)
            {
                return [popup popupPriority] < [newPopup popupPriority];
            })
    .first;
    
    if (!popupAboveNew)
    {
        popupAboveNew =
        [self overlayPopups]
        .first;
    }
    
    if (!popupAboveNew)
    {
        [self.view addSubview:newPopup];
    }
    else
    {
        [self.view insertSubview:newPopup belowSubview:popupAboveNew];
    }

    [newPopup setup];

    [newPopup moveToPending];
    @weakify(self)
    [[[newPopup.stateSignal
       filter:^BOOL(NSNumber* state)
       {
           return [state integerValue] == PopupState_Closing ||
                  [state integerValue] == PopupState_Closed;
       }]
      take:1]
     subscribeNext:^(id _)
     {
         @strongify(self)
         [self dispatchPopups];
     }];
    
#if POPUP_DEBUG
    [newPopup.stateSignal
     subscribeNext:^(id _)
     {
         @strongify(self)
         NSString* allPopups =
         [Underscore.array(self.view.subviews)
          .filter(^BOOL(AB_Popup* popup)
                  {
                      return [popup isKindOfClass:[AB_Popup class]];
                  })

          .map(^NSString*(AB_Popup* popup)
               {
                   return [NSString stringWithFormat:@"%@ (%@)", [popup class], [self popupStateDisplayName:popup.popupState]];
               })
          .unwrap componentsJoinedByString:@", "];
         
         NSLog(@"Popups: %@", allPopups);
     }];
#endif

    if ([newPopup isOverlayPopup])
    {
        [newPopup open];
    }
    else
    {
        [self dispatchPopups];
    }

    return newPopup;
}

- (void) closeAllPopups
{
    [self popups]
    .each(^(AB_Popup* popup)
          {
              [popup close];
          });
}

- (void) closeAllPopupsOfType:(Class)popupClass
{
    [self popups]
    .filter(^BOOL(id obj)
            {
                return [obj isKindOfClass:popupClass];
            })
    .each(^(AB_Popup* popup)
            {
              [popup close];
            });
}

- (void) closeAllPopupsExcept:(NSArray*)popupClasses
{
    [self popups]
    .filter(^BOOL(id obj)
            {
                return ![popupClasses containsObject:[obj class]];
            })
    .each(^(AB_Popup* popup)
          {
              [popup close];
          });
}

- (void) closeAllPopupsOfTypes:(NSArray*)popupClasses
{
    [self popups]
    .filter(^BOOL(id obj)
            {
                return [popupClasses containsObject:[obj class]];
            })
    .each(^(AB_Popup* popup)
          {
              [popup close];
          });
}

@end
