//
//  AB_SectionHeader.h
//  AB
//
//  Created by phoebe on 9/15/15.
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"

@protocol AB_SectionHeader

- (void) sectionHeaderInitItems;
@property(assign) CGFloat openAmount;
@property(strong) RACCommand* toggleOpenCommand;

@end