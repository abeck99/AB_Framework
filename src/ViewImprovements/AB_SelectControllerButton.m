//
//  AB_SelectControllerButton.m
//  GoHeroClient
//
//  Created by phoebe on 5/31/15.
//  Copyright (c) 2015 Hero. All rights reserved.
//

#import "AB_SelectControllerButton.h"

@implementation AB_SelectControllerButton

- (void) setIsSelected:(BOOL)selected
{
    for(UIView* view in enabledViews)
    {
        view.hidden = !selected;
    }
}

@end
