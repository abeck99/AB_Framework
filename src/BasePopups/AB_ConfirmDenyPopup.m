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
    [self close];
    if (self.confirmBlock)
    {
        self.confirmBlock();
    }
}

- (IBAction) deny:(id)sender
{
    [self close];
    if (self.denyBlock)
    {
        self.denyBlock();
    }
}

- (IBAction) cancel:(id)sender
{
    [self close];
    if (self.cancelBlock)
    {
        self.cancelBlock();
    }
}

- (void) closeFromBackgroundTap:(id)sender
{
}

@end
