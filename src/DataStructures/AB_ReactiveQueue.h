//
//  AB_ReactiveQueue.h
//  Eastern
//
//  Created by phoebe on 7/7/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AB_BaseReactiveStackQueue.h"

@interface AB_ReactiveQueue : AB_BaseReactiveStackQueue

- (void) enqueue:(id)obj;
- (void) dequeue;

@end
