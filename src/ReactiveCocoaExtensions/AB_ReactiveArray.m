//
//  AB_ReactiveArray.m
//  Eastern
//
//  Created by phoebe on 7/7/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ReactiveArray.h"
#import "EA_BaseModel.h"
#import "EA_ActiveJob.h"

@interface AB_ReactiveArray()
{
    id currentValue_;
}

@end

@implementation AB_ReactiveArray

- (void) insert:(NSObject*)obj toArray:(NSMutableArray*)mutableArray
{
    id objToReplace = nil;
    for (NSObject* model in mutableArray)
    {
        if ([model isEqual:obj])
        {
            objToReplace = model;
        }
    }
    
    if (objToReplace)
    {
        [mutableArray replaceObjectAtIndex:[mutableArray indexOfObject:objToReplace]
                                withObject:obj];
    }
    else
    {
        [mutableArray addObject:obj];
    }
}

- (void) removeFromArray:(NSMutableArray*)mutableArray
{
    if ([mutableArray containsObject:currentValue_])
    {
        [mutableArray removeObject:currentValue_];
    }
    
    currentValue_ = nil;
}

- (void) setObjects:(NSArray*)objects
{
    BOOL wasInArray = currentValue_ && [self.array containsObject:currentValue_];
    self.array = [NSArray arrayWithArray:objects];
    BOOL isInArray = currentValue_ && [self.array containsObject:currentValue_];
    
    if (wasInArray && !isInArray)
    {
        currentValue_ = nil;
    }
    [self pushCurrentValue];
}

- (id) currentValue
{
    // TODO: Remove this hack
    if ([currentValue_ isKindOfClass:[EA_ActiveJob class]])
    {
        EA_ActiveJob* activeJob = currentValue_;
        if (![activeJob.jobModel shouldShow])
        {
            currentValue_ = nil;
        }
    }
    
    if (currentValue_ == nil
        && self.array.count > 0
        && [self.array[0] isKindOfClass:[EA_ActiveJob class]])
    {
        currentValue_ = Underscore.array(self.array)
        .filter(^BOOL(EA_ActiveJob* activeJob)
                {
                    return [activeJob.jobModel shouldShow];
                })
        .first;
    }
        
    
    if (currentValue_ == nil)
    {
        currentValue_ = self.array.count == 0
        ? nil
        : self.array[self.array.count - 1];
    }
    
    return currentValue_;
}

- (void) setCurrentValue:(id)obj
{
    currentValue_ = obj;
    [self pushCurrentValue];
}

- (void) removeValue:(id)obj
{
    if (obj == currentValue_)
    {
        [self remove];
    }
    else if ([self.array containsObject:obj])
    {
        NSMutableArray* mutableArray = [self.array mutableCopy];
        [mutableArray removeObject:obj];
        self.array = [NSArray arrayWithArray:mutableArray];
    }
    [self pushCurrentValue];
}

- (RACSignal*) valuesChanged
{
    return [[RACObserve(self, array)
            scanWithStart:@[]
            reduce:^(NSArray* previous, NSArray* next)
            {
                // Since we want to keep distinct until changed, that is based on the hash of the objects pointer, so will keep previous if things haven't changed
                return [previous isEqualToArray:next]
                ? previous
                : next;
            }] distinctUntilChanged];
}


@end
