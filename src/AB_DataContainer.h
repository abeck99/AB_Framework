//
//  AB_DataContainer.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AB_SectionViewController;

@protocol AB_DataContainer <NSObject>

- (void) setData:(id)setData;
+ (Class) expectedClass;

- (void) setupWithFrame:(CGRect)frame;
- (void) openViewInView:(UIView*)insideView withParent:(AB_SectionViewController*)setParent;
- (void) closeView;

- (void) attemptToReopen;
- (void) poppedAwayWhileStillOpen;
- (void) poppedBackWhileStillOpen;

@property(strong) id key;

@end

typedef UIViewController<AB_DataContainer>* AB_Controller;

