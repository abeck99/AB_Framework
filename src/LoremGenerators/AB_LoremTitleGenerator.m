//
//  AB_LoremTitleGenerator.m
//  AB
//
//  Created by phoebe on 8/26/15.
//

#import "AB_LoremTitleGenerator.h"
#import "LoremIpsum.h"

@implementation AB_LoremTitleGenerator

- (NSString*) textContent
{
    return [LoremIpsum title];
}

@end
