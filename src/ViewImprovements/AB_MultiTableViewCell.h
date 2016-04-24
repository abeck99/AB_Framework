//
//  AB_MultiTableViewCell.h

//
//  Created by phoebe on 15/1/9.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AB_PassthroughView.h"

@protocol AB_TableView

- (void) prepareForReuse;

@end

@interface AB_MultiTableViewCell : AB_PassthroughTableViewCell
{
    UIView* innerContentView;
}

- (void) setData:(NSArray*)data;
- (NSArray*) innerCells;

@property(strong) UINib* nib;
@property(strong) UINib* emptyNib;
@property(assign) BOOL retainInnerCellSize;
@property(assign) CGFloat cellSpacing;

- (NSArray*) groupArray:(NSArray*)inArray groupSize:(int)groupSize enforceSize:(BOOL)enforceSize;

@end

@interface AB_EmptyDataPlaceholder : NSObject

@end
