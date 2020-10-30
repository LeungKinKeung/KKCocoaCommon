//
//  KKAppearanceManager.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKAppearanceManager.h"
#import "NSColor+KK.h"
#import <objc/runtime.h>

static NSString *kEffectiveAppearanceKey = @"effectiveAppearance";
NSNotificationName const KKAppearanceDidChangeNotification = @"KKAppearanceDidChangeNotification";

BOOL KKCurrentAppearanceIsLight(void)
{
    return [KKAppearanceManager manager].style == KKAppearanceStyleLight;
}

@interface KKAppearanceManager()
{
    KKAppearanceStyle _style;
}

@property (nonatomic, readonly) NSApplication *app;

@end

@implementation KKAppearanceManager

#pragma mark - 初始化
- (void)initialization
{
    if (@available(macOS 10.14, *)) {
        // macOS 10.14+才能用
    } else {
        return;
    }
    [self updateAppearanceStyle];
    [self.app addObserver:self forKeyPath:kEffectiveAppearanceKey options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setStyle:(KKAppearanceStyle)style
{
    _style = style;
    
    if (@available(macOS 14.0, *)) {
        self.app.appearance =
        style == KKAppearanceStyleLight ?
        [NSAppearance appearanceNamed:NSAppearanceNameAqua] :
        [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    }
}

- (KKAppearanceStyle)style
{
    return _style;
}

- (void)updateAppearanceStyle
{
    if (@available(macOS 10.14, *)) {
        if ([self.appearance.name isEqualToString:NSAppearanceNameAqua]) {
            _style  = KKAppearanceStyleLight;
        } else {
            _style  = KKAppearanceStyleDark;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kEffectiveAppearanceKey]) {
        [self updateAppearanceStyle];
        [[NSNotificationCenter defaultCenter] postNotificationName:KKAppearanceDidChangeNotification object:self];
    }
}

- (NSApplication *)app
{
    return [NSApplication sharedApplication];
}

- (NSAppearance *)appearance
{
    return [NSApplication sharedApplication].effectiveAppearance;
}

- (void)dealloc
{
    if (@available(macOS 10.14, *))
    {
        [self.app removeObserver:self forKeyPath:kEffectiveAppearanceKey];
    }
}

+ (instancetype)manager
{
    static id obj;
    if (!obj) {
        static dispatch_once_t oncToken;
        dispatch_once(&oncToken, ^{
            obj = [[super allocWithZone:NULL] init];
            [obj initialization];
        });
    }
    return obj;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self manager];
}
- (id)copy {
    return [[self class] manager];
}

@end


@implementation NSColor (KKAppearanceManager)

+ (NSColor *)systemAccentColor
{
    if (@available(macOS 10.14, *)) {
        return [NSColor controlAccentColor];
    }
    else {
        return [NSColor colorWithDeviceRed:0 green:122/255.0 blue:1 alpha:1];
    }
}

+ (NSColor *)systemHighlightColor
{
    return [self highlightColor];
}

+ (NSColor *)colorWithDynamicProvider:(NSColor * (^)(KKAppearanceStyle style))dynamicProvider
{
    
    
    return nil;
}

@end
