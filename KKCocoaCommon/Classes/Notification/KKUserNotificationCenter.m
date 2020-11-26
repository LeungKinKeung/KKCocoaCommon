//
//  KKUserNotificationCenter.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKUserNotificationCenter.h"
#import <UserNotifications/UserNotifications.h>

NSNotificationName const KKUserNotificationAlertClickedNotification = @"KKUserNotificationAlertClickedNotification";

@implementation KKUserNotification

@end

@interface KKUserNotificationCenter ()<NSUserNotificationCenterDelegate,UNUserNotificationCenterDelegate>

@property (nonatomic, assign) BOOL isAuthorized;
@property (nonatomic, strong) NSMutableDictionary *handlerMap;

@end

@implementation KKUserNotificationCenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.displayWhenAnyway      = YES;
        self.removeAllWhenClicked   = NO;
        self.handlerMap             = [NSMutableDictionary dictionary];
        
        if (@available(macOS 10.14, *))
        {
            UNUserNotificationCenter *center =
            [UNUserNotificationCenter currentNotificationCenter];
            
            center.delegate     = self;
        }
        else
        {
            NSUserNotificationCenter *center =
            [NSUserNotificationCenter defaultUserNotificationCenter];
            
            center.delegate     = self;
            self.isAuthorized   = YES;
        }
    }
    return self;
}

- (void)requestAuthorizationWithHandler:(void (^)(BOOL granted))handler
{
    if (@available(macOS 10.14, *))
    {
        UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];
        
        UNAuthorizationOptions opts =
        UNAuthorizationOptionBadge |
        UNAuthorizationOptionSound |
        UNAuthorizationOptionAlert;
        
        [center requestAuthorizationWithOptions:opts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            self.isAuthorized = granted;
            
            if (error)
            {
                NSLog(@"%@ error:%@",NSStringFromClass([self class]),error.localizedDescription);
            }
            if (handler)
            {
                handler(granted);
            }
        }];
    }
    else if (handler)
    {
        handler(YES);
    }
}

- (BOOL)isAuthorized
{
    return _isAuthorized;
}

#pragma mark - macOS => 10.14
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
API_AVAILABLE(macos(10.14))
{
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler
API_AVAILABLE(macos(10.14))
{
//    NSLog(@"actionIdentifier:%@",response.actionIdentifier);
    if ([UNNotificationDismissActionIdentifier isEqualToString:response.actionIdentifier])
    {
        // 点了取消就忽略
        completionHandler();
        return;
    }
    [self alertClickedWithIdentifier:response.notification.request.identifier
                            userInfo:response.notification.request.content.userInfo];
    
    completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification
API_AVAILABLE(macos(10.14))
{
    NSLog(@"%s open settings",__func__);
}

#pragma mark - 本地通知(macOS < 10.14)
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    // 1.通知时间已到或准备通知了
    
}

#pragma mark 当APP处于最前面时是否显示通知
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    // 2.当APP处于最前面时，将不显示通知，默认返回NO，如果一定要通知则返回YES
    return self.isDisplayWhenAnyway;
}

#pragma mark 点了通知
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    /*
     3.当用户单击通知中心中的通知时，向Delegate发送。
     这将是响应用户与特定通知交互采取行动的好时机。
     Important：如果想采取行动时，你的应用程序是作为一个结果，
     用户点击通知的推出，一定要实现你的NSApplicationDelegate
     applicationDidFinishLaunching:方法。通知参数，
     方法具有用户信息字典，词典，
     有NSApplicationLaunchUserNotificationKey关键。
     该键的值是造成应用程序启动NSUserNotification。
     的NSUserNotification送到NSApplication代表
     因为消息将在你的应用程序有一个机会为
     NSUserNotificationCenter设置一个Delegate。
     */
    
    // 点了other按钮不会走此方法
    NSUserNotificationActivationType type =
    notification.activationType;
    
    if (type != NSUserNotificationActivationTypeContentsClicked &&
        type != NSUserNotificationActivationTypeActionButtonClicked)
    {
        // 只有点了横幅本身和Action按钮才通知
        return;
    }
    
    [self alertClickedWithIdentifier:notification.identifier
                            userInfo:notification.userInfo];
    
    if (self.isRemoveAllWhenClicked)
    {
        [center removeAllDeliveredNotifications];
    }
}

#pragma mark 点了横幅本身或Action按钮
- (void)alertClickedWithIdentifier:(NSString *)identifier userInfo:(NSDictionary *)userInfo
{
    KKUserNotificationHandler handler = [self.handlerMap valueForKey:identifier];
    
    if (handler)
    {
        [self.handlerMap setValue:nil forKey:identifier];
        handler(userInfo);
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KKUserNotificationAlertClickedNotification object:userInfo];
    }
}

#pragma mark - 通知
+ (void)deliverNotificationWithTitle:(NSString *)title
                                body:(NSString *)body
{
    [self deliverNotificationWithTitle:title body:body userInfo:nil actionButtonTitle:nil cancelButtonTitle:nil handler:nil];
}

+ (void)deliverNotificationWithTitle:(NSString *)title
                                body:(NSString *)body
                            userInfo:(NSDictionary<NSString *,id> *)userInfo
                   actionButtonTitle:(NSString *)actionButtonTitle
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                             handler:(KKUserNotificationHandler)handler
{
    KKUserNotification *noti    = [KKUserNotification new];
    noti.title                  = title;
    noti.body                   = body;
    noti.userInfo               = userInfo;
    noti.actionButtonTitle      = actionButtonTitle;
    noti.cancelButtonTitle      = cancelButtonTitle;
    
    [self deliverNotification:noti handler:handler];
}

+ (void)deliverNotification:(KKUserNotification *)notification handler:(KKUserNotificationHandler)handler
{
    if (@available(macOS 10.14, *))
    {
        if (notification.identifier == nil)
        {
            notification.identifier = [[NSUUID UUID] UUIDString];
        }
        [[KKUserNotificationCenter defaultCenter] requestAuthorizationWithHandler:^(BOOL granted) {
            if (granted == NO) {
                return;
            }
            [self getNotificationCategoriesIdentifierWithActionButtonTitle:notification.actionButtonTitle
                                                         cancelButtonTitle:notification.cancelButtonTitle
                                                         completionHandler:^(NSString *categoriesIdentifier) {

                UNUserNotificationCenter *center =
                [UNUserNotificationCenter currentNotificationCenter];
                
                UNMutableNotificationContent *content =
                UNMutableNotificationContent.new;
                
                content.title               = notification.title;
                content.subtitle            = notification.subtitle;
                content.body                = notification.body;
                content.userInfo            = notification.userInfo;
                content.categoryIdentifier  = categoriesIdentifier;
                
                UNCalendarNotificationTrigger *trigger = nil;
                
                if (notification.deliveryRepeatInterval)
                {
                    trigger =
                    [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:notification.deliveryRepeatInterval repeats:YES];
                }
                else if (notification.deliveryDate)
                {
                    NSCalendar *calendar =
                    [NSCalendar currentCalendar];
                    
                    NSCalendarUnit unit =
                    NSCalendarUnitEra |
                    NSCalendarUnitYear |
                    NSCalendarUnitMonth |
                    NSCalendarUnitDay |
                    NSCalendarUnitHour |
                    NSCalendarUnitMinute |
                    NSCalendarUnitSecond;
                    
                    NSDateComponents *comps =
                    [calendar components:unit
                                fromDate:notification.deliveryDate];
                    
                    trigger =
                    [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:comps repeats:NO];
                }
                
                UNNotificationRequest *requst =
                [UNNotificationRequest requestWithIdentifier:notification.identifier
                                                     content:content
                                                     trigger:trigger];
                
                [center addNotificationRequest:requst withCompletionHandler:^(NSError * _Nullable error) {
                    
                    if (error)
                    {
                        NSLog(@"%@ deliver notification error:%@",NSStringFromClass([self class]),error.localizedDescription);
                    }
                    else if (handler)
                    {
                        [[KKUserNotificationCenter defaultCenter].handlerMap setValue:handler forKey:notification.identifier];
                    }
                }];
            }];
        }];
    }
    else
    {
        NSUserNotification *noti =
        [[NSUserNotification alloc] init];
        
        noti.identifier         = notification.identifier;
        noti.title              = notification.title;
        noti.subtitle           = notification.subtitle;
        noti.informativeText    = notification.body;
        noti.userInfo           = notification.userInfo;
        noti.hasActionButton    = notification.actionButtonTitle ? YES : NO;
        noti.actionButtonTitle  = notification.actionButtonTitle;
        noti.otherButtonTitle   = notification.cancelButtonTitle;
        
        if (notification.deliveryDate)
        {
            noti.deliveryDate   = notification.deliveryDate;
        }
        else if (notification.deliveryRepeatInterval)
        {
            noti.deliveryRepeatInterval = notification.deliveryRepeatInterval;
        }
        NSUserNotificationCenter *center =
        [NSUserNotificationCenter defaultUserNotificationCenter];
        
        [center deliverNotification:noti];
        
        if (handler)
        {
            [[KKUserNotificationCenter defaultCenter].handlerMap setValue:handler
                                                                   forKey:notification.identifier];
        }
    }
}

#pragma mark 获取按键标识符
+ (void)getNotificationCategoriesIdentifierWithActionButtonTitle:(NSString *)actionButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle completionHandler:(void(^)(NSString *categoriesIdentifier))completionHandler API_AVAILABLE(macos(10.14))
{
    if (actionButtonTitle == nil && cancelButtonTitle == nil)
    {
        completionHandler(nil);
        return;
    }
    
    NSString *categoriesIdentifier =
    [NSString stringWithFormat:@"CategoriesIdentifier(%@)(%@)",actionButtonTitle,cancelButtonTitle];
    
    UNUserNotificationCenter *center =
    [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
        
        NSArray *categorieList = categories.allObjects;
        
        // 查找
        for (UNNotificationCategory *category in categorieList)
        {
            if ([category.identifier isEqualToString:categoriesIdentifier])
            {
                completionHandler(category.identifier);
            }
        }
        // 创建
        NSMutableArray *actions = NSMutableArray.new;
        
        if (actionButtonTitle)
        {
            UNNotificationAction *action =
            [UNNotificationAction actionWithIdentifier:UNNotificationDefaultActionIdentifier title:actionButtonTitle options:UNNotificationActionOptionForeground | UNNotificationActionOptionAuthenticationRequired];
            [actions addObject:action];
        }
        if (cancelButtonTitle)
        {
            UNNotificationAction *action =
            [UNNotificationAction actionWithIdentifier:UNNotificationDismissActionIdentifier title:cancelButtonTitle options:UNNotificationActionOptionDestructive];
            [actions addObject:action];
        }
        
        NSMutableSet *set = NSMutableSet.new;
        
        [set addObject:[UNNotificationCategory categoryWithIdentifier:categoriesIdentifier actions:actions intentIdentifiers:@[] options:UNNotificationCategoryOptionNone]];
        
        [center setNotificationCategories:set];
        
        completionHandler(categoriesIdentifier);
    }];
}

#pragma mark 移除通知
+ (void)removeAllDeliveredNotifications
{
    if (@available(macOS 10.14, *))
    {
        UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];
        [center removeDeliveredNotificationsWithIdentifiers:@[]];
        [center removePendingNotificationRequestsWithIdentifiers:@[]];
        [center removeAllDeliveredNotifications];
    }
    else
    {
        NSUserNotificationCenter *center =
        [NSUserNotificationCenter defaultUserNotificationCenter];
        
        [center removeAllDeliveredNotifications];
    }
}

+ (void)removeDeliveredNotificationsWithIdentifiers:(NSArray<NSString *> *)identifiers
{
    if (identifiers == nil || identifiers.count == 0) {
        return;
    }
    if (@available(macOS 10.14, *))
    {
        UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];
        
        [center removeDeliveredNotificationsWithIdentifiers:identifiers];
    }
    else
    {
        NSUserNotificationCenter *center =
        [NSUserNotificationCenter defaultUserNotificationCenter];
        
        NSArray *list = [center deliveredNotifications].copy;
        
        for (NSUserNotification *noti in list)
        {
            if ([identifiers containsObject:noti.identifier])
            {
                [center removeDeliveredNotification:noti];
            }
        }
    }
}

+ (void)removePendingNotificationRequestsWithIdentifiers:(NSArray <NSString *>*)identifiers
{
    if (identifiers == nil || identifiers.count == 0) {
        return;
    }
    if (@available(macOS 10.14, *))
    {
        UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];
        
        [center removePendingNotificationRequestsWithIdentifiers:identifiers];
    }
    else
    {
        NSUserNotificationCenter *center =
        [NSUserNotificationCenter defaultUserNotificationCenter];
        
        NSArray *list = [center scheduledNotifications].copy;
        
        for (NSUserNotification *noti in list)
        {
            if ([identifiers containsObject:noti.identifier])
            {
                [center removeScheduledNotification:noti];
            }
        }
    }
}

#pragma mark 单例
+ (instancetype)defaultCenter
{
    static id obj;
    if (!obj) {
        static dispatch_once_t oncToken;
        dispatch_once(&oncToken, ^{
            obj = [[super allocWithZone:NULL] init];
        });
    }
    return obj;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self defaultCenter];
}
- (id)copy {
    return [[self class] defaultCenter];
}
- (id)mutableCopy
{
    return [[self class] defaultCenter];
}

@end
