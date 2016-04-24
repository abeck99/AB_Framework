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

- (instancetype)distinctUntilChangedDebug {
    Class class = self.class;
    
    return [[self bind:^{
        __block id lastValue = nil;
        __block BOOL initial = YES;
        
        return ^(id x, BOOL *stop) {
            if (!initial && (lastValue == x || [x isEqual:lastValue])) return [class empty];
            
            initial = NO;
            lastValue = x;
            return [class return:x];
        };
    }] setNameWithFormat:@"[%@] -distinctUntilChanged", self.name];
}

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

- (instancetype) promise
{
    __block id curValue = nil;
    __block BOOL firstRun = YES;
    __block BOOL finished = NO;
    __block NSError* curError = nil;
    __block RACSignal* publishedSignal = nil;
    
    return [RACSignal createSignal:^RACDisposable*(id<RACSubscriber>subscriber)
            {
                if (curValue)
                {
                    [subscriber sendNext:curValue];
                }
                
                if (curError)
                {
                    [subscriber sendError:curError];
                    return nil;
                }

                if (finished)
                {
                    [subscriber sendCompleted];
                    return nil;
                }
                
                if (firstRun)
                {
                    publishedSignal = [[self publish] autoconnect];
                }

                firstRun = NO;
                
                return
                [publishedSignal
                 subscribeNext:^(id x)
                 {
                     curValue = x;
                     [subscriber sendNext:x];
                 }
                 error:^(NSError* error)
                 {
                     curError = error;
                     [subscriber sendError:error];
                 }
                 completed:^
                 {
                     finished = YES;
                     [subscriber sendCompleted];
                 }];
            }];
}

- (instancetype) extractErrorsToBlock:(void (^)(NSError *error))errorBlock
{
    return
    [[[self materialize]
    map:^RACEvent*(RACEvent* event)
     {
         if (event.eventType == RACEventTypeError)
         {
             errorBlock(event.error);
             return [RACEvent completedEvent];
         }
         
         return event;
     }] dematerialize];
}

- (instancetype) noop
{
    return self;
}

- (instancetype) mapNilsTo:(id)val
{
    return [self
            map:^(id x)
            {
                return x == nil ? val : x;
            }];
}

- (instancetype) throttle:(NSTimeInterval)interval orMaxCount:(int)maxCount
{
    NSCParameterAssert(interval >= 0);
    
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        RACCompoundDisposable *compoundDisposable = [RACCompoundDisposable compoundDisposable];
        
        // We may never use this scheduler, but we need to set it up ahead of
        // time so that our scheduled blocks are run serially if we do.
        RACScheduler *scheduler = [RACScheduler scheduler];
        
        // Information about any currently-buffered `next` event.
        __block id nextValue = nil;
        __block int nextValueCount = 0;
        RACSerialDisposable *nextDisposable = [[RACSerialDisposable alloc] init];
        
        void (^flushNext)() = ^{
            @synchronized (compoundDisposable) {
                [nextDisposable.disposable dispose];
                
                if (nextValueCount > 0)
                {
                    [subscriber sendNext:nextValue];
                }
                
                nextValue = nil;
                nextValueCount = 0;
            }
        };
        
        RACDisposable *subscriptionDisposable = [self subscribeNext:^(id x) {
            RACScheduler *delayScheduler = RACScheduler.currentScheduler ?: scheduler;
            
            @synchronized (compoundDisposable) {
                [nextDisposable.disposable dispose];
                nextValue = x;
                nextValueCount++;
                if (nextValueCount >= maxCount)
                {
                    flushNext();
                }
                else
                {
                    nextDisposable.disposable = [delayScheduler afterDelay:interval schedule:^{
                        flushNext();
                    }];
                }
            }
        } error:^(NSError *error) {
            [compoundDisposable dispose];
            [subscriber sendError:error];
        } completed:^{
            flushNext();
            [subscriber sendCompleted];
        }];
        
        [compoundDisposable addDisposable:subscriptionDisposable];
        return compoundDisposable;
    }] setNameWithFormat:@"[%@] -throttle: %f valuesPassingTest:", self.name, (double)interval];
}

- (instancetype) takeWhen:(RACSignal*)boolSignal
{
    return [[[RACSignal combineLatest:@[self, boolSignal]]
            filter:^BOOL(RACTuple* tuple)
            {
                NSNumber* shouldAllow = tuple[1];
                return [shouldAllow isValid] ? [shouldAllow boolValue] : NO;
            }]
            map:^id(RACTuple* tuple)
            {
                id x = tuple[0];
                return [x isValid] ? x : nil;
            }];
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

