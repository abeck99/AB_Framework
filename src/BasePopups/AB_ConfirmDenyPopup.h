//
//  AB_ConfirmDenyPopup.h
//  AnsellInterceptApp
//
//  Created by phoebe on 15/1/26.
//  Copyright (c) 2015年 Ansell. All rights reserved.
//

#import "AB_Popup.h"

@interface AB_ConfirmDenyPopup : AB_Popup

@property(strong) void (^confirmBlock)();
@property(strong) void (^denyBlock)();
@property(strong) void (^cancelBlock)();

- (IBAction) confirm:(id)sender;
- (IBAction) deny:(id)sender;
- (IBAction) cancel:(id)sender;

@end
