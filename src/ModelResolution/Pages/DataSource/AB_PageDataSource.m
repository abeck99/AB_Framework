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
    
    AB_PauseUpdates* setupPause;
    AB_PauseUpdates* sectionPause;
    
    RACCommand* toggleSectionOpenCommand;
}

@end

@implementation AB_PageDataSource

- (void) setup
{
    [super setup];
    
    _numCellsInRow = 1;
    
    setupPause = [[AB_PauseUpdates alloc] init];
    sectionPause = [[AB_PauseUpdates alloc] init];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    [setupPause pauseDuringExecution:^
     {
         [self setNib:@"ControllerTableViewCell" forSectionType:@"Controllers" inBundle:[NSBundle bundleForClass:[AB_PageDataSource class]]];
         
         [self rac_liftSelector:@selector(setupSectionFromModels:inContexts:)
          withSignalOfArguments:[[RACSignal combineLatest:@[
                                                            RACObserve(self, contentModels),
                                                            RACObserve(self, contexts),
                                                            ]] pause:setupPause]];
     }];
    
    
    @weakify(self)
    toggleSectionOpenCommand = [[RACCommand alloc]
                                initWithSignalBlock:^RACSignal*(id<AB_SectionHeader> sectionHeader)
                                {
                                    @strongify(self)
                                    NSArray* capturedSections = [self sections];
                                    
                                    AB_SectionInfo* section =
                                    Underscore.array(capturedSections)
                                    .filter(^BOOL(AB_SectionInfo* section)
                                            {
                                                return (id)section.headerController == (id)sectionHeader;
                                            })
                                    .first;
                                    
                                    if (!section)
                                    {
                                        return [RACSignal empty];
                                    }
                                    
                                    NSUInteger sectionNum = [capturedSections indexOfObject:section];
                                    if (sectionNum == NSNotFound)
                                    {
                                        return [RACSignal empty];
                                    }
                                    
                                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:sectionNum];
                                    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
                                    
                                    BOOL shouldOpen = NO;
                                    
                                    if (!cell || !cell.superview || sectionHeader.openAmount <= 0.f)
                                    {
                                        shouldOpen = YES;
                                    }
                                    else
                                    {
                                        CGRect cellFrameInTableView = [self.tableView.superview convertRect:cell.frame fromView:cell.superview];
                                        CGRect visibleRect = CGRectIntersection(self.tableView.frame, cellFrameInTableView);
                                        CGFloat visibleHeight = visibleRect.size.height;
                                        
                                        if (section.headerView)
                                        {
                                            CGRect sectionHeaderInTableView = [self.tableView.superview convertRect:section.headerView.frame
                                                                                                            fromView:section.headerView.superview];
                                            visibleHeight -= CGRectIntersection(visibleRect, sectionHeaderInTableView).size.height;
                                        }
                                        
                                        CGFloat fullHeight = Clamp(cellFrameInTableView.size.height, 1.f, self.tableView.frame.size.height);
                                        if (visibleHeight <= 1.f || visibleHeight/fullHeight < 0.6f)
                                        {
                                            shouldOpen = YES;
                                        }
                                    }
                                    
                                    sectionHeader.openAmount = shouldOpen ? 1.f : 0.f;
                                    
                                    if (shouldOpen)
                                    {
                                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:sectionNum]
                                                              atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                    }
                                    
                                    return [[RACSignal empty] delay:0.1f];
                                }];
}


- (NSArray*) sections
{
    return sections;
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
- (NSArray*) sectionModelsForModel:(AB_BaseModel*)model inContext:(NSArray*)contexts
{
    NSArray* submodels = model ? @[model] : @[];
    return @[[[AB_SubModelInfo alloc] initWithSubmodels:submodels numSubmodelsPerRow:1]];
}

+ (id) objectForModel:(AB_BaseModel*)model submodels:(NSArray*)submodels
{
    NSMutableArray* hashes = [@[[NSString stringWithFormat:@"%llu", (unsigned long long)[model hash]]] mutableCopy];
    
    for (AB_BaseModel* submodel in submodels)
    {
        [hashes addObject:[NSString stringWithFormat:@"%llu", (unsigned long long)[submodel hash]]];
    }
    
    return [hashes componentsJoinedByString:@"-"];
}

- (void) setupSectionFromModels:(NSArray*)contentModels
                     inContexts:(NSArray*)contexts
{
    BOOL animate = NO;
    
    [sectionPause pauseDuringExecution:^
     {
         NSMutableDictionary* mutableExistingModels =
         [Underscore.array(sections)
          .toDictionary(^(AB_SectionInfo* section)
                        {
                            return @[
                                     [AB_PageDataSource objectForModel:section.headerModel submodels:section.items.fullArray],
                                     section,
                                     ];
                        }) mutableCopy];
         
         NSDate* startDate = [NSDate date];
         
         if (animate)
         {
             [self.tableView beginUpdates];
         }
         
         int sectionsAdded = 0;
         int sectionsRemoved = 0;
         int sectionsMoved = 0;
         
         NSArray* previousSections = sections;

         sections = Underscore.array(contentModels)
         .map(^(AB_BaseModel* model)
              {
                  return [self expandModel:model];
              })
         .flatten
         .map(^(AB_BaseModel* model)
              {
                  NSArray* submodelInfoList = [self sectionModelsForModel:model inContext:contexts];
                  
                  return Underscore.array(submodelInfoList)
                  .map(^(AB_SubModelInfo* submodelInfo)
                       {
                           id description = [AB_PageDataSource objectForModel:model submodels:submodelInfo.submodels];
                           
                           AB_SectionInfo* section = [mutableExistingModels objectForKey:description];
                           
                           if (section)
                           {
                               [mutableExistingModels removeObjectForKey:description];
                           }
                           else
                           {
                               section =
                               [self _setupSectionFromModel:model
                                                  withItems:submodelInfo.submodels
                                                  inContext:contexts];
                           }
                           
                           section.numCellsPerRow = submodelInfo.numSubmodelsPerRow;
                           section.equalSizeColumns = section.numCellsPerRow > 1;
                           section.cellSpacing = submodelInfo.cellSpacing;
                           
                           return section;
                       })
                  .unwrap;
              })
         .flatten
         .unwrap;
         
         for (AB_SectionInfo* section in [mutableExistingModels allValues])
         {
             [section.headerController closeView];
         }

         for (int i=0; i<previousSections.count; i++)
         {
             AB_SectionInfo* previousSection = previousSections[i];
             
             NSUInteger indexOfNewSection = [sections indexOfObject:previousSection];
             if (indexOfNewSection == NSNotFound)
             {
                 sectionsRemoved++;
                 if (animate)
                 {
                     [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:i]
                                   withRowAnimation:UITableViewRowAnimationNone];
                 }
             }
         }
         
         for (int i=0; i<sections.count; i++)
         {
             AB_SectionInfo* section = sections[i];
             
             NSUInteger indexOfPreviousSection = [previousSections indexOfObject:section];
             if (indexOfPreviousSection == NSNotFound)
             {
                 sectionsAdded++;
                 if (animate)
                 {
                     [self.tableView insertSections:[NSIndexSet indexSetWithIndex:i]
                                   withRowAnimation:UITableViewRowAnimationNone];
                 }
             }
             else if (i != indexOfPreviousSection)
             {
                 sectionsMoved++;
                 if (animate)
                 {
                     [self.tableView moveSection:indexOfPreviousSection toSection:i];
                 }
             }
         }
         
         [self postProcessSections];
                  
         if (animate)
         {
             [self.tableView endUpdates];
         }
         else
         {
             [self.tableView reloadData];
             self.tableView.contentOffset = CGPointZero;
//             [self.tableView setContentOffset:CGPointZero animated:NO];
         }
         
         CGFloat pageLoadTime = fabs([startDate timeIntervalSinceNow]);
         
//         NSLog(@"update (+%02d, -%02d, .%02d) page time: %g", sectionsAdded, sectionsRemoved, sectionsMoved, pageLoadTime);
         
         if (pageLoadTime > 0.2f)
         {
             NSLog(@"Page loading taking a long time");
         }
         
         [self pageUpdated];
     }];
}

- (void) postProcessSections
{
    
}

- (AB_SectionInfo*) _setupSectionFromModel:(AB_BaseModel*)model withItems:(NSArray*)items inContext:(NSArray*)contexts
{
     AB_SectionInfo* placeholderSection = [[AB_SectionInfo alloc] init];
     
     AB_Controller headerController = [[AB_ControllerResolver get]
                                       controllerForModel:model
                                       withDisplayType:DisplayType_SectionHeader
                                       inContext:contexts
                                       source:@"HEADER"];
     
     if (headerController)
     {
         placeholderSection.headerHidden = NO;
         placeholderSection.headerController = headerController;
         placeholderSection.headerView = headerController.view;
         placeholderSection.headerModel = model;
         
         CGRect viewFrame = headerController.view.frame;
         viewFrame.size.height = headerController.height;
         headerController.view.frame = viewFrame;
         
         if ([headerController conformsToProtocol:@protocol(AB_SectionHeader)])
         {
             id<AB_SectionHeader> sectionHeader = (id<AB_SectionHeader>)headerController;
             
             [sectionHeader sectionHeaderInitItems];
             sectionHeader.toggleOpenCommand = toggleSectionOpenCommand;
             
             @weakify(self)
             __weak AB_PauseUpdates* weakSectionPause = sectionPause;
             [RACObserve(sectionHeader, openAmount)
              subscribeNext:^(id x)
              {
                  @strongify(self)
                  AB_PauseUpdates* strongPauseUpdates = weakSectionPause;
                  if (strongPauseUpdates.paused)
                  {
                      [self.tableView reloadData];
                  }
                  else
                  {
                      [self updateSectionAnimated:placeholderSection];
                  }
              }];

             placeholderSection.items = [[AB_FilteredArray alloc]
                                         initWithArray:items];
         }
         else
         {
             placeholderSection.items = [[AB_FilteredArray alloc]
                                         initWithArray:items];
         }
     }
     else
     {
         placeholderSection.headerHidden = YES;
         placeholderSection.items = [[AB_FilteredArray alloc]
                                     initWithArray:items];
     }
     
     placeholderSection.sectionType = @"Controllers";
     placeholderSection.numCellsPerRow = self.numCellsInRow;
     // placeholderSection.retainMultiCellSize = placeholderSection.numCellsPerRow > 1;
     placeholderSection.equalSizeColumns = placeholderSection.numCellsPerRow > 1;
    
    return placeholderSection;
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
                                    inContext:self.contexts
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
    [[RACScheduler mainThreadScheduler]
     afterDelay:0.1f schedule:^
     {
         self.tableView.contentOffset = CGPointZero;
     }];
}

- (void) pageUpdated
{
    
}

@end

@implementation AB_SubModelInfo

- (instancetype) initWithSubmodels:(NSArray*)submodels numSubmodelsPerRow:(int)numSubmodelsPerRow
{
    if (self = [super init])
    {
        _submodels = submodels;
        _numSubmodelsPerRow = numSubmodelsPerRow;
        _cellSpacing = 0.f;
    }
    return self;
}

- (instancetype) initWithSubmodels:(NSArray*)submodels numSubmodelsPerRow:(int)numSubmodelsPerRow cellSpacing:(CGFloat)cellSpacing
{
    if (self = [super init])
    {
        _submodels = submodels;
        _numSubmodelsPerRow = numSubmodelsPerRow;
        _cellSpacing = cellSpacing;
    }
    return self;
}

@end
