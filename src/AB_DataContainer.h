//
//  AB_DataContainer.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AB_SectionViewController;
@class AB_BaseViewController;

typedef void (^ConfirmBlock)(BOOL confirmed);

@protocol AB_DataContainer <NSObject>

- (void) setData:(id)setData;
- (id) data;
+ (Class) expectedClass;

- (void) setupWithFrame:(CGRect)frame;
- (void) openInView:(UIView*)insideView
     withViewParent:(AB_BaseViewController*)viewParent_
          inSection:(AB_SectionViewController*)sectionParent_;
- (void) closeView;

- (void) attemptToReopen;

// TODO: Get rid of this stupid stuff
- (void) poppedAwayWhileStillOpen;
- (void) poppedBackWhileStillOpen;

// TODO: Add popped away
- (void) poppedBack;

- (NSDictionary*) getDescription;
- (void) applyDescription:(NSDictionary*)dictionary;
- (void) allowChangeController:(ConfirmBlock)confirmBlock;

@property(strong) id key;

@end

typedef UIViewController<AB_DataContainer>* AB_Controller;

