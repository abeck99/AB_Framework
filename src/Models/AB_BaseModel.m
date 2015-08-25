//
//  AB_BaseModel.m
//
//  Copyright (c) 2015 Andrew Beck. All rights reserved.
//

#import "AB_BaseModel.h"
#import "AB_NSDate+ISOExtensions.h"

@implementation AB_BaseModel

+ (instancetype) fromDictionary:(NSDictionary*)modelDictionary error:(NSError**)err
{
    return [MTLJSONAdapter modelOfClass:[self class]
                     fromJSONDictionary:modelDictionary
                                  error:err];
}

+ (NSArray*) fromDictionaries:(NSArray*)dictionaries error:(NSError**)err
{
    return [MTLJSONAdapter modelsOfClass:[self class]
                           fromJSONArray:dictionaries
                                   error:err];
}

- (NSDictionary*) toDictionaryWithError:(NSError**)err
{
    return [MTLJSONAdapter JSONDictionaryFromModel:self
                                             error:err];
}

+ (NSDateFormatter*) dateFormatter
{
    return [NSDate iso8601Formatter];
}

+ (NSDictionary*) JSONKeyPathsByPropertyKey
{
    return nil;
}

@end
