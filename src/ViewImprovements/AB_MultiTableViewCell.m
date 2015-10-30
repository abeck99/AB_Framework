//
//  AB_MultiTableViewCell.m

//
//  Created by phoebe on 15/1/9.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import "AB_MultiTableViewCell.h"
#import "AB_Funcs.h"
#import "AB_ClassExtensions.h"

@implementation AB_EmptyDataPlaceholder

@end

@interface AB_MultiTableViewCell()
{
    NSArray* _innerCells;
    
    NSArray* validCells;
    NSArray* emptyCells;
}

@end

@implementation AB_MultiTableViewCell

@synthesize nib;
@synthesize emptyNib;
@synthesize retainInnerCellSize;

- (BOOL) isValidObject:(id)obj
{
    return obj != [NSNull null];
}

- (void) setData:(NSArray*)data
{
    [self cleanViews];
    
    NSMutableArray* newInnerCells = [@[] mutableCopy];
    
    int validCellIndex = 0;
    int emptyCellIndex = 0;
    
    for ( NSObject* obj in data )
    {
        UIView* cell = nil;

        if ( [obj isKindOfClass:[AB_EmptyDataPlaceholder class]] )
        {
            if ( !self.emptyNib )
            {
                cell = (UIView*) [NSNull null];
            }
            else if ( emptyCellIndex < emptyCells.count )
            {
                cell = emptyCells[emptyCellIndex];
            }
            else
            {
                cell = [self.emptyNib instantiateWithOwner:nil options:@{}][0];

                NSMutableArray* mutableEmptyCells = [emptyCells mutableCopy];
                [mutableEmptyCells addObject:cell];
                emptyCells = [NSArray arrayWithArray:mutableEmptyCells];
            }
            
            emptyCellIndex++;
        }
        else
        {
            if ( validCellIndex < validCells.count )
            {
                cell = validCells[validCellIndex];
            }
            else
            {
                cell = [self.nib instantiateWithOwner:nil options:@{}][0];

                NSMutableArray* mutableValidCells = [validCells mutableCopy];
                [mutableValidCells addObject:cell];
                validCells = [NSArray arrayWithArray:mutableValidCells];
            }
            
            validCellIndex++;
        }
        
        if ( [self isValidObject:cell] )
        {
            [realContentView addSubview:cell];
        }
        [newInnerCells addObject:cell];
    }
    
    _innerCells = [NSArray arrayWithArray:newInnerCells];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentFrame = self.frame;
    contentFrame.origin = CGPointZero;
    
    realContentView.frame = contentFrame;
    
    contentFrame.size.width /= _innerCells.count;

    if ( self.retainInnerCellSize )
    {
        for ( UIView* cell in _innerCells )
        {
            if ( ![self isValidObject:cell] )
            {
                continue;
            }

            CGRect cellFrame = cell.frame;
            cellFrame.origin.x = contentFrame.origin.x + (contentFrame.size.width/2.f) - (cellFrame.size.width/2.f);
            cell.frame = cellFrame;
            contentFrame.origin.x += contentFrame.size.width;
            [cell setNeedsLayout];
        }
    }
    else
    {
        for ( UIView* cell in _innerCells )
        {
            if ( ![self isValidObject:cell] )
            {
                continue;
            }

            cell.frame = contentFrame;
            contentFrame.origin.x += contentFrame.size.width;
            [cell setNeedsLayout];
        }
    }
}

- (NSArray*) innerCells
{
    return _innerCells;
}

- (void) setNeedsLayout
{
    [super setNeedsLayout];
}

- (void) cleanViews
{
    validCells = validCells ? validCells : @[];
    emptyCells = emptyCells ? emptyCells : @[];

    for ( UIView* view in realContentView.subviews )
    {
        if ([view conformsToProtocol:@protocol(AB_TableView)])
        {
            [(id<AB_TableView>)view prepareForReuse];
        }
        [view removeFromSuperview];
    }
    
    _innerCells = @[];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    [self cleanViews];
}

- (NSArray*) groupArray:(NSArray*)inArray groupSize:(int)groupSize enforceSize:(BOOL)enforceSize
{
    NSMutableArray* outArray = [@[] mutableCopy];
    
    for ( int i = 0; i < inArray.count; i = i + groupSize )
    {
        NSMutableArray* groupedArray = [@[] mutableCopy];
        for ( int j = 0; j < groupSize; j++ )
        {
            id obj = [inArray objectAtIndexOrNil:i + j];
            if ( obj )
            {
                [groupedArray addObject:obj];
            }
            else if (enforceSize)
            {
                [groupedArray addObject:[[AB_EmptyDataPlaceholder alloc] init]];
            }
        }
        
        [outArray addObject:[NSArray arrayWithArray:groupedArray]];
    }
    
    return [NSArray arrayWithArray:outArray];
}

@end
