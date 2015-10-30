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
      withSignalsFromArray:@[RACObserve(self, model)]];
}

- (void) pushModel:(AB_BaseModel*)model
{
    dataSource.context = @"Popup";
    [dataSource setSection:self];
    dataSource.contentModels = model ? @[model] : @[];
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
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = heightReferenceView.frame.size.height;
    self.frame = selfFrame;
    
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