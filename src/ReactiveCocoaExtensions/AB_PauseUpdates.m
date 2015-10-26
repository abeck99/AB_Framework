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
}

@end

@implementation AB_PauseUpdates

+ (BOOL) automaticallyNotifiesObserversOfPaused
{
    return NO;
}

- (BOOL) paused
{
    return pauseCount > 0;
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
    BOOL doesPausedChange = pauseCount == 0;
    
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
    BOOL doesPausedChange = pauseCount == 1;
    
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

@end


@implementation RACSignal(PauseObjectExtension)

- (RACSignal*) pause:(AB_PauseUpdates*)pauseObject
{
    return
    [[[RACSignal combineLatest:@[
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
     }];
}

@end