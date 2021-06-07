//
//  NCNotificationRequest.h
//  libprofile
//
//  Created by Aspen on 6/7/21.
//
#import <Foundation/Foundation.h>
#import <UserNotifications/UNNotification.h>


@interface NCNotificationRequest: NSObject
-(NSDictionary*)supplementaryActions;
@property (nonatomic,copy,readonly) NSString* sectionIdentifier;
@property (nonatomic,copy,readonly) NSString* threadIdentifier;
@property (nonatomic,strong) UNNotification* userNotification;
@end
