//
//  AB_BaseModel.h
//
//  Copyright (c) 2015 Andrew Beck. All rights reserved.
//

#import "Mantle.h"
#import "AB_NSDate+ISOExtensions.h"
#import "AB_NSString+Extensions.h"

@interface AB_BaseModel : MTLModel<MTLJSONSerializing>

+ (instancetype) fromDictionary:(NSDictionary*)modelDictionary error:(NSError**)err;
+ (NSArray*) fromDictionaries:(NSArray*)dictionaries error:(NSError**)err;

- (NSDictionary*) toDictionaryWithError:(NSError**)err;

@end

#define MAP_SUBOBJECT(valueName, subobjectClass) + (NSValueTransformer*)valueName ##JSONTransformer { return [MTLJSONAdapter dictionaryTransformerWithModelClass:[subobjectClass class]]; }

#define MAP_SUBOBJECT_ARRAY(valueName, subobjectClass) + (NSValueTransformer*)valueName ## JSONTransformer { return [MTLJSONAdapter arrayTransformerWithModelClass:[subobjectClass class]]; }


#define MAP_DATE(valueName) + (NSValueTransformer*)valueName ## JSONTransformer { NSDateFormatter* dateFormatter = [NSDate iso8601Formatter]; return [MTLValueTransformer transformerUsingForwardBlock:^(NSString* dateStr, BOOL* success, NSError** error) { return [dateFormatter dateFromString:dateStr]; } reverseBlock:^(NSDate* date, BOOL* success, NSError** error) { return [dateFormatter stringFromDate:date]; }]; }


#define MAP_NUMBER(valueName, style) + (NSValueTransformer*)valueName ## JSONTransformer { return [MTLValueTransformer transformerUsingForwardBlock:^(NSString* numberStr, BOOL* success, NSError** error) { return [numberStr isKindOfClass:[NSString class]] ? [numberStr toNumberWithStyle:style] : numberStr; } reverseBlock:^(NSNumber* number, BOOL* success, NSError** error) { return [number toStringWithStyle:style]; }]; }


#define MAP_DECIMAL(valueName) MAP_NUMBER(valueName, NSNumberFormatterDecimalStyle)

#define MAP_STRING(valueName) + (NSValueTransformer*)valueName ## JSONTransformer { return [MTLValueTransformer transformerUsingForwardBlock:^(NSString* str, BOOL* success, NSError** error) { return str; } reverseBlock:^(NSString* str, BOOL* success, NSError** error) { return str; }]; }

