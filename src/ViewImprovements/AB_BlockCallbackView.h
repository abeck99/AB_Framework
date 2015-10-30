//
//  AB_BlockCallbackView.h

//
//  Created by phoebe on 15/1/10.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CallbackBlock)();

@interface AB_BlockCallbackView : UIView

@property(weak) CallbackBlock callbackBlock;

@end
