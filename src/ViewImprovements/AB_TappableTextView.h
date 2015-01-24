//
//  AB_TappableTextView.h
//  GoHeroClient
//
//  Created by phoebe on 15/1/5.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AB_TappableTextView : UITextView<UITextViewDelegate>
{
    IBOutlet UILabel* characterCountLabel;
}

@property(assign) int maxCharacterCount;
@property(assign) NSNumber* disabled;

@end
