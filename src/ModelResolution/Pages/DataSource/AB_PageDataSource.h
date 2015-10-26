//
//  AB_PageDataSource.h
//  AB
//
//  Created by Andrew on 09/15/2015.
//

#import "AB_DataSourceBase.h"
#import "AB_PageModel.h"
#import "AB_DataContainer.h"
#import "AB_SectionHeader.h"

@interface AB_PageDataSource : AB_DataSourceBase

@property(strong) NSArray* contentModels;
@property(strong) NSString* context;

- (void) setViewController:(AB_Controller)controller;
- (void) setSection:(AB_Section)section;

@end