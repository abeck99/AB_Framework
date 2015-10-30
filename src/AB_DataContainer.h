//
//  AB_DataContainer.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"

@class AB_SectionViewController;
@class AB_BaseViewController;

typedef void (^ConfirmBlock)(BOOL confirmed);
typedef BOOL (^TestControllerForModel)(id contentModel);
typedef void (^CreateControllerWithModelBlock)(id controller, id contentModel);
typedef void (^CloseControllerBlock)(id controller);


@protocol AB_DataContainer;
typedef UIViewController<AB_DataContainer>* AB_Controller;

@protocol AB_SectionContainer;
typedef NSObject<AB_SectionContainer>* AB_Section;

// TODO: This has completely changed from the original data container protocol and should be renamed accordingly
@protocol AB_DataContainer <NSObject>

- (void) openInView:(UIView*)insideView
     withViewParent:(AB_Controller)viewParent_
          inSection:(AB_Section)sectionParent_;
- (void) closeView;

- (void) attemptToReopen;

- (NSDictionary*) getDescription;
- (void) applyDescription:(NSDictionary*)dictionary;

- (void) allowChangeController:(ConfirmBlock)confirmBlock
                  toController:(AB_Controller)newController;

- (NSArray*) sidebars;

- (void) bind;

@property(strong) id key;
@property(nonatomic,retain) UIView *view;
@property(readonly) BOOL open;

- (void) addChildViewController:(UIViewController *)childController;
- (void) removeFromParentViewController;

@property(readonly) CGFloat height;

- (void) addRetainObject:(id)obj;

@property(strong) NSString* sourceString;

- (RACSignal*)openSignal;
- (RACSignal*)closeSignal;

- (void) setCloseBlock:(CloseControllerBlock)closeBlock;

@end


typedef void (^CreateControllerBlock)(AB_Controller controller);

@protocol AB_SectionContainer <NSObject>

- (void) pushControllerWithName:(id)name;
- (void) pushControllerWithName:(id)name
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock;
- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) pushControllerWithName:(id)name
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                shouldPushState:(BOOL)shouldPushState;
- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                shouldPushState:(BOOL)shouldPushState;
- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                      forceOpen:(BOOL)forceOpen
                    pushOnState:(BOOL)shouldPushOnState;

- (void) pushController:(AB_Controller)sectionController;
- (void) pushController:(AB_Controller)sectionController
              forceOpen:(BOOL)forceOpen
            pushOnState:(BOOL)shouldPushOnState;
- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock;
- (void) pushController:(AB_Controller)sectionController
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;
- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;

- (void) popController;
- (void) popControllerWithAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;

- (void) clearBackHistory;

@end
