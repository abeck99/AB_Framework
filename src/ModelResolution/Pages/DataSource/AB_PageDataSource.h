//
//  AB_PageDataSource.h
//  AB
//
//  Created by Andrew on 09/15/2015.
//

#import "AB_DataSourceBase.h"
#import "AB_DataContainer.h"
#import "AB_SectionHeader.h"
#import "AB_BaseModel.h"

@interface AB_PageDataSource : AB_DataSourceBase

@property(strong) NSArray* contentModels;
@property(strong) NSString* context;

- (void) setViewController:(AB_Controller)controller;
- (void) setSection:(AB_Section)section;

- (void) resetPosition;

// Each model returned from this will be a seperate section
- (NSArray*) expandModel:(AB_BaseModel*)model;
// Each model returned from here will be a list of items in the section
- (NSArray*) sectionModelsForModel:(AB_BaseModel*)model inContext:(NSString*)context;

@end