//
//  AB_Popup.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_Popup.h"

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
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (id) init
{
    self = [super initWithFrame:CGRectMake(0,0,10,10)];
    if ( self )
    {
        UINib* nib = [[self class] baseNib];
        
        NSArray* arrayOfViews = [nib instantiateWithOwner:nil options:nil];
        
        if([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        id view = [arrayOfViews objectAtIndex: 0];
        self = view;
        [self setup];
    }
    
    return self;
}

- (IBAction) closeSelf:(id)sender
{
    [viewController dismissPopup:self];
}

- (void) closeFromBackgroundTap:(id)sender
{
    [self closeSelf:sender];
}

@end


@implementation AB_BaseViewController (PopupExtension)

- (AB_Popup*) showPopup:(Class)popupClass
{
    AB_Popup* newPopup = [((AB_Popup*) [popupClass alloc]) init];
    newPopup.viewController = self;
    
    searchForFonts(newPopup);
    
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
    
    popupFrame.origin.y = self.view.frame.size.height / 2.f - newPopup.frame.size.height / 2.f;
    [UIView animateWithDuration:0.4f animations:^{
        newPopup.frame = popupFrame;
        newPopup.alpha = 1.f;
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
