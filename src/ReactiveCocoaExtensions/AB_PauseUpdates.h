//
//  AB_PauseUpdates.h
//  AB
//
//  Created by Andrew Beck on 10/25/15.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

@interface AB_PauseUpdates : NSObject

@property(readonly) BOOL paused;

- (void) pauseDuringExecution:(void (^)())executionBlock;
- (void) pauseDuringSignal:(RACSignal*)signal;

- (void) pushPause;
- (void) popPause;

@end


@interface RACSignal(PauseObjectExtension)

// If pause object is nil (or is deallocated while the signal is ongoing), will assume not paused
- (RACSignal*) pause:(AB_PauseUpdates*)pauseObject;

@end