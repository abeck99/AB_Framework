//
//  AB_ControllerResolver.m
//  AB
//
//  Created by phoebe on 9/14/15.
//

#import "AB_ControllerResolver.h"
#import "AB_Controllers.h"
#import "AB_Funcs.h"
#import "Underscore.h"
#import "AB_SectionViewController.h"
#import "ReactiveCocoa.h"

@interface AB_ControllerResolverContext: NSObject

- (NSString*) getByModel:(AB_BaseModel*)model withDisplayType:(AB_DisplayType)displayType inContext:(NSString*)contextName;
- (void) setTag:(NSString*)tag forSize:(AB_DisplayType)displayType inContext:(NSString*)contextName withTestBlock:(TestControllerForModel)testBlock;

@end

@interface AB_ControllerCallbacks : NSObject

@property(strong) CreateControllerWithModelBlock createControllerBlock;
@property(strong) CloseControllerBlock closeControllerBlock;

@end

@interface AB_ControllerResolver()
{
    NSDictionary* modelToControllerTag;
    NSDictionary* controllerModelCallbacks;
}

@end

@implementation AB_ControllerResolver

+ (AB_ControllerResolver*) get
{
    RETURN_THREAD_SAFE_SINGLETON(AB_ControllerResolver);
}

- (instancetype) init
{
    if (self == [super init])
    {
        modelToControllerTag = @{};
        controllerModelCallbacks = @{};
    }
    return self;
}

- (AB_Controller) controllerForModel:(AB_BaseModel*)model
                     withDisplayType:(AB_DisplayType)displayType
                           inContext:(NSString*)contextName
{
    return
    [self
     controllerForModel:model withDisplayType:displayType inContext:contextName source:nil];
}

- (AB_Controller) controllerForModel:(AB_BaseModel*)model
                     withDisplayType:(AB_DisplayType)displayType
                           inContext:(NSString*)contextName
                              source:(NSString*)sourceName
{
    AB_ControllerResolverContext* resolver = modelToControllerTag[[model class]];
    NSString* tag = [resolver
                     getByModel:model
                     withDisplayType:displayType
                     inContext:contextName];

    AB_Controllers* controllers = getController();
    AB_Controller controller = [controllers controllerForTag:tag source:sourceName];
    
    [self runPostCreate:controller model:model];
    
    return controller;
}

- (void) runPostCreate:(AB_Controller)controller model:(AB_BaseModel*)model
{
    if (!controller || !model)
    {
        return;
    }
    
    AB_ControllerCallbacks* callbacks =
    controllerModelCallbacks[[controller class]][[model class]];

    if (callbacks.createControllerBlock)
    {
        callbacks.createControllerBlock(controller, model);
    }
    
    [controller setCloseBlock:callbacks.closeControllerBlock];
}


- (void) registerController:(NSString*)tag
              forModelClass:(Class)modelClass
                 forDisplay:(AB_DisplayType)displayType
{
    [self registerController:tag
               forModelClass:modelClass
                  forDisplay:displayType
                   inContext:@""];
}

- (void) registerController:(NSString*)tag
              forModelClass:(Class)modelClass
                 forDisplay:(AB_DisplayType)displayType
                  inContext:(NSString*)contextName
{
    [self registerController:tag
               forModelClass:modelClass
                  forDisplay:displayType
                   inContext:contextName
               withTestBlock:^BOOL(id _){ return YES; }];
}

- (void) registerController:(NSString*)tag
              forModelClass:(Class)modelClass
                 forDisplay:(AB_DisplayType)displayType
              withTestBlock:(TestControllerForModel)testBlock
{
    [self registerController:tag
               forModelClass:modelClass
                  forDisplay:displayType
                   inContext:@""
               withTestBlock:testBlock];
}

- (void) registerController:(NSString*)tag
              forModelClass:(Class)modelClass
                 forDisplay:(AB_DisplayType)displayType
                  inContext:(NSString*)contextName
              withTestBlock:(TestControllerForModel)testBlock
{
    AB_ControllerResolverContext* context = modelToControllerTag[modelClass];
    
    if (!context)
    {
        context = [[AB_ControllerResolverContext alloc] init];
        
        NSMutableDictionary* mutableControllers = [modelToControllerTag mutableCopy];
        mutableControllers[(id<NSCopying>)modelClass] = context;
        modelToControllerTag = [NSDictionary dictionaryWithDictionary:mutableControllers];
    }
    
    [context setTag:tag forSize:displayType inContext:contextName withTestBlock:testBlock];
}

- (void) registerControllerCallbacks:(Class)controllerClass
                       forModelClass:(Class)modelClass
                        withCallback:(CreateControllerWithModelBlock)createBlock
                       closeCallback:(CloseControllerBlock)closeBlock
{
    NSMutableDictionary* mutableControllerModelCallbacks = [controllerModelCallbacks
                                                            mutableCopy];
    
    NSMutableDictionary* mutableModelCallbacks =
    [mutableControllerModelCallbacks[controllerClass]
     ? mutableControllerModelCallbacks[controllerClass]
     : @{} mutableCopy];
    
    AB_ControllerCallbacks* callbacks = [[AB_ControllerCallbacks alloc] init];
    callbacks.createControllerBlock = createBlock;
    callbacks.closeControllerBlock = closeBlock;
    
    mutableModelCallbacks[(id<NSCopying>)modelClass] = callbacks;
    
    mutableControllerModelCallbacks[(id<NSCopying>)controllerClass] =
    [NSDictionary
     dictionaryWithDictionary:mutableModelCallbacks];
    
    controllerModelCallbacks = [NSDictionary
                                dictionaryWithDictionary:mutableControllerModelCallbacks];
}


@end

@interface AB_ControllerResolverContext()
{
    NSArray* resolvables;
}

@end

@interface AB_ControllerResolverInstance : NSObject
{

}

@property(strong) TestControllerForModel testBlock;
@property(assign) AB_DisplayType displayType;
@property(strong) NSString* context;

@property(strong) NSString* tag;

- (BOOL) testModel:(AB_BaseModel*)model withDisplayType:(AB_DisplayType)displayType inContext:(NSString*)contextName;

@end

@implementation AB_ControllerResolverInstance

- (BOOL) testModel:(AB_BaseModel*)model withDisplayType:(AB_DisplayType)displayType inContext:(NSString*)contextName
{
    if (!self.testBlock || self.testBlock(model))
    {
        if ((self.displayType & displayType) == displayType)
        {
            if ([contextName isEqualToString:self.context])
            {
                return YES;
            }
        }
    }

    return NO;
}

@end


@implementation AB_ControllerResolverContext

- (instancetype) init
{
    if (self == [super init])
    {
        resolvables = @[];
    }
    return self;
}

- (NSString*) getByModel:(AB_BaseModel*)model withDisplayType:(AB_DisplayType)displayType inContext:(NSString*)contextName
{
    NSArray* validResolvables = Underscore.array(resolvables)
    .filter(^BOOL(AB_ControllerResolverInstance* resolvable)
    {
      return [resolvable testModel:model withDisplayType:displayType inContext:contextName];
    })
    .unwrap;

    if (validResolvables.count == 0)
    {
        validResolvables = Underscore.array(resolvables)
        .filter(^BOOL(AB_ControllerResolverInstance* resolvable)
        {
          return [resolvable testModel:model withDisplayType:displayType inContext:@""];
        })
        .unwrap;
    }

    if (validResolvables.count > 1)
    {
        NSLog(@"Found multiple controllers for this object!");
    }

    if (validResolvables.count > 0)
    {
        return ((AB_ControllerResolverInstance*)validResolvables[0]).tag;
    }

    return nil;
}

- (void) setTag:(NSString*)tag forSize:(AB_DisplayType)displayType inContext:(NSString*)contextName withTestBlock:(TestControllerForModel)testBlock
{
    AB_ControllerResolverInstance* resolvable = [[AB_ControllerResolverInstance alloc] init];
    resolvable.tag = tag;
    resolvable.displayType = displayType;
    resolvable.context = contextName;
    resolvable.testBlock = testBlock;

    NSMutableArray* mutableResolvables = [resolvables mutableCopy];
    [mutableResolvables addObject:resolvable];
    resolvables = [NSArray arrayWithArray:mutableResolvables];
}

@end

@implementation AB_ControllerCallbacks

@end