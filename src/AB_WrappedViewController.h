//
//  AB_WrappedViewController.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_SectionViewController.h"

@interface AB_WrappedViewController : AB_SectionViewController
{
    NSArray* retainSelf;
}
@property(weak) AB_SectionViewController* lastSectionController;

@end
