//
//  AB_ReactiveSet.h
//  Eastern
//
//  Created by phoebe on 7/24/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_BaseReactiveStackQueue.h"

@interface AB_ReactiveSet : NSObject

- (void) add:(id)obj;
- (void) remove:(id)obj;

- (RACSignal*) valuesChanged;

@end
