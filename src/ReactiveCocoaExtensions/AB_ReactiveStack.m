//
//  AB_ReactiveStack.m
//  Eastern
//
//  Created by phoebe on 7/7/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ReactiveStack.h"

@implementation AB_ReactiveStack

- (void) insert:(id)obj toArray:(NSMutableArray*)mutableArray
{
    [mutableArray addObject:obj];
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

- (void) push:(id)obj
{
    [self insert:obj];
}

- (void) pop
{
    [self remove];
}

@end
