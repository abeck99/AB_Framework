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

#define MAP_STRING(valueName) + (NSValueTransformer*)valueName ## JSONTransformer { return [MTLValueTransformer transformerUsingForwardBlock:^(NSString* str, BOOL* success, NSError** error) { return str ? [NSString stringWithFormat:@"%@", str] : nil; } reverseBlock:^(NSString* str, BOOL* success, NSError** error) { return str; }]; }

#define MAP_LOCATION(valueName, latName, lngName) + (NSValueTransformer*)valueName ## JSONTransformer { return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary* latLng, BOOL* success, NSError** err) { NSString* lat = latLng[@latName]; NSString* lng = latLng[@lngName]; if (lat.length == 0 || lng.length == 0) { return nil; } return [[AB_ComparableLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]]; } reverseBlock:^id(CLLocation* location, BOOL* success, NSError** err) { if (!location) { return @{}; } return @{ @latName: [@(location.coordinate.latitude) toFloatString], @lngName: [@(location.coordinate.longitude) toFloatString], }; }]; }
