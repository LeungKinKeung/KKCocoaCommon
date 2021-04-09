//
//  NSView+KKAnimation.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

/// 动画完成
typedef void (^KKAnimationCompletionBlock)(BOOL animationFinished);

@interface CABasicAnimation (KKAnimation)

/// 透明度渐变动画
/// @param duration 动画时长
/// @param fromOpacity 0 ~ 1.0
/// @param toOpacity 0 ~ 1.0
/// @param completionBlock 动画完成
+ (instancetype)animationGroupWithDuration:(NSTimeInterval)duration fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity completionBlock:(KKAnimationCompletionBlock)completionBlock;

@end

@interface CAAnimationGroup (KKAnimation)

/// 位置移动动画（阻尼效果）
/// @param duration 动画时长
/// @param fromPoint 起点
/// @param toPoint 终点
/// @param completionBlock 动画完成
+ (instancetype)animationGroupWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint completionBlock:(KKAnimationCompletionBlock)completionBlock;

/// 位置移动+透明度渐变动画（阻尼效果）
/// @param duration 动画时长
/// @param fromPoint 起点
/// @param toPoint 终点
/// @param fromOpacity 0 ~ 1.0
/// @param toOpacity 0 ~ 1.0
/// @param completionBlock 动画完成
+ (instancetype)animationGroupWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity completionBlock:(KKAnimationCompletionBlock)completionBlock;

/// 缩放+透明度渐变动画（弹簧效果）
/// @param duration 动画时长
/// @param fromScale 起始缩放值
/// @param toScale 最终缩放值
/// @param completionBlock 动画完成
+ (instancetype)animationGroupWithDuration:(NSTimeInterval)duration fromScale:(CGFloat)fromScale toScale:(CGFloat)toScale completionBlock:(KKAnimationCompletionBlock)completionBlock;

/// 缩放+透明度渐变动画（弹簧效果）
/// @param duration 动画时长
/// @param fromScale 起始缩放值
/// @param toScale 最终缩放值
/// @param fromOpacity 起始透明度（0 ~ 1.0）
/// @param toOpacity 最终透明度（0 ~ 1.0）
/// @param completionBlock 动画完成
+ (instancetype)animationGroupWithDuration:(NSTimeInterval)duration fromScale:(CGFloat)fromScale toScale:(CGFloat)toScale fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity completionBlock:(KKAnimationCompletionBlock)completionBlock;

@end

@interface NSView (KKAnimation)

/// 添加并执行位置移动动画
- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint completionBlock:(KKAnimationCompletionBlock)completionBlock;

- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint forKey:(NSString *)key removedOnCompletion:(BOOL)removedOnCompletion completionBlock:(KKAnimationCompletionBlock)completionBlock;

/// 添加并执行位置移动+透明度渐变动画
- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity completionBlock:(KKAnimationCompletionBlock)completionBlock;

- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity forKey:(NSString *)key removedOnCompletion:(BOOL)removedOnCompletion completionBlock:(KKAnimationCompletionBlock)completionBlock;

/// 添加渐变动画
- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity forKey:(NSString *)key completionBlock:(KKAnimationCompletionBlock)completionBlock;

/// 添加旋转动画（viewDidAppear、updateTrackingAreas后才能使用，否则会以左下角为锚点旋转）
/// @param duration 时长
/// @param startAngle 顺时针：M_PI*2，逆时针：0
/// @param endAngle 顺时针：0，逆时针：M_PI*2
/// @param repeat 是否重复
/// @param key 键
- (CAAnimation *)addRotateAnimationWithDuration:(NSTimeInterval)duration startAngle:(CGFloat)startAngle  endAngle:(CGFloat)endAngle repeat:(BOOL)repeat forKey:(NSString *)key;

/// 添加循环旋转动画（viewDidAppear、updateTrackingAreas后才能使用，否则会以左下角为锚点旋转）
- (CAAnimation *)addLoopRotateAnimationForKey:(NSString *)key;

/// 缩放动画（弹簧效果，viewDidAppear、updateTrackingAreas后才能使用，否则会以左下角为锚点旋转）
- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromScale:(CGFloat)fromScale toScale:(CGFloat)toScale forKey:(NSString *)key removedOnCompletion:(BOOL)removedOnCompletion completionBlock:(KKAnimationCompletionBlock)completionBlock;

/// 缩放动画（弹簧效果，viewDidAppear、updateTrackingAreas后才能使用，否则会以左下角为锚点旋转）
- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration  fromScale:(CGFloat)fromScale toScale:(CGFloat)toScale fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity forKey:(NSString *)key removedOnCompletion:(BOOL)removedOnCompletion completionBlock:(KKAnimationCompletionBlock)completionBlock;

/// 移除所有动画
- (void)removeAllCAAnimations;

/// 移除指定动画
- (void)removeCAAnimationForKey:(NSString *)key;

/// NSAnimationContext动画
/// @param duration 时长
/// @param animations 动画代码块
/// @param completion 完成
+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations
                 completion:(void (^)(void))completion;

@end

