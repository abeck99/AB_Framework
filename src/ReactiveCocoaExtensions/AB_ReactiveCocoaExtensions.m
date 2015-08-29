//
//  AB_ReactiveCocoaExtensions.m
//  Eastern
//
//  Created by phoebe on 7/6/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ReactiveCocoaExtensions.h"
#import "AB_NSString+Extensions.h"
#import <Foundation/Foundation.h>

@implementation RACSignal(AB_Extensions)

// TODO: Potentially reusable?
- (instancetype) mapToDictionaryKey:(NSString*)key
{
    return [self map:^(NSDictionary* dict)
            {
                return dict[key];
            }];
}

- (instancetype)previousWhenChanged
{
    Class class = self.class;
    
    return [[self bind:^{
        __block id lastValue = nil;
        __block BOOL initial = YES;
        
        return ^(id x, BOOL *stop) {
            if (!initial && (lastValue == x || [x isEqual:lastValue])) return [class empty];
            
            initial = NO;
            id retVal = lastValue;
            lastValue = x;
            return [class return:retVal];
        };
    }] setNameWithFormat:@"[%@] -previousWhenChanged", self.name];
}

- (instancetype) toString
{
    return
    [self
     map:^(id val)
     {
         if ([val isValid])
         {
             return [NSString stringWithFormat:@"%@", val];
         }
         return @"";
     }];
}

- (instancetype) toDollarCurrencyString
{
    return
    [self map:^(NSNumber* number)
     {
         if (![number isValid])
         {
             number = @0;
         }
         return [number toDollarCurrencyString];
     }];
}

- (instancetype) multipliedBy:(double)amount
{
    return
    [self map:^(NSNumber* number)
     {
         if (![number isValid])
         {
             number = @0;
         }
         return @([number doubleValue] * amount);
     }];
}

- (instancetype) sum
{
    return
    [self map:^(RACTuple* tuple)
    {
        double t = 0.0;
        for (NSNumber* num in tuple)
        {
            if ([num isValid])
            {
                t += [num doubleValue];
            }
        }
        return @(t);
    }];
}


+ (instancetype)noResubscriptionIf:(RACSignal*)boolSignal
                              then:(RACSignal*)trueSignal
                              else:(RACSignal*)falseSignal
{
    NSCParameterAssert(boolSignal != nil);
    NSCParameterAssert(trueSignal != nil);
    NSCParameterAssert(falseSignal != nil);
    
    __block RACSignal* curSignal = nil;
    
    return [[[[boolSignal
              map:^(NSNumber *value) {
                  NSCAssert([value isKindOfClass:NSNumber.class], @"Expected %@ to send BOOLs, not %@", boolSignal, value);
                  
                  RACSignal* newSignal = (value.boolValue ? trueSignal : falseSignal);
                  BOOL changed = newSignal != curSignal;
                  curSignal = newSignal;
                  return changed ? curSignal : nil;
              }]
              filter:^BOOL(RACSignal* signal)
              {
                  return signal != nil;
              }]
             switchToLatest]
            setNameWithFormat:@"+noResubscriptionIf: %@ then: %@ else: %@", boolSignal, trueSignal, falseSignal];
}


@end

@implementation NSObject(AB_ReactiveCocoaExtensions)

- (RACSignal*) observePreviousValue:(NSString*)keyPath
{
    return
    [[self rac_valuesAndChangesForKeyPath:keyPath
                                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                                 observer:self]
     map:^(RACTuple* pickupChanges)
     {
         NSDictionary* changes = pickupChanges.second;
         return changes[NSKeyValueChangeOldKey];
     }];
}

- (RACSignal*) mapSignal:(RACSignal*)signal withSelector:(SEL)mapSelector
{
    @weakify(self)
    return [signal map:^id(id val)
            {
                @strongify(self)
                IMP mapImp = [self methodForSelector:mapSelector];
                id (*mapFunc)(id, SEL, id) = (void*) mapImp;
                return mapFunc(self, mapSelector, val);
            }];
}

- (BOOL) isValid
{
    return self != [NSNull null] && self != [RACTupleNil tupleNil] && self != nil;
}

@end

