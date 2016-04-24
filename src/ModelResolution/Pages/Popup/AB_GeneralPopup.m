//
//  AB_GeneralPopup.m
//  AB
//
//  Created by Andrew on 09/14/2015.
//

#import "AB_GeneralPopup.h"
#import "ReactiveCocoa.h"

@interface AB_GeneralPopup()

@end

@implementation AB_GeneralPopup

+ (UINib*) baseNib
{
    RETURN_NIB_NAMED(@"GeneralPopup")
}

+ (void) load
{
    [[self class] baseNib];
}

- (BOOL) isOverlayPopup
{
    return NO;
}

- (void) setup
{
    [super setup];
    
    [self rac_liftSelector:@selector(pushModel:)
      withSignalsFromArray:@[RACObserve(self, models)]];
}

- (void) pushModel:(NSArray*)models
{
    NSMutableArray* mutableFullContexts = [@[] mutableCopy];
    for (NSString* context in self.contexts)
    {
        if ([context caseInsensitiveCompare:@""] == NSOrderedSame)
        {
            NSLog(@"BREAK");
        }
        [mutableFullContexts addObject:context];
    }
    [mutableFullContexts addObject:@"Popup"];
    NSArray* fullContexts = [NSArray arrayWithArray:mutableFullContexts];

    dataSource.contexts = fullContexts;
    [dataSource setSection:self];
    dataSource.contentModels = models ? models : @[];
    tableViewHeightConstraint.constant = [dataSource expectedHeight];
    
    [self updateConstraints];
    [self layoutIfNeeded];
    if (dataSource.tableView.frame.size.height <= tableViewHeightConstraint.constant+0.001f)
    {
        dataSource.tableView.scrollEnabled = NO;
    }
    else
    {
        dataSource.tableView.scrollEnabled = YES;
    }
    
    dataSource.tableView.scrollEnabled = YES;
    [self recalculateDestination];
}





- (void) pushControllerWithName:(id)name;{}
- (void) pushControllerWithName:(id)name
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;{}
- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock;{}
- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;{}
- (void) pushControllerWithName:(id)name
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                shouldPushState:(BOOL)shouldPushState;{}
- (void) pushControllerWithName:(id)name
                withConfigBlock:(CreateControllerBlock)configurationBlock
                  withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
                shouldPushState:(BOOL)shouldPushState;{}
- (void) pushController:(AB_Controller)sectionController;{}
- (void) pushController:(AB_Controller)sectionController
              forceOpen:(BOOL)forceOpen
            pushOnState:(BOOL)shouldPushOnState;{}
- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock;{}
- (void) pushController:(AB_Controller)sectionController
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;{}
- (void) pushController:(AB_Controller)sectionController
        withConfigBlock:(CreateControllerBlock)configurationBlock
          withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation;{}
- (void) pushControllerWithName:(id)name withConfigBlock:(CreateControllerBlock)configurationBlock withAnimation:(id<UIViewControllerAnimatedTransitioning>)animation forceOpen:(BOOL)forceOpen pushOnState:(BOOL)shouldPushOnState{}

- (void) popController
{
    [self close];
}
- (void) popControllerWithAnimation:(id<UIViewControllerAnimatedTransitioning>)animation
{
    [self close];
}

- (void) clearBackHistory
{
    
}

@end