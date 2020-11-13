//
//  KKAppearanceManager.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKAppearanceManager.h"
#import <objc/runtime.h>

static NSString *kEffectiveAppearanceKey = @"effectiveAppearance";
NSNotificationName const KKAppAppearanceDidChangeNotification = @"KKAppAppearanceDidChangeNotification";

BOOL KKAppAppearanceIsLight(void)
{
    return [KKAppearanceManager manager].style == KKAppearanceStyleLight;
}

BOOL KKViewAppearanceIsLight(NSView *view)
{
    return [view.effectiveAppearance.name isEqualToString:NSAppearanceNameAqua];
}

@interface KKAppearanceManager()
{
    KKAppearanceStyle _style;
}

@property (nonatomic, readonly) NSApplication *app;
@property (nonatomic, strong) NSMutableDictionary *blocks;

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
    self.blocks = [NSMutableDictionary dictionary];
    [self updateAppearanceStyle];
    [self.app addObserver:self forKeyPath:kEffectiveAppearanceKey options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemColorsDidChange:) name:NSSystemColorsDidChangeNotification object:nil];
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
        
        KKAppearanceStyle style =
        [self.appearance.name isEqualToString:NSAppearanceNameAqua] ?
        KKAppearanceStyleLight :
        KKAppearanceStyleDark;
        
        if (_style == style) {
            return;
        }
        _style = style;
        [self performBlocks];
        [[NSNotificationCenter defaultCenter] postNotificationName:KKAppAppearanceDidChangeNotification object:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kEffectiveAppearanceKey]) {
        [self updateAppearanceStyle];
    }
}

- (void)systemColorsDidChange:(NSNotification *)noti
{
    [self performBlocks];
}

- (NSApplication *)app
{
    return [NSApplication sharedApplication];
}

- (NSAppearance *)appearance
{
    return [NSApplication sharedApplication].effectiveAppearance;
}

- (void)addAppearanceObserver:(NSObject *)observer block:(KKAppearanceBlock)block
{
    if (block == nil) {
        return;
    }
    if (@available(macOS 10.14, *))
    {
        NSString *key           = [NSString stringWithFormat:@"%lu",observer.hash];
        NSMutableArray *array   = [self.blocks valueForKey:key];
        if (array == nil) {
            array               = [NSMutableArray array];
            [self.blocks setValue:array forKey:key];
        }
        [array addObject:block];
    }
    block(_style == KKAppearanceStyleLight);
}

- (void)removeAppearanceObserver:(NSObject *)observer
{
    NSString *key           = [NSString stringWithFormat:@"%lu",observer.hash];
    NSMutableArray *array   = [self.blocks valueForKey:key];
    if (array) {
        [array removeAllObjects];
    }
}

- (void)performBlocks
{
    NSArray *allValues = self.blocks.allValues;
    for (NSArray *blocks in allValues) {
        for (KKAppearanceBlock block in blocks) {
            block(_style == KKAppearanceStyleLight);
        }
    }
}

- (void)dealloc
{
    if (@available(macOS 10.14, *)) {
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

@implementation NSObject (KKAppearanceManager)

- (void)appearanceBlock:(KKAppearanceBlock)block
{
    [[KKAppearanceManager manager] addAppearanceObserver:self block:block];
}

- (void)removeAppearanceBlocks
{
    [[KKAppearanceManager manager] removeAppearanceObserver:self];
}

@end

@implementation NSColor (KKAppearanceManager)

+ (NSColor *)systemAccentColor
{
    if (@available(macOS 10.14, *)) {
        // NSColor.selectedContentBackgroundColor
        return [NSColor controlAccentColor];
    }
    else {
        return [NSColor alternateSelectedControlColor];
    }
}

+ (NSColor *)systemSelectedContentBackgroundColor
{
    if (@available(macOS 10.14, *)) {
        return NSColor.selectedContentBackgroundColor;
    }
    else {
        return NSColor.alternateSelectedControlColor;
    }
}

+ (NSColor *)systemUnemphasizedSelectedContentBackgroundColor
{
    if (@available(macOS 10.14, *)) {
        return NSColor.unemphasizedSelectedTextBackgroundColor;
    }
    else {
        return NSColor.secondarySelectedControlColor;
    }
}

+ (NSColor *)systemHighlightColor
{
    // NSColor.selectedControlColor
    return [self selectedTextBackgroundColor];
}

@end
