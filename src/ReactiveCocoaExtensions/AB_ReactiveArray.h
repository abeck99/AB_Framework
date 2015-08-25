//
//  AB_ReactiveArray.h
//  Eastern
//
//  Created by phoebe on 7/7/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AB_BaseReactiveStackQueue.h"

@interface AB_ReactiveArray : AB_BaseReactiveStackQueue

// This can technically be set to something that is not in the array, will stay valid until removing it or setting setCurrentValue to something else
// Setting to nil will default back to the top of stack
- (void) setCurrentValue:(id)obj;
- (void) removeValue:(id)obj;

- (RACSignal*) valuesChanged;

@end
