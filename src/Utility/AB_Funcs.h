//
//  AB_Funcs.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RETURN_THREAD_SAFE_SINGLETON(className) static dispatch_once_t pred; static className* ret = nil; dispatch_once(&pred, ^{ ret = [[className alloc] init]; }); return ret;

#define RETURN_THREAD_SAFE_NIB(nibName) static dispatch_once_t pred; static UINib* ret = nil; dispatch_once (&pred, ^{ ret = [UINib nibWithNibName:@nibName bundle:[NSBundle mainBundle]];}); return ret;


void printAllSubviews(UIView* view, int depth);
UIFont* fontForPointSize(CGFloat pointSize);
void applyFontToLabel(UILabel* label);
void applyFontToButton(UIButton* button);
void applyFontToTextView(UITextView* textView);
void applyFontToTextField(UITextField* textField);
void searchForFonts(UIView* view);
