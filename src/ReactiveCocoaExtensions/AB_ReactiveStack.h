//
//  AB_ReactiveStack.h
//  Eastern
//
//  Created by phoebe on 7/7/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AB_BaseReactiveStackQueue.h"

@interface AB_ReactiveStack : AB_BaseReactiveStackQueue

- (void) push:(id)obj;
- (void) pop;

@end
