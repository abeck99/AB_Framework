//
//  AB_GoogleAnalytics.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_GoogleAnalytics.h"
#import "AB_Funcs.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "AB_ClassExtensions.h"

@implementation AB_GoogleAnalytics

+ (AB_GoogleAnalytics*) get
{
    //    return nil;
    RETURN_THREAD_SAFE_SINGLETON(AB_GoogleAnalytics);
}

- (void) sendEvent:(NSArray*)eventArray
{
    if ( eventArray.count < 2 )
    {
        NSLog(@"Needs category and event!");
        return;
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    GAIDictionaryBuilder* builder =
    [GAIDictionaryBuilder createEventWithCategory:[eventArray objectAtIndexOrNil:0]
                                           action:[eventArray objectAtIndexOrNil:1]
                                            label:[eventArray objectAtIndexOrNil:2]
                                            value:[eventArray objectAtIndexOrNil:3]];
    NSMutableDictionary* eventDict = [builder build];
    [tracker send:eventDict];
}

@end
