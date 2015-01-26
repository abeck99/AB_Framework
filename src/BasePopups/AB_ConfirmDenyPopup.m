//
//  AB_ConfirmDenyPopup.m
//  AnsellInterceptApp
//
//  Created by phoebe on 15/1/26.
//  Copyright (c) 2015年 Ansell. All rights reserved.
//

#import "AB_ConfirmDenyPopup.h"

@implementation AB_ConfirmDenyPopup

@synthesize confirmBlock;
@synthesize denyBlock;

- (IBAction) confirm:(id)sender
{
    [self closeSelf:sender];
    if ( self.confirmBlock )
    {
        self.confirmBlock();
    }
}

- (IBAction) deny:(id)sender
{
    [self closeSelf:sender];
    if ( self.denyBlock )
    {
        self.denyBlock();
    }
}

- (void) closeFromBackgroundTap:(id)sender
{
}

@end
