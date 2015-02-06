//
//  AB_Funcs.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_Funcs.h"

void printAllSubviews(UIView* view, int depth)
{
    NSString* tabs = @"";
    for ( int i=0; i<depth; i++ )
    {
        tabs = [NSString stringWithFormat:@"\t%@", tabs];
    }
    
    NSLog(@"%@%@", tabs, view);

    CGFloat r,g,b,a;
    [view.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    NSLog(@"%@BGColor: %g, %g, %g, %g, %@", tabs, r, g, b, a, view.opaque ? @"Opaque" : @"Transparent");

    for ( UIView* subview in view.subviews )
    {
        printAllSubviews(subview, depth+1);
    }
}

void searchForFonts(UIView* view)
{
    if ( [view isKindOfClass:[UILabel class]] )
    {
        UILabel* label = (UILabel*)view;
        applyFontToLabel(label);
    }
    else if ( [view isKindOfClass:[UIButton class]] )
    {
        UIButton* button = (UIButton*)view;
        UILabel* label = button.titleLabel;
        applyFontToLabel(label);
    }
    else if ( [view isKindOfClass:[UITextView class]] )
    {
        UITextView* textView = (UITextView*)view;
        
        textView.editable = YES;
        applyFontToTextView(textView);
        textView.editable = NO;
    }
    else if ( [view isKindOfClass:[UITextField class]] )
    {
        UITextField* textField = (UITextField*)view;
        applyFontToTextField(textField);
    }
    
    for ( UIView* subview in view.subviews )
    {
        searchForFonts(subview);
    }
}
