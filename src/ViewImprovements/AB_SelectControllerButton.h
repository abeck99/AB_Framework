//
//  AB_SelectControllerButton.h
//  GoHeroClient
//
//  Created by phoebe on 5/31/15.
//  Copyright (c) 2015 Hero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AB_SelectControllerButton : UIButton
{
    IBOutletCollection(UIView) NSArray* enabledViews;
}

- (void) setIsSelected:(BOOL)selected;

@property(strong) IBInspectable NSString* controllerName;
@property(assign) IBInspectable BOOL forwardData;

@end
