//
//  AB_ControllerView.h
//  PPA
//
//  Created by Andrew Beck on 12/2/15.
//  Copyright © 2015 Prospect Park Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_BaseViewController.h"

@interface AB_ControllerView : UIView
{
    IBOutlet UIViewController* parentController;
    IBOutlet NSObject* parentSectionController;
}

@property(strong) AB_Controller controller;

@property(strong) AB_Controller parentController;
@property(strong) AB_Section parentSectionController;

@end
