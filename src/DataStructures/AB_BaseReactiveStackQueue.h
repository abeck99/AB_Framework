//
//  AB_BaseReactiveStackQueue.h
//  Eastern
//
//  Created by phoebe on 7/7/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AB_ReactiveDataStructure.h"

@interface AB_BaseReactiveStackQueue : NSObject<AB_ReactiveDataStructure>
{
}

- (void) insert:(id)obj toArray:(NSMutableArray*)mutableArray;
- (void) removeFromArray:(NSMutableArray*)mutableArray;
- (id) currentValue;


- (void) pushCurrentValue;
- (void) insert:(id) obj;
- (void) remove;

- (void) setObjects:(NSArray*)objects;

@property(strong) NSArray* array;

@end
