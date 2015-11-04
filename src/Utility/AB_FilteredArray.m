//
//  AB_FilteredArray.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_FilteredArray.h"

@implementation AB_FilteredArray

- (id) initWithArray:(NSArray*)setArray
{
    if (self = [super init])
    {
        baseArray = [NSArray arrayWithArray:setArray];
        self.predicate = nil;
    }
    
    return self;
}

- (NSPredicate*) predicate
{
    return _predicate;
}

- (void) removeItemAtIndex:(int) index
{
    id obj = [filteredArray objectAtIndex:index];
    [self removeItem:obj];
}

- (void) removeItem:(id)obj
{
    NSMutableArray* filteredMutable = [filteredArray mutableCopy];
    [filteredMutable removeObject:obj];
    filteredArray = [NSArray arrayWithArray:filteredMutable];

    NSMutableArray* baseMutable = [baseArray mutableCopy];
    [baseMutable removeObject:obj];
    baseArray = [NSArray arrayWithArray:baseMutable];
}

- (void) replaceIndex:(int)index withItem:(id)newItem
{
    id obj = [filteredArray objectAtIndex:index];

    NSMutableArray* filteredMutable = [filteredArray mutableCopy];
    [filteredMutable replaceObjectAtIndex:index withObject:newItem];
    filteredArray = [NSArray arrayWithArray:filteredMutable];
    

    NSInteger baseIndex = [baseArray indexOfObject:obj];
    if ( baseIndex != NSNotFound )
    {
        NSMutableArray* baseMutable = [baseArray mutableCopy];
        [baseMutable replaceObjectAtIndex:baseIndex withObject:newItem];
        baseArray = [NSArray arrayWithArray:baseMutable];
    }
}


- (void) setPredicate:(NSPredicate *)predicate
{
    _predicate = predicate;
    if ( _predicate )
    {
        filteredArray = [baseArray filteredArrayUsingPredicate:predicate];
    }
    else
    {
        filteredArray = baseArray;
    }
}

- (NSArray*) array
{
    return filteredArray;
}

- (NSArray*) fullArray
{
    return baseArray;
}

@end
