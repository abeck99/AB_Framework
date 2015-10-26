//
//  AB_LoremGenerator.m
//  AB
//
//  Created by phoebe on 8/26/15.
//

#import "AB_LoremWordGenerator.h"
#import "LoremIpsum.h"

@implementation AB_LoremWordGenerator

- (NSString*) textContent
{
    return [LoremIpsum wordsWithNumber:self.numWords];
}

@end
