//
//  AB_DataSourceBase.h
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AB_FilteredArray.h"
#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"

@interface AB_SectionInfo : NSObject

@property(strong) NSString* sectionName;
@property(assign) BOOL headerHidden;
@property(assign) BOOL quickLinkable;
@property(strong) AB_FilteredArray* items;
@property(strong) NSString* sectionType;
@property(assign) int numCellsPerRow;
@property(strong) NSURL* nextURL;
@property(assign) BOOL retainMultiCellSize;
@property(assign) BOOL equalSizeColumns;

- (int) numRows;

@end


@interface AB_DataSourceBase : NSObject<UITableViewDataSource, UITableViewDelegate>
{
    NSArray* sections;
    NSDictionary* nibs;
    NSDictionary* emptyNibs;
    NSDictionary* heights;
    UITableView* tableView;
    
    IBOutlet UIActivityIndicatorView* spinny;
    IBOutlet UILabel* emptyLabel;
    
    IBOutlet UITableView* setTableView;
    
    id asyncCheckObject;
}


// Override these for custom functionality
- (void) setup;
- (void) setupCell:(UIView*)cell withData:(id)data dataIndexPath:(NSIndexPath*)indexPath;
- (void) triggerNextURL:(NSURL*)url inSection:(AB_SectionInfo*)section;

// Override this to change reloadData behaviour (optional)
- (void) update;

// Call these to set properties
// Don't forget to set reuseidentifier in the xib!
- (void) setNib:(NSString*)nibName forSectionType:(NSString*)sectionType;
- (void) setEmptyNib:(NSString*)nibName forSectionType:(NSString*)sectionType;

- (void) clearSections;
- (void) addSection:(AB_SectionInfo*)section;
- (void) removeSection:(NSUInteger)sectionNum;
- (void) removeSectionObj:(AB_SectionInfo*)section;
- (void) updateSection:(AB_SectionInfo*)section atIndex:(NSUInteger)sectionNum;
- (void) insertSection:(AB_SectionInfo*)section atIndex:(NSUInteger)sectionNum;


// Utitlity
- (id) initWithTableView:(UITableView*)tableView;
- (CGFloat) heightForSectionType:(NSString*)sectionType withData:(id)data;
- (AB_SectionInfo*) section:(int)sectionNum;

- (void) startSpinny;
- (void) stopSpinny;
- (void) showNoLabel;

- (void) reset;

- (id) getAsyncCheckObject;
- (BOOL) testAsyncCheckObject:(id)object;
- (CGFloat) expectedHeight;

@property(strong) IBOutlet UIActivityIndicatorView* spinny;
@property(strong) IBOutlet UILabel* emptyLabel;
@property(readonly) IBOutlet UITableView* tableView;
@property(readonly) RACSignal* updateSignal;

@end
