//
//  AB_LoremImageGenerator.m
//  AB
//
//  Created by phoebe on 8/26/15.
//

#import "AB_LoremImageGenerator.h"
#import "LoremIpsum.h"
#import "Underscore.h"
#import "ReactiveCocoa.h"

@implementation AB_LoremImageGenerator

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
    Underscore.array(imageViews)
    .each(^(UIImageView* imageView)
          {
              [self setPlaceholderImage:imageView];
          });
}

- (void) setPlaceholderImage:(UIImageView*)imageView
{
    @weakify(imageView)
    [LoremIpsum asyncPlaceholderImageFromService:LIPlaceholderImageServiceLoremPixel
                                        withSize:imageView.frame.size
                                      completion:^(UIImage *image)
    {
        @strongify(imageView)
        imageView.image = image;
    }];
}

@end
