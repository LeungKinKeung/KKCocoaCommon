//
//  KKUserNotificationCenter.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 通知Alert被点击了，详情：(NSDictionary <NSString *, id> *userInfo)
OBJC_EXTERN NSNotificationName const KKUserNotificationAlertClickedNotification;
/// 通知Alert被点击了
typedef void(^KKUserNotificationHandler)(NSDictionary <NSString *, id> *userInfo);

@interface KKUserNotificationCenter : NSObject

/// 本地通知中心
+ (instancetype)defaultCenter;

/// APP前台仍然显示通知，默认：YES
@property (nonatomic, assign, getter=isDisplayWhenAnyway) BOOL displayWhenAnyway;

/// 点了Alert后清理全部通知，默认：NO
@property (nonatomic, assign, getter=isRemoveAllWhenClicked) BOOL removeAllWhenClicked;

/// 通知是否可用（macOS 10.14以下一定可用）
@property (nonatomic, readonly) BOOL isAuthorized;

/// 请求授权
- (void)requestAuthorizationWithHandler:(void (^)(BOOL granted))handler;

/**
 *  如果要显示按钮，则就要info.plist里添加
 *  NSUserNotificationAlertStyle:alert
 *  可选样式:banner(默认)，alert或none
 */
/// 发出通知
/// @param identifier 标识符
/// @param title 标题
/// @param subtitle 副标题
/// @param body 详情
/// @param deliveryDate 定时发送
/// @param deliveryRepeatInterval 重复定时发送
/// @param userInfo 自定义信息
/// @param actionButtonTitle 确定按钮标题（在横幅右下）
/// @param cancelButtonTitle 其他按钮标题（在横幅右上，点击直接消失不会通知）
/// @param handler 点了通知Alert或Action Button回调
+ (void)deliverNotificationWithID:(NSString *)identifier
                            title:(NSString *)title
                         subtitle:(NSString *)subtitle
                             body:(NSString *)body
                     deliveryDate:(NSDate *)deliveryDate
           deliveryRepeatInterval:(NSDateComponents *)deliveryRepeatInterval
                         userInfo:(NSDictionary<NSString *,id> *)userInfo
                actionButtonTitle:(NSString *)actionButtonTitle
                cancelButtonTitle:(NSString *)cancelButtonTitle
                          handler:(KKUserNotificationHandler)handler;
/// 发出通知
+ (void)deliverNotificationWithTitle:(NSString *)title
                                body:(NSString *)body
                            userInfo:(NSDictionary<NSString *,id> *)userInfo
                   actionButtonTitle:(NSString *)actionButtonTitle
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                             handler:(KKUserNotificationHandler)handler;

/// 发出通知
+ (void)deliverNotificationWithTitle:(NSString *)title body:(NSString *)body;

/// 移除所有已传递（显示）的通知
+ (void)removeAllDeliveredNotifications;

/// 根据ID移除已传递（显示）的通知
+ (void)removeDeliveredNotificationsWithIdentifiers:(NSArray<NSString *> *)identifiers;

/// 根据ID移除队列中的通知
+ (void)removePendingNotificationRequestsWithIdentifiers:(NSArray <NSString *>*)identifiers;

@end
