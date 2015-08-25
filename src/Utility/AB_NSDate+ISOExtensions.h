//
//  AB_NSDate+ISOExtensions.h
//  Eastern
//
//  Created by phoebe on 7/12/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ISO8601Format @"yyyy-MM-dd'T'HH:mm:ssZZZZ"

@interface NSDate(AB_ISOExtensions)

+ (NSDateFormatter*) iso8601Formatter;
+ (NSDate*) dateFromISO8601String:(NSString*)iso8601String;
- (NSString*) toISO8601String;
- (NSString*) toAmericanReadableString;

@end
