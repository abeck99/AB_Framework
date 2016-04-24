//
//  AB_DataSourceBase.m
//
//  Copyright (c) 2014年 Andrew Beck. All rights reserved.
//

#import "AB_DataSourceBase.h"
#import "AB_DataContainer.h"
#import "AB_Funcs.h"
#import "AB_MultiTableViewCell.h"
#import "AB_ClassExtensions.h"

@interface AB_DataSourceBase()
{
    NSMutableArray* mutableOpenHeaderControllers;
    RACSubject* updateSubject;
}

@end


@implementation AB_DataSourceBase

@synthesize spinny;
@synthesize emptyLabel;
@synthesize tableView;

+ (UINib*) multiNib
{
    static dispatch_once_t pred;
    static UINib* ret = nil;
    
    dispatch_once(&pred, ^{
        NSBundle* frameworkBundle = [NSBundle bundleWithPath:
                                     [[NSBundle mainBundle] pathForResource:@"AB_Framework"
                                                                     ofType:@"framework"
                                                                inDirectory:@"Frameworks"]];
        
        ret = [UINib nibWithNibName:@"MultiTableCell" bundle:frameworkBundle];
    });
    
    return ret;
}

- (id) initWithTableView:(UITableView*)theTableView
{
    if (self = [super init])
    {
        [self setupWithTableView:theTableView];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setupWithTableView:setTableView];
}

- (void) reset
{
    [self clearSections];
    [tableView reloadData];
    [updateSubject sendNext:@YES];
}

- (void) setupWithTableView:(UITableView*)theTableView
{
    updateSubject = [RACSubject subject];
    mutableOpenHeaderControllers = [@[] mutableCopy];
    
    tableView = theTableView;
    nibs = @{};
    emptyNibs = @{};
    heights = @{};
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    tableView.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);

    [self setup];
}

- (void) setup
{
    [self startSpinny];
    emptyLabel.hidden = YES;
    [self clearSections];
}

- (void) updateSectionAnimated:(AB_SectionInfo*)section
{
    if ([sections containsObject:section])
    {
        NSUInteger sectionNumber = [sections indexOfObject:section];
        NSMutableArray* mutableIndexPaths = [@[] mutableCopy];
        for (int i=0; i<section.items.array.count; ++i)
        {
            [mutableIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:sectionNumber]];
        }
        
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithArray:mutableIndexPaths]
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    [self scrollViewDidScroll:tableView];
    [updateSubject sendNext:@YES];
}

- (void) update
{
    [tableView reloadData];
    [self scrollViewDidScroll:tableView];
    [updateSubject sendNext:@YES];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void) triggerNextURL:(NSURL*)url inSection:(AB_SectionInfo*)section
{
    
}

- (void) clearSections
{
    if (sections)
    {
        for (AB_SectionInfo* section in sections)
        {
            [section.headerController closeView];
        }
    }

    sections = @[];
}

- (void) dealloc
{
    if ( tableView.delegate == self )
    {
        tableView.delegate = nil;
    }
    if ( tableView.dataSource == self )
    {
        tableView.dataSource = nil;
    }
    
    for (AB_SectionInfo* section in sections)
    {
        [section.headerController closeView];
    }
}

- (void) addSection:(AB_SectionInfo*)section
{
    NSMutableArray* mutableSections = [sections mutableCopy];
    [mutableSections addObject:section];
    sections = [NSArray arrayWithArray:mutableSections];
}

- (void) removeSectionObj:(AB_SectionInfo*)section
{
    if ( [sections containsObject:section] )
    {
        NSMutableArray* mutableSections = [sections mutableCopy];
        [mutableSections removeObject:section];
        [section.headerController closeView];
        sections = [NSArray arrayWithArray:mutableSections];
    }
}

- (void) removeSection:(NSUInteger)sectionNum
{
    NSMutableArray* mutableSections = [sections mutableCopy];
    [mutableSections removeObjectAtIndex:sectionNum];
    sections = [NSArray arrayWithArray:mutableSections];
}

- (void) updateSection:(AB_SectionInfo*)section atIndex:(NSUInteger)sectionNum
{
    NSMutableArray* mutableSections = [sections mutableCopy];
    [mutableSections replaceObjectAtIndex:sectionNum withObject:section];
    sections = [NSArray arrayWithArray:mutableSections];
}

- (void) insertSection:(AB_SectionInfo*)section atIndex:(NSUInteger)sectionNum
{
    NSMutableArray* mutableSections = [sections mutableCopy];
    [mutableSections insertObject:section atIndex:sectionNum];
    sections = [NSArray arrayWithArray:mutableSections];
}

- (void) setNib:(NSString*)nibName forSectionType:(NSString*)sectionType
{
    [self setNib:nibName forSectionType:sectionType inBundle:[NSBundle mainBundle]];
}

- (void) setNib:(NSString*)nibName forSectionType:(NSString*)sectionType inBundle:(NSBundle*)bundle
{
    UINib* newNib = [UINib nibWithNibName:nibName bundle:bundle];
    
    NSMutableDictionary* mutableNibs = [nibs mutableCopy];
    [mutableNibs setObject:newNib forKey:sectionType];
    nibs = [NSDictionary dictionaryWithDictionary:mutableNibs];

    UIView* nibView = [newNib instantiateWithOwner:nil options:@{}][0];
    
    NSMutableDictionary* mutableHeights = [heights mutableCopy];
    [mutableHeights setObject:[NSNumber numberWithFloat:nibView.frame.size.height] forKey:sectionType];
    heights = [NSDictionary dictionaryWithDictionary:mutableHeights];
}

- (void) setEmptyNib:(NSString*)nibName forSectionType:(NSString*)sectionType
{
    UINib* newNib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
    
    NSMutableDictionary* mutableNibs = [emptyNibs mutableCopy];
    [mutableNibs setObject:newNib forKey:sectionType];
    emptyNibs = [NSDictionary dictionaryWithDictionary:mutableNibs];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)sectionNum
{
    AB_SectionInfo* section = [self section:(int)sectionNum];
    if (section.headerView)
    {
        for (UIView* v in [view.subviews copy])
        {
            if (v != section.headerView)
            {
                [v removeFromSuperview];
            }
        }
        
        if (section.headerView.superview == view)
        {
            return;
        }

        CGRect f = section.headerView.frame;
        f.size.width = self.tableView.frame.size.width;
        
        if (section.headerController)
        {
            [section.headerController openInView:view
                                  withViewParent:section.headerControllerParent
                                       inSection:nil];

            CGRect viewFrame = section.headerController.view.frame;
            viewFrame.size.height = section.headerController.height;
            section.headerController.view.frame = viewFrame;

            [mutableOpenHeaderControllers addObject:section.headerController];
        }
        else
        {
            section.headerView.frame = f;

            if ([view isKindOfClass:[UITableViewHeaderFooterView class]])
            {
                [view addSubview:section.headerView];
            }
            else
            {
                view.backgroundColor = [UIColor clearColor];
                [view addSubview:section.headerView];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)sectionNum
{
    AB_Controller controllerToClose = nil;
    
    for (AB_Controller c in mutableOpenHeaderControllers)
    {
        for (UIView* v in view.subviews)
        {
            if (c.view == v)
            {
                controllerToClose = controllerToClose;
            }
        }
    }
    
    [controllerToClose closeView];
    [mutableOpenHeaderControllers removeObject:controllerToClose];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionNum
{
    AB_SectionInfo* section = [self section:(int)sectionNum];
    if (section.headerHidden)
    {
        return 0.f;
    }
    
    if (section.headerController)
    {
        return section.headerController.height;
    }
    
    return section.headerView
    ? section.headerView.frame.size.height
    : UITableViewAutomaticDimension;
}

- (AB_SectionInfo*) section:(int)sectionNum
{
    return sections[sectionNum];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self section:(int) section].sectionName;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [[self section:(int) section] numRows];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRowsInSection:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray* searchableSections = [NSMutableArray array];
    for ( AB_SectionInfo* sectionInfo in sections )
    {
        if ( sectionInfo.quickLinkable )
        {
            [searchableSections addObject:sectionInfo.sectionName];
        }
    }
    
    return searchableSections.count > 0 ? [NSArray arrayWithArray:searchableSections] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    for ( AB_SectionInfo* section in sections )
    {
        if ( [section.sectionName isEqualToString:title] )
        {
            return [sections indexOfObject:section];
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.f;
}

- (void) setupCell:(UIView*)cell withData:(id)data dataIndexPath:(NSIndexPath*)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [cell prepareForReuse];
}

- (UITableViewCell*) tableView:(UITableView*)theTableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger sectionNum = [indexPath section];
    NSInteger row = [indexPath row];

    AB_SectionInfo* section = [self section:(int) sectionNum];

    if ( section.nextURL && row == [section numRows] - 1 )
    {
        NSURL* url = section.nextURL;
        section.nextURL = nil;

        [self triggerNextURL:url inSection:section];
    }
    
    if ( [section.sectionType isEqualToString:@"Empty"] )
    {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    UITableViewCell* cell = nil;
    
    if ( section.numCellsPerRow == 0 )
    {
        cell = [theTableView dequeueReusableCellWithIdentifier:section.sectionType];
        
        if ( !cell )
        {
            UINib* nib = nibs[section.sectionType];
            cell = [nib instantiateWithOwner:nil options:@{}][0];
            [cell setValue:section.sectionType forKey:@"reuseIdentifier"];
        }
        
        // You may be wondering why I'm doing it this way.
        //      Turns out Mutable index paths hash differently that non-mutable
        //      And internally tableviews seem to use mutable index paths
        //  Converting it this way lets us use it as dictionary keys and such
        NSIndexPath* nonMutableIndexPath = [NSIndexPath indexPathForRow:[indexPath row] inSection:[indexPath section]];
        [self setupCell:cell withData:section.items.array[row] dataIndexPath:nonMutableIndexPath];
    }
    else
    {
        NSString* reuseID = [NSString stringWithFormat:@"%@_Multi_%d", section.sectionType, section.numCellsPerRow];
        
        cell = [theTableView dequeueReusableCellWithIdentifier:reuseID];
        
        if ( !cell )
        {
            cell = [[AB_MultiTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];

//            UINib* nib = [[self class] multiNib];
//            cell = [nib instantiateWithOwner:nil options:@{}][0];
//            [cell setValue:reuseID forKey:@"reuseIdentifier"];
        }
        
        CGRect cellRect = cell.frame;
        cellRect.size.width = theTableView.bounds.size.width;
        cell.frame = cellRect;

        AB_MultiTableViewCell* multiCell = (AB_MultiTableViewCell*)cell;
        multiCell.nib = nibs[section.sectionType];
        multiCell.emptyNib = emptyNibs[section.sectionType];
        multiCell.retainInnerCellSize = section.retainMultiCellSize;
        multiCell.cellSpacing = section.cellSpacing;

        NSArray* groupedArray = [multiCell groupArray:section.items.array groupSize:section.numCellsPerRow enforceSize:section.equalSizeColumns];
        
        [multiCell setData:groupedArray[row]];
        
        NSArray* realCells = [multiCell innerCells];

        int starting = (int) (row * section.numCellsPerRow);
        for ( int i = 0; i < realCells.count; i++ )
        {
            int dataIndex = starting + i;
            NSIndexPath* nonMutableIndexPath = [NSIndexPath indexPathForRow:dataIndex inSection:sectionNum];
            UITableViewCell* realCell = realCells[i];
            
            NSObject* obj = [section.items.array objectAtIndexOrNil:dataIndex];
            if ( obj )
            {
                [self setupCell:realCell withData:section.items.array[dataIndex] dataIndexPath:nonMutableIndexPath];
            }
        }
    }

    return cell;
}

- (void) startSpinny
{
    spinny.hidesWhenStopped = YES;
    [spinny startAnimating];
    spinny.hidden = NO;
}

- (void) stopSpinny
{
    spinny.hidesWhenStopped = YES;
    [spinny stopAnimating];
    spinny.hidden = YES;
}

- (void) showNoLabel
{
    [self stopSpinny];
    emptyLabel.hidden = NO;
}

- (id) getAsyncCheckObject
{
    asyncCheckObject = [[NSObject alloc] init];
    return asyncCheckObject;
}

- (BOOL) testAsyncCheckObject:(id)object
{
    return object == asyncCheckObject;
}

- (RACSignal*) updateSignal
{
    return updateSubject;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//- (NSInteger)numberOfRowsInSection:(NSInteger)section

- (CGFloat) expectedHeight
{
    CGFloat height = 0.f;

    for (NSInteger sectionNum=0; sectionNum<[self numberOfSectionsInTableView:self.tableView]; ++sectionNum)
    {
        CGFloat heightToAdd = [self tableView:self.tableView heightForHeaderInSection:sectionNum];
        if (heightToAdd > 0.f)
        {
            // Add an extra pixel for seperator if the header view exists
            height += 1.f;
        }
        height += heightToAdd;

        AB_SectionInfo* section = sections[sectionNum];
        for (NSInteger rowNum=0; rowNum<[self numberOfRowsInSection:sectionNum]; ++rowNum)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowNum inSection:sectionNum];
            
            UITableViewCell* cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
            CGSize size = [cell sizeThatFits:CGSizeMake(self.tableView.bounds.size.width, CGFLOAT_MAX)];
            height += size.height + 1.f;
        }
        heightToAdd = [self tableView:self.tableView heightForFooterInSection:sectionNum];
        if (heightToAdd > 0.f)
        {
            // Add an extra pixel for seperator if the header view exists
            height += 1.f;
        }
        height += heightToAdd;
    }

    return height;
}

- (NSArray*) visibleCells
{
    NSMutableArray* retCells = [@[] mutableCopy];
    for (id x in [self.tableView visibleCells])
    {
        if ([x isKindOfClass:[AB_MultiTableViewCell class]])
        {
            for (id y in [((AB_MultiTableViewCell*)x) innerCells])
            {
                [retCells addObject:y];
            }
        }
        else
        {
            [retCells addObject:x];
        }
    }
    return [NSArray arrayWithArray:retCells];
}

@end


@implementation AB_SectionInfo

- (id) init
{
    if ( self = [super init ] )
    {
        self.numCellsPerRow = 0;
    }
    
    return self;
}

@synthesize sectionName;
@synthesize headerHidden;
@synthesize items;
@synthesize sectionType;
@synthesize numCellsPerRow;
@synthesize nextURL;
@synthesize retainMultiCellSize;
@synthesize equalSizeColumns;

- (int) numRows
{
    if ( self.numCellsPerRow == 0 )
    {
        return (int) self.items.array.count;
    }
    
    int itemCount = (int) self.items.array.count;
    
    if ( itemCount % self.numCellsPerRow == 0 )
    {
        return itemCount / self.numCellsPerRow;
    }
    
    return ( itemCount / self.numCellsPerRow ) + 1;
}

@end
