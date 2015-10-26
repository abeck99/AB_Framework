//
//  AB_ScrollPageSectionViewController.m
//  AnsellInterceptApp
//
//  Created by andrew on 2/7/15.
//  Copyright (c) 2015 Ansell. All rights reserved.
//

#import "AB_ScrollPageSectionViewController.h"
#import "AB_Controllers.h"

@interface AB_ScrollPageSectionViewController ()
{
    UIView* scrollContent;
    NSArray* controllers;
}

@end

@implementation AB_ScrollPageSectionViewController

- (void) bind
{
    [super bind];
    
    scrollContent = [[UIView alloc] initWithFrame:scrollView.bounds];
    scrollContent.userInteractionEnabled = YES;
    scrollContent.backgroundColor = [UIColor clearColor];
    scrollContent.autoresizesSubviews = NO;
    [scrollView addSubview:scrollContent];
    
    controllers = @[];
    
    NSArray* controllersToLoad = [self controllers];
    [self expandScrollContentTo:controllersToLoad.count];
    
    int index = 0;
    for ( NSDictionary* controllerType in [self controllers] )
    {
        [self loadController:controllerType[@"name"]
                     atIndex:index];
        ++index;
    }
    
    scrollView.delegate = self;
    
    [self showButtons];
}

- (NSArray*) controllers
{
    return @[];
}

- (void) expandScrollContentTo:(NSUInteger)size
{
    size = MAX(1, size);
    
    CGRect scrollContentFrame = scrollContent.frame;
    scrollContentFrame.size.width = scrollView.bounds.size.width * size;
    scrollContent.frame = scrollContentFrame;
    scrollView.contentSize = scrollContentFrame.size;
}

- (void) loadController:(id)controllerName atIndex:(int)index
{
    [self expandScrollContentTo:controllers.count + 1];
    
    AB_Controller page = [getController() controllerForTag:controllerName];
    
    CGRect newPageFrame = scrollView.bounds;
    newPageFrame.origin.x = index * scrollView.bounds.size.width;
    
    [page openInView:scrollContent
      withViewParent:self
           inSection:self];
    
    NSMutableArray* mutableControllers = [controllers mutableCopy];
    [mutableControllers addObject:page];
    controllers = [NSArray arrayWithArray:mutableControllers];
}

- (void) pageUpdatedTo:(AB_Controller)page
{
    
}


- (void) showButtonsForPage:(NSUInteger)pageNum
{
    leftButton.hidden = pageNum == 0;
    rightButton.hidden = pageNum >= controllers.count - 1;
    
    [self pageUpdatedTo:controllers[pageNum]];
}

- (void) showButtons
{
    NSUInteger pageNum = [self pageNum];
    [self showButtonsForPage:pageNum];
}

- (NSUInteger) pageNum
{
    return MAX(0, MIN(controllers.count - 1, ( scrollView.contentOffset.x + 4.f ) / scrollView.frame.size.width));
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self showButtons];
}

- (void) goToPage:(NSUInteger)pageNum
{
    [scrollView setContentOffset:CGPointMake(scrollView.bounds.size.width * pageNum, 0.f) animated:YES];
    [self showButtonsForPage:pageNum];
}

- (IBAction) goLeft:(id)sender
{
    NSUInteger pageNum = [self pageNum];
    if ( pageNum > 0 )
    {
        [self goToPage:pageNum - 1];
    }
}

- (IBAction) goRight:(id)sender
{
    NSUInteger pageNum = [self pageNum];
    if ( pageNum < controllers.count - 1 )
    {
        [self goToPage:pageNum + 1];
    }
}

@end
