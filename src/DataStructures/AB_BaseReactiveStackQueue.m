//
//  AB_BaseReactiveStackQueue.m
//  Eastern
//
//  Created by phoebe on 7/7/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_BaseReactiveStackQueue.h"

@interface AB_BaseReactiveStackQueue()
{
    RACSubject* valueSubject;
}

@end

@implementation AB_BaseReactiveStackQueue

- (void) insert:(id)obj toArray:(NSMutableArray*)mutableArray
{
    @throw [NSException exceptionWithName:NSObjectNotAvailableException
                                   reason:@"Abstract base class!"
                                 userInfo:@{}];
}

- (void) removeFromArray:(NSMutableArray*)mutableArray
{
    @throw [NSException exceptionWithName:NSObjectNotAvailableException
                                   reason:@"Abstract base class!"
                                 userInfo:@{}];
}

- (id) currentValue
{
    @throw [NSException exceptionWithName:NSObjectNotAvailableException
                                   reason:@"Abstract base class!"
                                 userInfo:@{}];
}

- (instancetype) init
{
    if (self == [super init])
    {
        self.array = @[];
        valueSubject = [RACSubject subject];
    }
    return self;
}

- (RACSignal*) valueSignal
{
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable*(id<RACSubscriber> subscriber)
            {
                @strongify(self)
                [subscriber sendNext:[self currentValue]];
                
                return
                [valueSubject subscribeNext:^(id item)
                 {
                     [subscriber sendNext:item];
                 }];
            }];
}

- (void) setObjects:(NSArray*)objects
{
    self.array = [NSArray arrayWithArray:objects];
    [self pushCurrentValue];
}

- (void) insert:(id) obj
{
    NSMutableArray* mutableArray = [self.array mutableCopy];
    [self insert:obj toArray:mutableArray];
    self.array = [NSArray arrayWithArray:mutableArray];

    [self pushCurrentValue];
}

- (void) remove
{
    NSMutableArray* mutableArray = [self.array mutableCopy];
    [self removeFromArray:mutableArray];
    self.array = [NSArray arrayWithArray:mutableArray];

    [self pushCurrentValue];
}

- (void) pushCurrentValue
{
    [valueSubject sendNext:[self currentValue]];
}

- (void) dealloc
{
    [valueSubject sendCompleted];
}

@end
