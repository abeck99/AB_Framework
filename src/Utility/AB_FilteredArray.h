//
//  AB_FilteredArray.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AB_FilteredArray : NSObject
{
    NSArray* baseArray;
    NSArray* filteredArray;
    NSPredicate* _predicate;
}

- (id) initWithArray:(NSArray*)setArray;

- (void) removeItemAtIndex:(int) index;
- (void) removeItem:(id)obj;
- (void) replaceIndex:(int)index withItem:(id)newItem;

@property(strong) NSPredicate* predicate;
@property(readonly) NSArray* array;
@property(readonly) NSArray* fullArray;

@end
