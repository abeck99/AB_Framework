//
//  AB_ExpandableTextWatcher.h
//  GoHeroClient
//
//  Created by phoebe on 6/1/15.
//  Copyright (c) 2015 Hero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AB_ExpandableTextWatcher;

@protocol TextWatcherEventListener <NSObject>

- (void) textViewsChangedSize:(AB_ExpandableTextWatcher*)textWatcher;

@end

@interface AB_ExpandableTextWatcher : NSObject
{
    IBOutletCollection(UITextView) NSArray* expandableTextViews;
}

@property(weak) IBOutlet NSObject<TextWatcherEventListener>* delegate;
@property(weak) IBOutlet UIView* rootView;
@property(assign) IBInspectable CGFloat minimumSize;
@property(assign) IBInspectable CGFloat endBufferSize;

@end
