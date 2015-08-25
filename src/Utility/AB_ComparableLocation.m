//
//  AB_ComparableLocation.m
//  Eastern
//
//  Created by phoebe on 8/1/15.
//  Copyright (c) 2015 Eastern Taxi Company. All rights reserved.
//

#import "AB_ComparableLocation.h"

@implementation AB_ComparableLocation

- (BOOL) isEqual:(id)object
{
    if (!object || ![object isKindOfClass:[CLLocation class]])
    {
        return NO;
    }
    
    CLLocation* location = (CLLocation*) object;
    CLLocationDistance thresholdInMeters = 1.0;
    
    return [self distanceFromLocation:location] < thresholdInMeters;
}

@end
