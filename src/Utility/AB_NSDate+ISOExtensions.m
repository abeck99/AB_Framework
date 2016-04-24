//
//  AB_NSDate+ISOExtensions.m
//  Eastern
//
//  Created by phoebe on 7/12/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_NSDate+ISOExtensions.h"

@implementation NSDate(AB_ISOExtensions)

+ (NSDateFormatter*) iso8601Formatter
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:ISO8601Format];
    dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    return dateFormatter;
}

+ (NSDate*) dateFromISO8601String:(NSString*)iso8601String
{
    NSDateFormatter* formatter = [self iso8601Formatter];
    return [formatter dateFromString:iso8601String];
}

- (NSString*) toISO8601String
{
    NSDateFormatter* formatter = [[self class] iso8601Formatter];
    return [formatter stringFromDate:self];
}

- (NSString*) toAmericanReadableString
{
    NSLocale* usLocale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    NSString* dateFormat = [NSDateFormatter
                            dateFormatFromTemplate:@"EEEEdMMMMha"
                            options:0
                            locale:usLocale];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    dateFormatter.locale = usLocale;
    dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    
    return [[[dateFormatter stringFromDate:self] stringByReplacingOccurrencesOfString:@"AM" withString:@"am"] stringByReplacingOccurrencesOfString:@"PM" withString:@"pm"];
}

@end
