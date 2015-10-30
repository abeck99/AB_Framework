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
    
    AB_PauseUpdates* setuABuse;
    AB_PauseUpdates* sectionPause;
}

@end

@implementation AB_PageDataSource

- (void) setup
{
    [super setup];
    
    setuABuse = [[AB_PauseUpdates alloc] init];
    sectionPause = [[AB_PauseUpdates alloc] init];
    
    [setuABuse pauseDuringExecution:^
    {
        mutableHeaderControllers = [@[] mutableCopy];
        
        [self setNib:@"ControllerTableViewCell" forSectionType:@"Controllers" inBundle:[NSBundle bundleForClass:[AB_PageDataSource class]]];
        
        [self rac_liftSelector:@selector(setupSectionFromModels:inContext:)
         withSignalOfArguments:[[RACSignal combineLatest:@[
                                                          RACObserve(self, contentModels),
                                                          RACObserve(self, context),
                                                          ]] pause:setuABuse]];
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

- (void) setupSectionFromModels:(NSArray*)contentModels
                      inContext:(NSString*)context
{
    [self clearSections];

    [sectionPause pauseDuringExecution:^
     {
        for (AB_BaseModel* model in contentModels)
        {
            [self _setupSectionFromModel:model inContext:context];
        }

        [self update];
     }];
}

//      TODO: Make "ContentModel" and "Submodels" as the properties, instead of a single content model
//- (void) _setupSectionFromModel:(AB_BaseModel*)model inContext:context
//{
//    if (!model)
//    {
//        return;
//    }
//    
////    NSArray* submodels = [[AB_TableViewModelItemsResolver get]
////                          itemsForModel:model
////                          inContext:context];
////
//    [self _setupSectionFromModel:model
//                       withItems:submodels ? submodels : @[model]
//                       inContext:context];
//}
//
//- (void) _setupSectionFromModel:(AB_ContentModel*)model withItems:(NSArray*)items inContext:context


- (void) _setupSectionFromModel:(AB_BaseModel*)model inContext:context
{
    [sectionPause pauseDuringExecution:^
     {
         NSArray* items = @[model];
         
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
                [self rac_liftSelector:@selector(updateSection:withItems:)
                 withSignalOfArguments:[[RACSignal combineLatest:@[
                                                                   [RACSignal return:placeholderSection],
                                                                   [RACObserve(sectionHeader, sectionOpen)
                                                                    map:^(NSNumber* open)
                                                                    {
                                                                        return [open boolValue]
                                                                        ? items
                                                                        : @[];
                                                                    }]
                                                                   ]] pause:sectionPause]];
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

        if (!controller)
        {
            return;
        }
        
        [controllerCell setController:controller
                   withViewController:viewController
                              section:viewSection];
    }
    else
    {
        [super setupCell:cell withData:data dataIndexPath:indexPath];
    }
}

- (CGFloat) heightForSectionType:(NSString*)sectionType withData:(id)data
{
    if ([sectionType isEqualToString:@"Controllers"])
    {
        AB_Controller controller = [[AB_ControllerResolver get]
                                    controllerForModel:data
                                    withDisplayType:DisplayType_Cell
                                    inContext:self.context
                                    source:@"HEIGHT"];

        if (!controller)
        {
            //197.0
            //277
            return 0.f;
        }
        
        CGRect controllerFrame = controller.view.frame;
        controllerFrame.size.width = self.tableView.bounds.size.width;

        UIView* parentView = [[UIView alloc] initWithFrame:controllerFrame];
        [self.tableView.superview addSubview:parentView];
        
        [controller openInView:parentView withViewParent:nil inSection:nil];
        
        CGFloat height = controller.height;
        
        [controller closeView];
        [parentView removeFromSuperview];
        
        return height;
    }
    else
    {
        return [super heightForSectionType:sectionType withData:data];
    }
}

@end