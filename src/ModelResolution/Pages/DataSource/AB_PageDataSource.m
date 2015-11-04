//
//  AB_PageDataSource.m
//  AB
//
//  Created by Andrew on 09/15/2015.
//

#import "AB_PageDataSource.h"
#import "AB_ControllerResolver.h"
#import "AB_ControllerTableViewCell.h"
#import "Underscore.h"
#import "AB_PauseUpdates.h"


@interface AB_PageDataSource()
{
    __weak AB_Controller viewController;
    __weak AB_Section viewSection;
    
    NSMutableArray* mutableHeaderControllers;
    
    AB_PauseUpdates* setupPause;
    AB_PauseUpdates* sectionPause;
}

@end

@implementation AB_PageDataSource

- (void) setup
{
    [super setup];
    
    setupPause = [[AB_PauseUpdates alloc] init];
    sectionPause = [[AB_PauseUpdates alloc] init];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    [setupPause pauseDuringExecution:^
     {
         mutableHeaderControllers = [@[] mutableCopy];
         
         [self setNib:@"ControllerTableViewCell" forSectionType:@"Controllers" inBundle:[NSBundle bundleForClass:[AB_PageDataSource class]]];
         
         [self rac_liftSelector:@selector(setupSectionFromModels:inContext:)
          withSignalOfArguments:[[RACSignal combineLatest:@[
                                                            RACObserve(self, contentModels),
                                                            RACObserve(self, context),
                                                            ]] pause:setupPause]];
     }];
}

- (void) setSection:(AB_Section)section
{
    viewSection = section;
}

- (void) setViewController:(AB_Controller)controller
{
    viewController = controller;
}

// Each model returned from this will be a seperate section
- (NSArray*) expandModel:(AB_BaseModel*)model
{
    return model
    ? @[model]
    : @[];
}

// Each model returned from here will be a list of items in the section
- (NSArray*) sectionModelsForModel:(AB_BaseModel*)model inContext:(NSString*)context
{
    return model
    ? @[model]
    : @[];
}

- (void) setupSectionFromModels:(NSArray*)contentModels
                      inContext:(NSString*)context
{
    [self clearSections];
    
    [sectionPause pauseDuringExecution:^
     {
         for (AB_BaseModel* model in contentModels)
         {
             for (AB_BaseModel* rootModel in [self expandModel:model])
             {
                 NSArray* submodels = [self sectionModelsForModel:rootModel inContext:context];
                 [self _setupSectionFromModel:rootModel
                                    withItems:submodels
                                    inContext:context];
             }
         }
         
         [self update];
     }];
}

- (void) _setupSectionFromModel:(AB_BaseModel*)model withItems:(NSArray*)items inContext:context
{
    [sectionPause pauseDuringExecution:^
     {
         AB_SectionInfo* placeholderSection = [[AB_SectionInfo alloc] init];
         
         AB_Controller headerController = [[AB_ControllerResolver get]
                                           controllerForModel:model
                                           withDisplayType:DisplayType_SectionHeader
                                           inContext:context
                                           source:@"HEADER"];
         
         if (headerController)
         {
             placeholderSection.headerHidden = NO;
             placeholderSection.headerController = headerController;
             placeholderSection.headerView = headerController.view;
             
             if ([headerController conformsToProtocol:@protocol(AB_SectionHeader)])
             {
                 id<AB_SectionHeader> sectionHeader = (id<AB_SectionHeader>)headerController;
                 
                 [sectionHeader sectionHeaderInitItems];
                 
                 @weakify(self)
                 [[RACObserve(sectionHeader, openAmount) pause:sectionPause]
                  subscribeNext:^(id x)
                  {
                      @strongify(self)
                      [self updateSectionAnimated:placeholderSection];
                  }];

                 placeholderSection.items = [[AB_FilteredArray alloc]
                                             initWithArray:items];
             }
             else
             {
                 placeholderSection.items = [[AB_FilteredArray alloc]
                                             initWithArray:items];
             }
             
             [mutableHeaderControllers addObject:headerController];
         }
         else
         {
             placeholderSection.headerHidden = YES;
             placeholderSection.items = [[AB_FilteredArray alloc]
                                         initWithArray:items];
         }
         
         placeholderSection.sectionType = @"Controllers";
         placeholderSection.numCellsPerRow = 1;
         
         [self addSection:placeholderSection];
     }];
}

- (void) dealloc
{
    for (AB_Controller c in [mutableHeaderControllers copy])
    {
        [c closeView];
    }
}

- (void) updateSection:(AB_SectionInfo*)section withItems:(NSArray*)items
{
    if (![sections containsObject:section])
    {
        return;
    }
    
    [tableView beginUpdates];
    
    NSUInteger sectionNum = [sections indexOfObject:section];
    
    [tableView
     deleteRowsAtIndexPaths:Underscore.array(section.items.array)
     .mapWithIndex(^(id item, NSUInteger i)
                   {
                       return [NSIndexPath indexPathForItem:i inSection:sectionNum];
                   }).unwrap
     withRowAnimation:UITableViewRowAnimationFade];
    
    section.items = [[AB_FilteredArray alloc] initWithArray:items];
    
    [tableView
     insertRowsAtIndexPaths:Underscore.array(section.items.array)
     .mapWithIndex(^(id item, NSUInteger i)
                   {
                       return [NSIndexPath indexPathForItem:i inSection:sectionNum];
                   }).unwrap
     withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView endUpdates];
    
    if (section.items.array.count > 0)
    {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                             inSection:sectionNum]
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
    }
    
    [self update];
    
}

- (void) setupCell:(UIView*)cell withData:(id)data dataIndexPath:(NSIndexPath*)indexPath
{
    cell.clipsToBounds = YES;
    
    if ([cell isKindOfClass:[AB_ControllerTableViewCell class]])
    {
        AB_ControllerTableViewCell* controllerCell = (AB_ControllerTableViewCell*)cell;
        AB_Controller controller = [[AB_ControllerResolver get]
                                    controllerForModel:data
                                    withDisplayType:DisplayType_Cell
                                    inContext:self.context
                                    source:@"CELL V"];
        
        cell.clipsToBounds = controller.view.clipsToBounds;
        
        if (!controller)
        {
            return;
        }
        
        [controllerCell setController:controller
                   withViewController:viewController
                              section:viewSection];
        
        AB_SectionInfo* sectionInfo = [self section:(int)[indexPath section]];
        if ([sectionInfo.headerController conformsToProtocol:@protocol(AB_SectionHeader)])
        {
            NSObject<AB_SectionHeader>* header = (NSObject<AB_SectionHeader>*)sectionInfo.headerController;
            controllerCell.header = header;
        }
        else
        {
            controllerCell.header = nil;
        }
    }
    else
    {
        [super setupCell:cell withData:data dataIndexPath:indexPath];
    }
}

- (void) resetPosition
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView setContentOffset:CGPointZero animated:NO];
    });
}

@end