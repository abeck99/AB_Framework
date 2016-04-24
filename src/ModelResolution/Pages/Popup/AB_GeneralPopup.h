//
//  AB_GeneralPopup.h
//  AB
//
//  Created by Andrew on 09/14/2015.
//

#import "AB_Popup.h"
#import "AB_BaseModel.h"
#import "AB_PageDataSource.h"

@interface AB_GeneralPopup : AB_Popup<AB_SectionContainer>
{
    IBOutlet AB_PageDataSource* dataSource;
    IBOutlet NSLayoutConstraint* tableViewHeightConstraint;
}

@property(strong) NSArray* contexts;
@property(strong) NSArray* models;

@end