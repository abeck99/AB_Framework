//
//  AB_NSString+Extensions.m
//  Eastern
//
//  Created by phoebe on 7/24/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_NSString+Extensions.h"

@implementation NSString(AB_Extensions)

- (NSNumber*) toNumberFromDollarCurrency
{
    return [[NSNumberFormatter dollarCurrencyFormatter]
            numberFromString:self];
}

- (NSNumber*) toNumberWithStyle:(NSNumberFormatterStyle)style
{
    return [[NSNumberFormatter
             formatterWithStyle:style]
            numberFromString:self];
}

- (NSNumber*) toNumber
{
    return [self toNumberWithStyle:NSNumberFormatterDecimalStyle];
}

@end

@implementation NSNumber(AB_Extensions)

- (NSString*) toFloatString
{
    return [self toStringWithStyle:NSNumberFormatterDecimalStyle];
}

- (NSString*) toStringWithStyle:(NSNumberFormatterStyle)style
{
    return [[NSNumberFormatter
             formatterWithStyle:style]
            stringFromNumber:self];
}

- (NSString*) toCurrencyStringWithLocale:(NSLocale*)locale
{
    return [[NSNumberFormatter
             currencyFormatterWithLocale:locale]
            stringFromNumber:self];
}

- (NSString*) toDollarCurrencyString
{
    return [[NSNumberFormatter dollarCurrencyFormatter]
            stringFromNumber:self];
}

@end


@implementation NSNumberFormatter(AB_Extensions)

+ (NSNumberFormatter*) formatterWithStyle:(NSNumberFormatterStyle)style
                                   locale:(NSLocale*)locale
{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = style;
    formatter.locale = locale;
    return formatter;
}

+ (NSNumberFormatter*) formatterWithStyle:(NSNumberFormatterStyle)style;
{
    return [NSNumberFormatter
            formatterWithStyle:style
            locale:[NSLocale currentLocale]];
}

+ (NSNumberFormatter*) currencyFormatterWithLocale:(NSLocale*)locale
{
    return [NSNumberFormatter
            formatterWithStyle:NSNumberFormatterCurrencyStyle
            locale:locale];
}

+ (NSNumberFormatter*) dollarCurrencyFormatter
{
    return [NSNumberFormatter
            formatterWithStyle:NSNumberFormatterCurrencyStyle
            locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
}

@end
