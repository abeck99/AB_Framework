//
//  AB_LoremGenerator.m
//  PPA
//
//  Created by phoebe on 8/26/15.
//  Copyright (c) 2015 Prospect Park Alliance. All rights reserved.
//

#import "AB_LoremWordGenerator.h"
#import "LoremIpsum.h"

@implementation AB_LoremWordGenerator

- (NSString*) textContent
{
    return [LoremIpsum wordsWithNumber:self.numWords];
}

@end
