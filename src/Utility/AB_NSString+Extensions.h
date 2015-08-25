//
//  AB_NSString+Extensions.h
//  Eastern
//
//  Created by phoebe on 7/24/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(AB_Extensions)

- (NSNumber*) toNumberFromDollarCurrency;
- (NSNumber*) toNumberWithStyle:(NSNumberFormatterStyle)style;
- (NSNumber*) toNumber;

@end

@interface NSNumber(AB_Extensions)

- (NSString*) toFloatString;
- (NSString*) toStringWithStyle:(NSNumberFormatterStyle)style;
- (NSString*) toCurrencyStringWithLocale:(NSLocale*) locale;
- (NSString*) toDollarCurrencyString;

@end


@interface NSNumberFormatter(AB_Extensions)

+ (NSNumberFormatter*) formatterWithStyle:(NSNumberFormatterStyle)style
                                   locale:(NSLocale*)locale;
+ (NSNumberFormatter*) formatterWithStyle:(NSNumberFormatterStyle)style;
+ (NSNumberFormatter*) currencyFormatterWithLocale:(NSLocale*)locale;
+ (NSNumberFormatter*) dollarCurrencyFormatter;

@end