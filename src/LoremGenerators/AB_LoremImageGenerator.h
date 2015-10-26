//
//  AB_LoremImageGenerator.h
//  AB
//
//  Created by phoebe on 8/26/15.
//

#import <UIKit/UIKit.h>

@interface AB_LoremImageGenerator : NSObject
{
    IBOutletCollection(UIImageView) NSArray* imageViews;
}

- (void) setContent;

@end
