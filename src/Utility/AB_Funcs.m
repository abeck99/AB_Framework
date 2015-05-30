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
    
    for ( UIView* subview in view.subviews )
    {
        printAllSubviews(subview, depth+1);
    }
}
