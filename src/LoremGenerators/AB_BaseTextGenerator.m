//
//  AB_BaseTextGenerator.m
//  PPA
//
//  Created by phoebe on 8/26/15.
//  Copyright (c) 2015 Prospect Park Alliance. All rights reserved.
//

#import "AB_BaseTextGenerator.h"
#import "Underscore.h"

@implementation AB_BaseTextGenerator

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setContent];
}

- (void) prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    [self setContent];
}

- (void) setContent
{
    [self setTextContent:[self textContent]];
}

- (NSString*) textContent
{
    return @"";
}

- (void) setTextContent:(NSString*)textContent
{
    Underscore.array(labels)
    .each(^(UILabel* label)
          {
              label.text = textContent;
          });
    
    Underscore.array(textViews)
    .each(^(UILabel* label)
          {
              label.text = textContent;
          });
}

@end
