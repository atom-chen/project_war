#import "NotifyCenter.h"
#import <UIKit/UIApplication.h>
#import <UIKit/UILocalNotification.h>
#import <UIKit/UIUserNotificationSettings.h>

@implementation NotifyCenter

+(void)regist {
    // ios8需要给用户授权
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
}

+(void)add:(NSNumber*)type key:(NSNumber*)key msg:(NSString*)msg delay:(NSNumber*)delay {
    if (nil == type || nil == key || nil == msg || [msg isEqualToString:@""] || nil == delay) {
        return;
    }
    UILocalNotification* notification = [[[UILocalNotification alloc] init] autorelease];
    // 通知信息
    notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[type stringValue], @"type", [key stringValue], @"key", nil];
    // 推送内容
    notification.alertBody = msg;
    // 推送时区(本地时区)
    notification.timeZone = [NSTimeZone localTimeZone];
    // 推送时间(默认从当前时间开始算)
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[delay doubleValue]];
    // 重复间隔(默认只推送一次)
    notification.repeatInterval = 0;
    // 获取当前时间(年/月/日/时/分/秒)
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps= [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:[NSDate date]];
    // 当天已走秒数/当天剩余秒数
    NSInteger dayPassedSeconds = [comps hour]*3600 + [comps minute]*60 + [comps second];
    NSInteger dayRemainSeconds = 24*3600 - dayPassedSeconds;
    switch ([type intValue]) {
        case 1: {       // 每天定时推送
            NSTimeInterval interval = [delay doubleValue] - dayPassedSeconds;
            if (interval <= 0) {
                interval = dayRemainSeconds + [delay doubleValue];
            }
            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
            notification.repeatInterval = NSDayCalendarUnit;
            break;
        }
		case 2: {		// 从当前时间延迟推送(已默认处理)
		}
        default:
            break;
    }
    // 推送声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 显示在icon上的红色圈中的数字
    notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    // 添加推送到UIApplication
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+(void)removeType:(NSNumber*)type {
    if (nil == type) {
        return;
    }
    NSArray* notifyArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if (nil == notifyArray || 0 == [notifyArray count]) {
        return;
    }
    for (UILocalNotification* notify in notifyArray) {
        if (nil == notify.userInfo) {
            continue;
        }
        NSString* notifyType = [notify.userInfo objectForKey:@"type"];
        if (notifyType && [notifyType isEqualToString:[type stringValue]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
        }
    }
}

+(void)removeKey:(NSNumber*)key {
    if (nil == key) {
        return;
    }
    NSArray* notifyArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if (nil == notifyArray || 0 == [notifyArray count]) {
        return;
    }
    for (UILocalNotification* notify in notifyArray) {
        if (nil == notify.userInfo) {
            continue;
        }
        NSString* notifyKey = [notify.userInfo objectForKey:@"key"];
        if (notifyKey && [notifyKey isEqualToString:[key stringValue]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
        }
    }
}

+(void)clear {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

+(void)reset {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

@end
