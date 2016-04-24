//
//  AB_ReactiveCocoaExtensions.h
//  Eastern
//
//  Created by phoebe on 7/6/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "ReactiveCocoa.h"

@interface RACSignal(AB_Extensions)

// TODO: Potentially reusable?
- (instancetype) mapToDictionaryKey:(NSString*)key;
- (instancetype)previousWhenChanged;

- (instancetype) toString;
- (instancetype) toDollarCurrencyString;
- (instancetype) multipliedBy:(double)amount;
- (instancetype) sum;

+ (instancetype)noResubscriptionIf:(RACSignal*)ifSignal then:(RACSignal*)thenSignal else:(RACSignal*)elseSignal;

- (instancetype) promise;
- (instancetype) extractErrorsToBlock:(void (^)(NSError *error))errorBlock;
- (instancetype) noop;

- (instancetype)distinctUntilChangedDebug;

- (instancetype) mapNilsTo:(id)val;

- (instancetype) throttle:(NSTimeInterval)interval orMaxCount:(int)maxCount;

- (instancetype) takeWhen:(RACSignal*)boolSignal;

@end

@interface NSObject(AB_ReactiveCocoaExtensions)

- (RACSignal*) observePreviousValue:(NSString*)keyPath;
- (RACSignal*) mapSignal:(RACSignal*)signal withSelector:(SEL)mapSelector;

- (BOOL) isValid;

@end

#define VALID_VALUE_FROM_ARRAY(arrName, index) ([arrName[index] isValid] ? arrName[index] : nil)