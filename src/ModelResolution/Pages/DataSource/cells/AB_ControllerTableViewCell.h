//
//  AB_ControllerTableViewCell.h
//  AB
//
//  Created by Andrew on 09/15/2015.
//

#import <UIKit/UIKit.h>
#import "AB_MultiTableViewCell.h"
#import "AB_DataContainer.h"
#import "AB_PassthroughView.h"

@interface AB_ControllerTableViewCell : AB_PassthroughView<AB_TableView>

- (void) setController:(AB_Controller)controller
    withViewController:(AB_Controller)viewController
               section:(AB_Section)section;

@end