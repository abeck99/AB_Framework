//
//  AB_LoremTitleGenerator.m
//  PPA
//
//  Created by phoebe on 8/26/15.
//  Copyright (c) 2015 Prospect Park Alliance. All rights reserved.
//

#import "AB_LoremTitleGenerator.h"
#import "LoremIpsum.h"

@implementation AB_LoremTitleGenerator

- (NSString*) textContent
{
    return [LoremIpsum title];
}

@end
