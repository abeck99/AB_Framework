//
//  AB_MultiObjectDispatcher.m
//  AB
//
//  Created by phoebe on 9/21/15.
//

#import "AB_MultiObjectDispatcher.h"
#import "Underscore.h"

@interface AB_MultiObjectDispatcher()
{
    NSArray* responders;
}

@end

typedef id(^GetObjectBlock)();

@implementation AB_MultiObjectDispatcher

- (instancetype) init
{
    if (self == [super init])
    {
        responders = @[];
    }
    return self;
}

- (void) addResponder:(id)responder
{
    __weak id weakResponder = responder;
    
    NSMutableArray* mutableResponders = [responders mutableCopy];
    [mutableResponders addObject:[^{
        id strongResponder = weakResponder;
        return strongResponder;
    } copy]];
    
    responders = Underscore.array(mutableResponders)
    .filter(^BOOL(GetObjectBlock block)
         {
             id val = block();
             return val != nil;
         })
    .unwrap;
}

- (void) removeResponder:(id)responder
{
    responders = Underscore.array(responders)
    .filter(^BOOL(GetObjectBlock block)
            {
                id val = block();
                return val != nil && val != responder;
            })
    .unwrap;
}

- (void) removeRespondersOfClass:(Class)responderClass
{
    responders = Underscore.array(responders)
    .filter(^BOOL(GetObjectBlock block)
            {
                id val = block();
                return val != nil && ![val isKindOfClass:responderClass];
            })
    .unwrap;
}


- (USArrayWrapper*) objectsRespondingToSelector:(SEL)aSelector
{
    return Underscore.array(responders)
    .map(^(GetObjectBlock block)
         {
             return block();
         })
    .filter(^BOOL(id obj)
            {
                return [obj respondsToSelector:aSelector];
            });
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;

    return [self objectsRespondingToSelector:aSelector]
    .first != nil;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector
{
    id obj = [self objectsRespondingToSelector:aSelector].first;
    
    return obj
    ? [obj methodSignatureForSelector:aSelector]
    : [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation*)anInvocation
{
    __block void* returnObject = nil;
    const char* returnType = [[anInvocation methodSignature] methodReturnType];
    BOOL isPointerReturn = returnType[0] == '@';
    
    [self objectsRespondingToSelector:[anInvocation selector]]
    .each(^(id obj)
          {
              [anInvocation invokeWithTarget:obj];
              
              if (isPointerReturn)
              {
                  void* rawInvocationReturn = nil;
                  [anInvocation getReturnValue:&rawInvocationReturn];
                  
                  if (rawInvocationReturn && !returnObject)
                  {
                      returnObject = rawInvocationReturn;
                  }
                  else if (rawInvocationReturn && returnObject)
                  {
                      NSLog(@"Multiple objects returning something! This is probably a problem");
                  }
              }
          });
    
    if (returnObject)
    {
        [anInvocation setReturnValue:&returnObject];
    }
}

@end
