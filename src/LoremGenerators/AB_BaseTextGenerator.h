//
//  AB_BaseTextGenerator.h
//  AB
//
//  Created by phoebe on 8/26/15.
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
