//
//  AB_ControllerResolver.h
//  AB
//
//  Created by phoebe on 9/14/15.
//

#import <UIKit/UIKit.h>
#import "AB_BaseModel.h"
#import "AB_SectionViewController.h"


typedef NS_OPTIONS(NSUInteger, AB_DisplayType) {
    DisplayType_Full             = (1 << 0),
    DisplayType_Popup            = (1 << 1),
    DisplayType_Cell             = (1 << 2),
    DisplayType_SectionHeader    = (1 << 3),
    DisplayType_AnnotationView   = (1 << 4),
    DisplayType_EnumSize         = (1 << 5),
    
    
    DisplayType_All =
    DisplayType_Full |
    DisplayType_Popup |
    DisplayType_Cell,
};

@interface AB_ControllerResolver : NSObject

+ (AB_ControllerResolver*) get;


- (AB_Controller) controllerForModel:(AB_BaseModel*)model
                     withDisplayType:(AB_DisplayType)displayType
                           inContext:(NSString*)contextName
                              source:(NSString*)sourceName;

- (AB_Controller) controllerForModel:(AB_BaseModel*)model
                     withDisplayType:(AB_DisplayType)displayType
                           inContext:(NSString*)contextName;

- (void) registerController:(NSString*)tag
              forModelClass:(Class)modelClass
                 forDisplay:(AB_DisplayType)displayType;

- (void) registerController:(NSString*)tag
              forModelClass:(Class)modelClass
                 forDisplay:(AB_DisplayType)displayType
                  inContext:(NSString*)contextName;

- (void) registerController:(NSString*)tag
              forModelClass:(Class)modelClass
                 forDisplay:(AB_DisplayType)displayType
              withTestBlock:(TestControllerForModel)testBlock;

- (void) registerController:(NSString*)tag
              forModelClass:(Class)modelClass
                 forDisplay:(AB_DisplayType)displayType
                  inContext:(NSString*)contextName
              withTestBlock:(TestControllerForModel)testBlock;

- (void) registerControllerCallbacks:(Class)controllerClass
                       forModelClass:(Class)modelClass
                        withCallback:(CreateControllerWithModelBlock)createBlock
                       closeCallback:(CloseControllerBlock)closeBlock;

- (void) runPostCreate:(AB_Controller)controller model:(AB_BaseModel*)model;


@end

#define REGISTER_CONTROLLER(controllerTag, modelClass, displayType) + (void) load { [[AB_ControllerResolver get] registerController:controllerTag forModelClass:[modelClass class] forDisplay:displayType]; }

#define REGISTER_DEFAULT_CALLBACKS(controllerClass, modelClass, propertyName) [[AB_ControllerResolver get] \
registerControllerCallbacks:[controllerClass class] \
forModelClass:[modelClass class] \
withCallback:^(controllerClass* controller, modelClass* propertyName) \
{ \
controller.propertyName = propertyName; \
} \
closeCallback:^(controllerClass* controller) \
{ \
 /*controller.propertyName = nil;*/ \
}];

