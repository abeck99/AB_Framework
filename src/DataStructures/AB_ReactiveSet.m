//
//  AB_ReactiveSet.m
//  Eastern
//
//  Created by phoebe on 7/24/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ReactiveSet.h"

@interface AB_ReactiveSet()
{
    RACSubject* subject;
    NSMutableOrderedSet* set;
}

@end

@implementation AB_ReactiveSet

- (instancetype) init
{
    if (self == [super init])
    {
        subject = [RACSubject subject];
        set = [NSMutableOrderedSet orderedSet];
    }

    return self;
}

- (void) add:(id)obj
{
    if ([set containsObject:obj])
    {
        [set removeObject:obj];
    }
    [set addObject:obj];
    [subject sendNext:set];
}

- (void) remove:(id)obj
{
    if ([set containsObject:obj])
    {
        [set removeObject:obj];
    }
    [subject sendNext:set];
}

- (void) dealloc
{
    [subject sendCompleted];
}

- (RACSignal*) valuesChanged
{
    return subject;
}

@end
