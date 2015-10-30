//
//  AB_ClassExtensions.h

//
//  Created by phoebe on 15/1/9.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (TwoFiveFiveExtension)

+ (UIColor*) colorWith255Red:(int)red green:(int)green blue:(int)blue alpha:(CGFloat) alpha;

@end

@interface NSArray (SafeAccessExtension)

- (id) objectAtIndexOrNil:(NSUInteger)index;

@end
