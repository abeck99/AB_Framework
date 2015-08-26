//
//  AB_LoremParagraphGenerator.m
//  PPA
//
//  Created by phoebe on 8/26/15.
//  Copyright (c) 2015 Prospect Park Alliance. All rights reserved.
//

#import "AB_LoremParagraphGenerator.h"
#import "LoremIpsum.h"

@implementation AB_LoremParagraphGenerator

- (NSString*) textContent
{
    return [LoremIpsum paragraphsWithNumber:self.numParagraphs];
}

@end
