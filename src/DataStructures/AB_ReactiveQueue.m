//
//  AB_ReactiveQueue.m
//  Eastern
//
//  Created by phoebe on 7/7/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ReactiveQueue.h"

@implementation AB_ReactiveQueue

- (void) insert:(id)obj toArray:(NSMutableArray*)mutableArray
{
    [mutableArray insertObject:obj atIndex:0];
}

- (void) removeFromArray:(NSMutableArray*)mutableArray
{
    [mutableArray removeLastObject];
}

- (id) currentValue
{
    return self.array.count == 0
    ? nil
    : self.array[self.array.count - 1];
}

- (void) enqueue:(id)obj
{
    [self insert:obj];
}

- (void) dequeue
{
    [self remove];
}

@end
