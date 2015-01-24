//
//  AB_PrintTools.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_PrintTools.h"
#import "AB_Funcs.h"

@implementation AB_PrintTools

+ (AB_PrintTools*) get
{
    RETURN_THREAD_SAFE_SINGLETON(AB_PrintTools);
}

- (void) printWebView:(UIWebView*)webView withCompletion:(UIPrintInteractionCompletionHandler)completion
{
    UIPrintInfo *pi = [UIPrintInfo printInfo];
    pi.outputType = UIPrintInfoOutputGeneral;
    pi.jobName = webView.request.URL.absoluteString;
    pi.orientation = UIPrintInfoOrientationPortrait;
    pi.duplex = UIPrintInfoDuplexLongEdge;
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.printInfo = pi;
    pic.showsPageRange = YES;
    pic.printFormatter = webView.viewPrintFormatter;
    
    CGRect viewRect =  CGRectMake(
                                  webView.frame.size.width/2.f,
                                  webView.frame.size.height/2.f,
                                  webView.frame.size.width/2.f,
                                  webView.frame.size.height/2.f
                                  );
    
    // This is the call for iPad, it's different for iPhone
    [pic presentFromRect:viewRect inView:webView animated:YES completionHandler:completion];
}


@end
