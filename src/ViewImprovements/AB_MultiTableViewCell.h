//
//  AB_MultiTableViewCell.h
//  GoHeroClient
//
//  Created by phoebe on 15/1/9.
//  Copyright (c) 2015年 Hero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AB_MultiTableViewCell : UITableViewCell
{
    IBOutlet UIView* realContentView;
}

- (void) setData:(NSArray*)data;
- (NSArray*) innerCells;

@property(strong) UINib* nib;
@property(strong) UINib* emptyNib;

- (NSArray*) groupArray:(NSArray*)inArray groupSize:(int)groupSize;

@end

@interface AB_EmptyDataPlaceholder : NSObject

@end
