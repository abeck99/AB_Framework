//
//  AB_PauseUpdates.m
//  AB
//
//  Created by Andrew Beck on 10/25/15.
//

#import "AB_PauseUpdates.h"
#import "AB_ReactiveCocoaExtensions.h"

@interface AB_PauseUpdates()
{
    NSUInteger pauseCount;
    NSMutableSet* pauseItems;
}

@end

@implementation AB_PauseUpdates

+ (BOOL) automaticallyNotifiesObserversOfPaused
{
    return NO;
}

- (instancetype) init
{
    if (self == [super init])
    {
        pauseItems = [[NSMutableSet alloc] init];
    }
    return self;
}

- (BOOL) paused
{
    return pauseCount > 0 || pauseItems.count > 0;
}

- (void) pauseDuringExecution:(void (^)())executionBlock
{
    if (!executionBlock)
    {
        return;
    }
    
    [self pushPause];
    executionBlock();
    [self popPause];
}

- (void) pauseDuringSignal:(RACSignal*)signal
{
    [self pushPause];
    [signal
     subscribeCompleted:^
     {
         [self popPause];
     }];
}

- (void) pushPause
{
    BOOL doesPausedChange = pauseCount == 0 && pauseItems.count == 0;
    
    if (doesPausedChange)
    {
        [self willChangeValueForKey:@"paused"];
    }
    
    pauseCount++;
    
    if (doesPausedChange)
    {
        [self didChangeValueForKey:@"paused"];
    }
}

- (void) popPause
{
    BOOL doesPausedChange = pauseCount == 1 && pauseItems.count == 0;
    
    if (doesPausedChange)
    {
        [self willChangeValueForKey:@"paused"];
    }
    
    pauseCount--;
    
    if (doesPausedChange)
    {
        [self didChangeValueForKey:@"paused"];
    }
}

- (void) pushNamedPause:(NSString*)name
{
    if ([pauseItems containsObject:name])
    {
        return;
    }
    
    BOOL doesPausedChange = pauseCount == 0 && pauseItems.count == 0;

    if (doesPausedChange)
    {
        [self willChangeValueForKey:@"paused"];
    }
    
    [pauseItems addObject:name];

    if (doesPausedChange)
    {
        [self didChangeValueForKey:@"paused"];
    }
}

- (void) popNamedPause:(NSString*)name
{
    if (![pauseItems containsObject:name])
    {
        return;
    }
    
    BOOL doesPausedChange = pauseCount == 0 && pauseItems.count == 1;
    
    if (doesPausedChange)
    {
        [self willChangeValueForKey:@"paused"];
    }
    
    [pauseItems removeObject:name];
    
    if (doesPausedChange)
    {
        [self didChangeValueForKey:@"paused"];
    }
}

@end


@implementation RACSignal(PauseObjectExtension)


- (RACSignal*) debugPause:(AB_PauseUpdates*)pauseObject
{
    __weak AB_PauseUpdates* weakPause = pauseObject;
    
    return
    [[[RACSignal combineLatest:@[
                                 self,
                                 [[RACObserve(pauseObject, paused) takeUntil:[pauseObject rac_willDeallocSignal]] distinctUntilChanged],
                                 ]]
      filter:^BOOL(RACTuple* tuple)
      {
          AB_PauseUpdates* capturedPause = weakPause;
          NSNumber* paused = tuple[1];
          NSLog(@"Paused: %@ (while sending %@) --- %@ (%d)", paused, tuple[0], capturedPause, capturedPause.paused);
          return ![paused boolValue];
      }]
     map:^(RACTuple* tuple)
     {
         id x = tuple[0];
         // isValid will check if x is an object representation of nil (RACTuple nil or [NSNull null])
         return [x isValid] ? x : nil;
     }];
}


- (RACSignal*) pause:(AB_PauseUpdates*)pauseObject
{
    return
    [[[[RACSignal combineLatest:@[
                                 self,
                                 [[RACObserve(pauseObject, paused) takeUntil:[pauseObject rac_willDeallocSignal]] distinctUntilChanged],
                                 ]]
     filter:^BOOL(RACTuple* tuple)
     {
         NSNumber* paused = tuple[1];
         return ![paused boolValue];
     }]
     map:^(RACTuple* tuple)
     {
         id x = tuple[0];
         // isValid will check if x is an object representation of nil (RACTuple nil or [NSNull null])
         return [x isValid] ? x : nil;
     }] distinctUntilChanged];
}

- (RACSignal*) ignoreWhile:(AB_PauseUpdates*)pauseObject
{
    return [RACSignal createSignal:^RACDisposable*(id<RACSubscriber> subscriber)
            {
                RACCompoundDisposable* compoundDisposable = [RACCompoundDisposable compoundDisposable];
                
                __block BOOL paused = NO;
                
                [compoundDisposable addDisposable:
                [[RACObserve(pauseObject, paused) takeUntil:[pauseObject rac_willDeallocSignal]]
                 subscribeNext:^(NSNumber* pausedObj)
                 {
                     paused = [pausedObj boolValue];
                 }]];
                
                [compoundDisposable addDisposable:
                [self subscribeNext:^(id x)
                 {
                    if (!paused)
                    {
                        [subscriber sendNext:x];
                    }
                 }
                 error:^(NSError* error)
                 {
                     [subscriber sendError:error];
                 }
                 completed:^
                 {
                     [subscriber sendCompleted];
                 }]];
                
                return compoundDisposable;
            }];
}


@end