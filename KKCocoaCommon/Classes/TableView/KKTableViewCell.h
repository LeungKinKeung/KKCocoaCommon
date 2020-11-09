//
//  KKTableViewCell.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KKTableView;

/// 高度已更改通知
OBJC_EXTERN NSNotificationName const KKTableViewCellHeightDidChangeNotification;

typedef NS_ENUM(NSUInteger, KKTableViewCellStyle) {
    KKTableViewCellStyleDefault,    // 图像，文本
    KKTableViewCellStyleValue1,     // 图像，左对齐文本，右对齐文本
    KKTableViewCellStyleValue2,     // 右对齐文本，左对齐文本
    KKTableViewCellStyleSubtitle,   // 图像，上文本，下文本
    KKTableViewCellStylePlain,      // 图像，文本
    KKTableViewCellStyleGrouped,    // 图像，文本
};

typedef NS_ENUM(NSInteger, KKTableViewCellSeparatorStyle) {
    KKTableViewCellSeparatorStyleNone,
    KKTableViewCellSeparatorStyleSingleLine,
};

typedef NS_ENUM(NSInteger, KKTableViewCellAccessoryType) {
    KKTableViewCellAccessoryNone,
    KKTableViewCellAccessoryDisclosureIndicator,
    KKTableViewCellAccessoryCheckmark,
};

@interface KKTableViewCell : NSTableCellView

/// 初始化
/// @param style 样式
/// @param reuseIdentifier 重用标识符
- (instancetype)initWithStyle:(KKTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

/// 标题
@property (nonatomic, readwrite) NSTextField *textLabel;
/// 详情
@property (nonatomic, readwrite) NSTextField *detailTextLabel;
/// 附加视图
@property (nonatomic, readwrite) NSView *accessoryView;

/// 样式
@property (nonatomic, assign) KKTableViewCellStyle style;
/// 附加类型
@property (nonatomic, assign) KKTableViewCellAccessoryType accessoryType;
/// 分隔线，默认:KKTableViewCellSeparatorStyleSingleLine
@property (nonatomic, assign) KKTableViewCellSeparatorStyle separatorStyle;
/// 分隔线颜色
@property (nonatomic, strong) NSColor *separatorColor;
/// 内容边距
@property (nonatomic, assign) NSEdgeInsets contentInsets;
/// 分隔线边距
@property (nonatomic, assign) NSEdgeInsets separatorInset;
/// 分隔线宽度
@property (nonatomic, assign) CGFloat separatorLineWidth;
/// 子视图的水平间隔
@property (nonatomic, assign) CGFloat interitemSpacing;
/// 子视图的垂直间隔
@property (nonatomic, assign) CGFloat lineSpacing;
/// 重用标识符
@property (nonatomic, readwrite) NSString *reuseIdentifier;
/// 是否选中
@property (nonatomic, readwrite, getter=isSelected) BOOL selected;
/// 上一行已选中
@property (nonatomic, readwrite, getter=isPreviousRowSelected) BOOL previousRowSelected;
/// 下一行已选中
@property (nonatomic, readwrite, getter=isNextRowSelected) BOOL nextRowSelected;
/// 是页眉
@property (nonatomic, readonly) BOOL isHeader;
/// 是第一个Cell
@property (nonatomic, readonly) BOOL isFirstRow;
/// 是Cell
@property (nonatomic, readonly) BOOL isRow;
/// 是最后一个Cell
@property (nonatomic, readonly) BOOL isLastRow;
/// 是页尾
@property (nonatomic, readonly) BOOL isFooter;
/// 使用自动高度
@property (nonatomic, readonly) BOOL usesAutomaticRowHeights;

/// 初始化
- (void)commonInit;
/// 选择已更改
- (void)selectionDidChange;
/// 绘制分隔线
- (void)drawSeparatorInRect:(NSRect)dirtyRect;

@end
