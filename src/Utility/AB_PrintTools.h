//
//  AB_PrintTools.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AB_PrintTools : NSObject

+ (AB_PrintTools*) get;

- (void) printWebView:(UIWebView*)webView withCompletion:(UIPrintInteractionCompletionHandler)completion;

@end
