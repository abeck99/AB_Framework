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

UIFont* fontForPointSize(CGFloat pointSize)
{
    UIFont* font = [UIFont fontWithName:@"Asap-Regular" size:pointSize];
    return font;
}

void searchForFonts(UIView* view)
{
    if ( [view isKindOfClass:[UILabel class]] )
    {
        UILabel* label = (UILabel*)view;
        if ( !label.tag != 1000 )
        {
            label.font = fontForPointSize(label.font.pointSize);
        }
    }
    else if ( [view isKindOfClass:[UIButton class]] )
    {
        UIButton* button = (UIButton*)view;
        UILabel* label = button.titleLabel;
        if ( !label.tag != 1000 )
        {
            label.font = fontForPointSize(label.font.pointSize);
        }
    }
    else if ( [view isKindOfClass:[UITextView class]] )
    {
        UITextView* textView = (UITextView*)view;
        
        if ( !textView.tag != 1000 )
        {
            textView.editable = YES;
            textView.font = fontForPointSize(textView.font.pointSize);
            textView.editable = NO;
        }
    }
    else if ( [view isKindOfClass:[UITextField class]] )
    {
        UITextField* textField = (UITextField*)view;
        if ( !textField.tag != 1000 )
        {
            textField.font = fontForPointSize(textField.font.pointSize);
        }
    }
    
    for ( UIView* subview in view.subviews )
    {
        searchForFonts(subview);
    }
}
