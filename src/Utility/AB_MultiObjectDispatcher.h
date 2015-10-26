//
//  AB_MultiObjectDispatcher.h
//  AB
//
//  Created by phoebe on 9/21/15.
//

#import <Foundation/Foundation.h>

@interface AB_MultiObjectDispatcher : NSObject

- (void) addResponder:(id)responder;
- (void) removeResponder:(id)responder;
- (void) removeRespondersOfClass:(Class)responderClass;

@end
