//
//  AB_ShadowImageView.h
//  Eastern
//
//  Created by phoebe on 7/4/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AB_ShadowImageView : UIImageView

@property(assign) IBInspectable CGFloat shadowRadius;
@property(assign) IBInspectable CGSize shadowOffset;
@property(assign) IBInspectable UIColor* shadowColor;
@property(assign) IBInspectable CGFloat shadowOpacity;

@end
