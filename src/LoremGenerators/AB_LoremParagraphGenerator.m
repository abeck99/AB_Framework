//
//  AB_LoremParagraphGenerator.m
//  AB
//
//  Created by phoebe on 8/26/15.
//

#import "AB_LoremParagraphGenerator.h"
#import "LoremIpsum.h"

@implementation AB_LoremParagraphGenerator

- (NSString*) textContent
{
    return [LoremIpsum paragraphsWithNumber:self.numParagraphs];
}

@end
