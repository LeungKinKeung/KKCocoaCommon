//
//  NSView+KKAnimation.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSView+KKAnimation.h"

@interface KKCAAnimationDelegate : NSObject <CAAnimationDelegate>

@property (copy , nonatomic) KKAnimationCompletionBlock completionBlock;

+ (instancetype)delegateWithCompletionBlock:(KKAnimationCompletionBlock)completionBlock;

@end

@implementation KKCAAnimationDelegate

+ (instancetype)delegateWithCompletionBlock:(KKAnimationCompletionBlock)completionBlock
{
    KKCAAnimationDelegate *obj = [self new];
    obj.completionBlock         = completionBlock;
    return obj;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.completionBlock) {
        self.completionBlock(flag);
        self.completionBlock = nil;
    }
}

@end

@implementation CABasicAnimation (KKAnimation)

+ (instancetype)animationGroupWithDuration:(NSTimeInterval)duration fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity completionBlock:(KKAnimationCompletionBlock)completionBlock
{
    CABasicAnimation *opacity   = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue           = [NSNumber numberWithFloat:fromOpacity];
    opacity.toValue             = [NSNumber numberWithFloat:toOpacity];
    opacity.fillMode            = kCAFillModeForwards;
    opacity.duration            = duration;
    opacity.removedOnCompletion = NO;
    if (completionBlock) {
        opacity.delegate        = [KKCAAnimationDelegate delegateWithCompletionBlock:completionBlock];
    }
    return opacity;
}

@end

@implementation CAAnimationGroup (KKAnimation)

double CircularEaseIn(double p)
{
    return sqrt((2 - p) * p);
}

+ (NSArray *)calculateFrameFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint frameCount:(size_t)frameCount
{
    NSMutableArray *values  = [NSMutableArray arrayWithCapacity:frameCount];
    CGFloat t = 0.0;
    CGFloat dt = 1.0 / (frameCount - 1);
    for(size_t frame = 0; frame < frameCount; ++frame, t += dt) {
        CGFloat x = fromPoint.x + CircularEaseIn(t) * (toPoint.x - fromPoint.x);
        CGFloat y = fromPoint.y + CircularEaseIn(t) * (toPoint.y - fromPoint.y);
        [values addObject:[NSValue valueWithPoint:NSMakePoint(x, y)]];
    }
    return values;
}

+ (instancetype)animationGroupWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint completionBlock:(KKAnimationCompletionBlock)completionBlock
{
    CAAnimationGroup *group         = [CAAnimationGroup animation];
    CAKeyframeAnimation *position   = [CAKeyframeAnimation animation];
    position.keyPath                = @"position";
    position.values                 = [self calculateFrameFromPoint:fromPoint toPoint:toPoint frameCount:30];
    NSMutableArray *animations      = [NSMutableArray array];
    [animations addObject:position];
    group.animations                = animations;
    group.duration                  = duration;
    group.fillMode                  = kCAFillModeForwards;
    group.removedOnCompletion       = NO;
    if (completionBlock) {
        group.delegate              = [KKCAAnimationDelegate delegateWithCompletionBlock:completionBlock];
    }
    return group;
}

+ (instancetype)animationGroupWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity completionBlock:(KKAnimationCompletionBlock)completionBlock
{
    CAAnimationGroup *group     = [CAAnimationGroup animationGroupWithDuration:duration fromPoint:fromPoint toPoint:toPoint completionBlock:completionBlock];
    NSMutableArray *animations  = group.animations.mutableCopy;
    CABasicAnimation *opacity   = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue           = [NSNumber numberWithFloat:fromOpacity];
    opacity.toValue             = [NSNumber numberWithFloat:toOpacity];
    [animations addObject:opacity];
    group.animations            = animations;
    return group;
}

@end

@implementation NSView (KKAnimation)

- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint completionBlock:(KKAnimationCompletionBlock)completionBlock
{
    return [self addCAAnimationWithDuration:duration fromPoint:fromPoint toPoint:toPoint forKey:nil removedOnCompletion:NO completionBlock:completionBlock];
}

- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint forKey:(NSString *)key removedOnCompletion:(BOOL)removedOnCompletion completionBlock:(KKAnimationCompletionBlock)completionBlock
{
    CAAnimationGroup *animation     =
    [CAAnimationGroup animationGroupWithDuration:duration fromPoint:fromPoint toPoint:toPoint completionBlock:completionBlock];
    animation.removedOnCompletion   = removedOnCompletion;
    self.wantsLayer                 = YES;
    [self.layer addAnimation:animation forKey:key];
    
    return animation;
}

- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity completionBlock:(KKAnimationCompletionBlock)completionBlock
{
    return [self addCAAnimationWithDuration:duration fromPoint:fromPoint toPoint:toPoint fromOpacity:fromOpacity toOpacity:toOpacity forKey:nil removedOnCompletion:NO completionBlock:completionBlock];
}

- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)toPoint fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity forKey:(NSString *)key removedOnCompletion:(BOOL)removedOnCompletion completionBlock:(KKAnimationCompletionBlock)completionBlock
{
    CAAnimationGroup *animation     =
    [CAAnimationGroup animationGroupWithDuration:duration fromPoint:fromPoint toPoint:toPoint fromOpacity:fromOpacity toOpacity:toOpacity completionBlock:completionBlock];
    animation.removedOnCompletion   = removedOnCompletion;
    self.wantsLayer                 = YES;
    [self.layer addAnimation:animation forKey:key];
    
    return animation;
}

- (CAAnimation *)addCAAnimationWithDuration:(NSTimeInterval)duration fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity forKey:(NSString *)key completionBlock:(KKAnimationCompletionBlock)completionBlock
{
    CABasicAnimation *animation =
    [CABasicAnimation animationGroupWithDuration:duration fromOpacity:fromOpacity toOpacity:toOpacity completionBlock:completionBlock];
    
    self.wantsLayer = YES;
    [self.layer addAnimation:animation forKey:key];
    
    return animation;
}

- (CAAnimation *)addRotateAnimationWithDuration:(NSTimeInterval)duration startAngle:(CGFloat)startAngle  endAngle:(CGFloat)endAngle repeat:(BOOL)repeat forKey:(NSString *)key
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue         = @(startAngle);
    animation.toValue           = @(endAngle);
    animation.duration          = duration;
    animation.repeatCount       = repeat ? MAXFLOAT : 1;
    animation.removedOnCompletion = NO;
    self.wantsLayer             = YES;
    self.layer.position         = CGPointMake(CGRectGetMidX(self.frame) , CGRectGetMidY(self.frame));
    self.layer.anchorPoint      = CGPointMake(0.5, 0.5);
    [self.layer addAnimation:animation forKey:nil];
    return animation;
}

- (CAAnimation *)addLoopRotateAnimationForKey:(NSString *)key
{
    return [self addRotateAnimationWithDuration:1 startAngle:M_PI*2 endAngle:0 repeat:YES forKey:key];
}

- (void)removeAllCAAnimations
{
    [self.layer removeAllAnimations];
}

- (void)removeCAAnimationForKey:(NSString *)key
{
    [self.layer removeAnimationForKey:key];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations
                 completion:(void (^)(void))completion
{
    if (duration == 0) {
        if (animations) {
            animations();
        }
        if (completion) {
            completion();
        }
        return;
    }
    [NSAnimationContext beginGrouping];
    
    NSAnimationContext *ctx = [NSAnimationContext currentContext];
    ctx.completionHandler   = completion;
    ctx.duration            = duration;
    ctx.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // 启用隐式动画，就不用调用.animator了（不生效？？？）
    ctx.allowsImplicitAnimation = YES;
    
    if (animations) {
        animations();
    }
    [NSAnimationContext endGrouping];
}


@end
