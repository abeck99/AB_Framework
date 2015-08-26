//
//  AB_LoremImageGenerator.h
//  PPA
//
//  Created by phoebe on 8/26/15.
//  Copyright (c) 2015 Prospect Park Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AB_LoremImageGenerator : NSObject
{
    IBOutletCollection(UIImageView) NSArray* imageViews;
}

- (void) setContent;

@end
