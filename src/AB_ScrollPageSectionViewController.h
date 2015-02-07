//
//  AB_ScrollPageSectionViewController.h
//  AnsellInterceptApp
//
//  Created by andrew on 2/7/15.
//  Copyright (c) 2015 Ansell. All rights reserved.
//

#import "AB_SectionViewController.h"

@interface AB_ScrollPageSectionViewController : AB_SectionViewController<UIScrollViewDelegate>
{
    IBOutlet UIScrollView* scrollView;
    
    IBOutlet UIButton* leftButton;
    IBOutlet UIButton* rightButton;
   
}

- (NSArray*) controllers;
- (void) pageUpdatedTo:(AB_Controller)page;
- (NSUInteger) pageNum;

- (IBAction) goLeft:(id)sender;
- (IBAction) goRight:(id)sender;


@end
