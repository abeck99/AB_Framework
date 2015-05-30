//
//  AB_Notification.h
//  Homelister
//
//  Created by phoebe on 5/30/15.
//  Copyright (c) 2015 Homelister. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NotificationEventBlock)(id object, NSDictionary* notificationInfo);

// Note: This object allows you to use blocks for notification center events
//      It's very easy to create a circular reference when doing this, so either use a weak self reference
//      or explictly set this object to nil
@interface AB_Events : NSObject

@property(strong) NotificationEventBlock event;

+ (void) postEvent:(NSString*)notificationName info:(NSDictionary*)notificationInfo;
+ (void) postEvent:(NSString*)notificationName;
+ (AB_Events*) eventListenerWithName:(NSString*)notificationName;
+ (AB_Events*) eventListenerWithName:(NSString*)notificationName object:(id)object;

@end

@interface NSObject(AB_NotificationExtension)

- (void) postEvent:(NSString*)notificationName info:(NSDictionary*)notificationInfo;
- (void) postEvent:(NSString*)notificationName;

@end
