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

- (void) pushNamedPause:(NSString*)name;
- (void) popNamedPause:(NSString*)name;

@end


@interface RACSignal(PauseObjectExtension)

- (RACSignal*) debugPause:(AB_PauseUpdates*)pauseObject; // Resumes when object is unpaused

// If pause object is nil (or is deallocated while the signal is ongoing), will assume not paused
- (RACSignal*) pause:(AB_PauseUpdates*)pauseObject; // Resumes when object is unpaused
- (RACSignal*) ignoreWhile:(AB_PauseUpdates*)pauseObject; // Completely ignores any changes when object is paused

@end