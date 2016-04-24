//
//  AB_ReactiveDataStructure.h
//  Eastern
//
//  Created by phoebe on 7/7/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "ReactiveCocoa.h"

@protocol AB_ReactiveDataStructure

@property(readonly, strong) RACSignal* valueSignal;

@end