//
//  NSBezierPath+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSBezierPath+KK.h"

@implementation NSBezierPath (KK)

+ (NSBezierPath *)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
    return [self bezierPathWithRoundedRect:rect xRadius:cornerRadius yRadius:cornerRadius];
}

+ (NSBezierPath *)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(KKRectCorner)corners cornerRadii:(CGSize)cornerRadii
{
    NSBezierPath *path  = [NSBezierPath bezierPath];
    CGFloat maxX        = rect.origin.x + rect.size.width;
    CGFloat minX        = rect.origin.x;
    CGFloat maxY        = rect.size.height + rect.origin.y;
    CGFloat minY        = rect.origin.y;
    
    CGFloat offsetX     = cornerRadii.width * 0.45;
    CGFloat offsetY     = cornerRadii.height * 0.45;
    
    BOOL topLeft        = corners & KKRectCornerTopLeft;
    BOOL topRight       = corners & KKRectCornerTopRight;
    BOOL bottomRight    = corners & KKRectCornerBottomRight;
    BOOL bottomLeft     = corners & KKRectCornerBottomLeft;

    if (topLeft) {
        [path moveToPoint:CGPointMake(minX, maxY - cornerRadii.height)];
        [path curveToPoint:CGPointMake(minX + cornerRadii.width, maxY) controlPoint1:CGPointMake(minX, maxY - offsetY) controlPoint2:CGPointMake(minX + offsetX, maxY)];
    } else {
        [path moveToPoint:CGPointMake(minX, maxY)];
    }

    if (topRight) {
        [path lineToPoint:CGPointMake(maxX - cornerRadii.width, maxY)];
        [path curveToPoint:CGPointMake(maxX, maxY - cornerRadii.height) controlPoint1:CGPointMake(maxX - offsetX, maxY) controlPoint2:CGPointMake(maxX, maxY - offsetY)];
    } else {
        [path lineToPoint:CGPointMake(maxX, maxY)];
    }

    if (bottomRight) {
        [path lineToPoint:CGPointMake(maxX, minY + cornerRadii.height)];
        [path curveToPoint:CGPointMake(maxX - cornerRadii.width, minY) controlPoint1:CGPointMake(maxX, minY + offsetY) controlPoint2:CGPointMake(maxX - offsetX, minY)];
    } else {
        [path lineToPoint:CGPointMake(maxX, minY)];
    }
    
    if (bottomLeft) {
        [path lineToPoint:CGPointMake(minX + cornerRadii.width, minY)];
        [path curveToPoint:CGPointMake(minX, minY + cornerRadii.height) controlPoint1:CGPointMake(minX + offsetX, minY) controlPoint2:CGPointMake(minX, minY + offsetY)];
    } else {
        [path lineToPoint:CGPointMake(minX, minY)];
    }

    [path closePath];
    
    return path;
}

+ (NSBezierPath *)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(KKRectCorner)corners cornerRadii:(CGSize)cornerRadii viewIsFlipped:(BOOL)viewIsFlipped viewBounds:(CGRect)viewBounds
{
    NSBezierPath *path  = [NSBezierPath bezierPath];
    CGFloat maxX        = rect.origin.x + rect.size.width;
    CGFloat minX        = rect.origin.x;
    CGFloat maxY        = viewIsFlipped ? rect.size.height + rect.origin.y : viewBounds.size.height - rect.origin.y;
    CGFloat minY        = viewIsFlipped ? rect.origin.y : maxY - rect.size.height;
    
    BOOL bottomRight    = viewIsFlipped ? corners & KKRectCornerTopRight : corners & KKRectCornerBottomRight;
    BOOL topRight       = viewIsFlipped ? corners & KKRectCornerBottomRight : corners & KKRectCornerTopRight;
    BOOL topLeft        = viewIsFlipped ? corners & KKRectCornerBottomLeft : corners & KKRectCornerTopLeft;
    BOOL bottomLeft     = viewIsFlipped ? corners & KKRectCornerTopLeft : corners & KKRectCornerBottomLeft;
    
    CGFloat offsetX     = cornerRadii.width * 0.45;
    CGFloat offsetY     = cornerRadii.height * 0.45;
    
    if (topLeft) {
        [path moveToPoint:CGPointMake(minX, maxY - cornerRadii.height)];
        [path curveToPoint:CGPointMake(minX + cornerRadii.width, maxY) controlPoint1:CGPointMake(minX, maxY - offsetY) controlPoint2:CGPointMake(minX + offsetX, maxY)];
    } else {
        [path moveToPoint:CGPointMake(minX, maxY)];
    }

    if (topRight) {
        [path lineToPoint:CGPointMake(maxX - cornerRadii.width, maxY)];
        [path curveToPoint:CGPointMake(maxX, maxY - cornerRadii.height) controlPoint1:CGPointMake(maxX - offsetX, maxY) controlPoint2:CGPointMake(maxX, maxY - offsetY)];
    } else {
        [path lineToPoint:CGPointMake(maxX, maxY)];
    }

    if (bottomRight) {
        [path lineToPoint:CGPointMake(maxX, minY + cornerRadii.height)];
        [path curveToPoint:CGPointMake(maxX - cornerRadii.width, minY) controlPoint1:CGPointMake(maxX, minY + offsetY) controlPoint2:CGPointMake(maxX - offsetX, minY)];
    } else {
        [path lineToPoint:CGPointMake(maxX, minY)];
    }
    
    if (bottomLeft) {
        [path lineToPoint:CGPointMake(minX + cornerRadii.width, minY)];
        [path curveToPoint:CGPointMake(minX, minY + cornerRadii.height) controlPoint1:CGPointMake(minX + offsetX, minY) controlPoint2:CGPointMake(minX, minY + offsetY)];
    } else {
        [path lineToPoint:CGPointMake(minX, minY)];
    }
    
    [path closePath];
    
    return path;
}

- (void)addLineToPoint:(CGPoint)point
{
    [self lineToPoint:point];
}

- (CGPathRef)CGPath
{
    NSInteger i, numElements;
    CGPathRef immutablePath = NULL;
    
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        /*
        if (!didClosePath) {
            CGPathCloseSubpath(path);
        }
         */
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    return immutablePath;
}

- (void)CGPathBlock:(void (^)(CGPathRef _Nonnull))block
{
    if (block)
    {
        CGPathRef path = self.CGPath;
        block(path);
        CGPathRelease(path);
    }
}

@end
