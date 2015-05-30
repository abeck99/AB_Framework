//
//  AB_Notification.m
//  Homelister
//
//  Created by phoebe on 5/30/15.
//  Copyright (c) 2015 Homelister. All rights reserved.
//

#import "AB_Events.h"

@interface AB_Events()
{
    NSString* _notificationName;
    __unsafe_unretained id _object;
}

@end

@implementation AB_Events

@synthesize event;

+ (void) postEvent:(NSString*)notificationName info:(NSDictionary*)notificationInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:self
                                                      userInfo:notificationInfo];
}

+ (void) postEvent:(NSString*)notificationName
{
    
}


+ (AB_Events*) eventListenerWithName:(NSString*)notificationName
{
    return [[AB_Events alloc] initWithNotificationName:notificationName object:nil];
}

+ (AB_Events*) eventListenerWithName:(NSString*)notificationName object:(id)object
{
    return [[AB_Events alloc] initWithNotificationName:notificationName object:object];
}

- (instancetype) initWithNotificationName:(NSString*)notificationName object:(id)object
{
    if ( self == [super init])
    {
        _notificationName = notificationName;
        _object = object;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doTheNotification:)
                                                     name:notificationName
                                                   object:object];
        
        
    }
    
    return self;
}

- (void) doTheNotification:(NSNotification*)notif
{
    if (self.event)
    {
        self.event(notif.object, notif.userInfo);
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_notificationName object:_object];
}

@end

@implementation NSObject(AB_NotificationExtension)

- (void) postEvent:(NSString*)notificationName info:(NSDictionary*)notificationInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:self
                                                      userInfo:notificationInfo];
}

- (void) postEvent:(NSString*)notificationName
{
    [self postEvent:notificationName info:nil];
}

@end
