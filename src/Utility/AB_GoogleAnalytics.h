//
//  AB_GoogleAnalytics.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AB_GoogleAnalytics : NSObject

+ (AB_GoogleAnalytics*) get;

- (void) sendEvent:(NSArray*)eventArray;

@end
