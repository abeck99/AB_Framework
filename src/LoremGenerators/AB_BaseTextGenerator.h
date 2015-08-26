//
//  AB_BaseTextGenerator.h
//  PPA
//
//  Created by phoebe on 8/26/15.
//  Copyright (c) 2015 Prospect Park Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AB_BaseTextGenerator : NSObject
{
    IBOutletCollection(UILabel) NSArray* labels;
    IBOutletCollection(UITextView) NSArray* textViews;
}

- (void) setContent;
- (NSString*) textContent;

@end
