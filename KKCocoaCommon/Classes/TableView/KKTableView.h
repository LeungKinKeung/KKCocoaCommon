//
//  KKTableView.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KKTableViewCell.h"
#import "NSIndexPath+KK.h"
#import "NSScrollView+KK.h"

@class KKTableView;

/// 默认高度：25.0
OBJC_EXTERN const CGFloat KKTableViewAutomaticDimension;
OBJC_EXTERN const NSInteger KKTableViewHeaderTag;
OBJC_EXTERN const NSInteger KKTableViewFooterTag;

/********************* 数据源 ******************************/
@protocol KKTableViewDataSource<NSObject>

@required
- (NSInteger)tableView:(KKTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSTableCellView *)tableView:(KKTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInTableView:(KKTableView *)tableView;
- (NSString *)tableView:(KKTableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(KKTableView *)tableView titleForFooterInSection:(NSInteger)section;

@end

/************************ 代理 ************************/
@protocol KKTableViewDelegate <NSObject>

@optional
- (CGFloat)tableView:(KKTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(KKTableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(KKTableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(KKTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(KKTableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray <NSIndexPath *>*)tableView:(KKTableView *)tableView willSelectRowsAtIndexPaths:(NSArray <NSIndexPath *>*)indexPaths;
- (void)tableView:(KKTableView *)tableView didSelectRowsAtIndexPaths:(NSArray <NSIndexPath *>*)indexPaths;
- (void)tableView:(KKTableView *)tableView didClickHeaderAtSection:(NSInteger)section;
- (void)tableView:(KKTableView *)tableView didClickFooterAtSection:(NSInteger)section;
- (void)tableView:(KKTableView *)tableView didDoubleClickRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(KKTableView *)tableView didDoubleClickHeaderAtSection:(NSInteger)section;
- (void)tableView:(KKTableView *)tableView didDoubleClickFooterAtSection:(NSInteger)section;
- (NSView *)tableView:(KKTableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (NSView *)tableView:(KKTableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(KKTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(KKTableView *)tableView heightForFooterInSection:(NSInteger)section;

- (BOOL)tableView:(KKTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(KKTableView *)tableView canMoveRowsAtIndexPaths:(NSArray <NSIndexPath *>*)indexPaths;
- (void)tableView:(KKTableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (void)tableView:(KKTableView *)tableView moveRowsAtIndexPaths:(NSArray <NSIndexPath *>*)sourceIndexPaths toIndexPath:(NSIndexPath *)destinationIndexPath;

@end

typedef NS_ENUM(NSInteger, KKTableViewStyle)
{
    KKTableViewStylePlain,
    KKTableViewStyleGrouped
};

typedef NS_ENUM(NSUInteger, KKTableViewInteriorBackgroundStyle) {
    KKTableViewInteriorBackgroundStyleDefault,      // 选中时文本和图像颜色变为白色
    KKTableViewInteriorBackgroundStyleAlwaysNormal, // 选中时文本和图像颜色不变
};

typedef NS_ENUM(NSUInteger, KKTableViewSelectionStyle) {
    /// 优化过的选中方式（可反选，但不可多选排序）
    KKTableViewSelectionStyleDefault,
    /// 系统预设的选中方式（不可反选，但可多选排序）
    KKTableViewSelectionStyleSystem,
    /**
     显示selectedImage/unselectedImage，并建议：
     更改选中背景色为灰色（selectionBackgroundColor = [NSColor colorWithWhite:0.5 alpha:0.1]）
     选中时文本和图像颜色不变（interiorBackgroundStyle = KKTableViewInteriorBackgroundStyleAlwaysNormal）
     实现- tableView:heightForRowAtIndexPath:固定高度
     */
    KKTableViewSelectionStyleCheckmark,
};

typedef NS_ENUM(NSUInteger, KKTableViewSortStyle) {
    /// 不可排序
    KKTableViewSortStyleNone,
    /// 默认的排序
    KKTableViewSortStyleDefalut,
    /// 显示排序图片
    KKTableViewSortStyleDisplaySortImage,
};

@interface KKTableView : NSScrollView

/// 初始化
/// @param style 样式
- (instancetype)initWithStyle:(KKTableViewStyle)style;
- (instancetype)initWithFrame:(CGRect)frame style:(KKTableViewStyle)style;
/// 代理
@property (nonatomic, weak) id<KKTableViewDelegate> delegate;
/// 数据源
@property (nonatomic, weak) id<KKTableViewDataSource> dataSource;
/// 样式
@property (nonatomic, readonly) KKTableViewStyle style;
/// 表视图
@property (nonatomic, readonly) NSTableView *tableView;
/// 表的页眉（需要提前设置高度，假如高度更改了，就调用-[KKTableView noteHeightOfTableHeaderViewChanged]）
@property (nonatomic, strong) NSView *tableHeaderView;
/// 表的页尾（需要提前设置高度，假如高度更改了，就调用-[KKTableView noteHeightOfTableFooterViewChanged]）
@property (nonatomic, strong) NSView *tableFooterView;
/// 半透明的（模糊背景），为YES时不能自定义选中背景色
@property (nonatomic, assign, getter=isTranslucent) BOOL translucent;
/// 设为纯色背景色（NSColor.clearColor会变成模糊背景）
@property (nonatomic, strong) NSColor *solidBackgroundColor;
/// 分隔线，默认:KKTableViewCellSeparatorStyleSingleLine
@property (nonatomic, assign) KKTableViewCellSeparatorStyle separatorStyle;
/// 分隔线颜色
@property (nonatomic, strong) NSColor *separatorColor;
/// 分隔线边距
@property (nonatomic, assign) NSEdgeInsets separatorInset;
/// 分隔线宽度
@property (nonatomic, assign) CGFloat separatorLineWidth;
/// 可见的Cell
@property (nonatomic, readonly) NSArray <__kindof NSView *>*visibleCells;
/// 可见的Cell索引
@property (nonatomic, readonly) NSArray <NSIndexPath *> *indexPathsForVisibleRows;
/// Section数
@property (nonatomic, readonly) NSInteger numberOfSections;
/// 默认行高，默认：KKTableViewAutomaticDimension
@property (nonatomic, assign) CGFloat rowHeight;
/// 默认页眉高度，默认：KKTableViewAutomaticDimension
@property (nonatomic, assign) CGFloat sectionHeaderHeight;
/// 默认页尾高度，默认：KKTableViewAutomaticDimension
@property (nonatomic, assign) CGFloat sectionFooterHeight;
/// 估算的行高，默认：KKTableViewAutomaticDimension，设为0禁用
@property (nonatomic, assign) CGFloat estimatedRowHeight;
/// 估算的页眉高度，默认：KKTableViewAutomaticDimension，设为0禁用
@property (nonatomic, assign) CGFloat estimatedSectionHeaderHeight;
/// 估算的页尾高度，默认：KKTableViewAutomaticDimension，设为0禁用
@property (nonatomic, assign) CGFloat estimatedSectionFooterHeight;
/// 行使用自动高度
@property (nonatomic, readonly) BOOL usesAutomaticRowHeights;
/// 页眉使用自动高度
@property (nonatomic, readonly) BOOL usesAutomaticHeaderHeights;
/// 页尾使用自动高度
@property (nonatomic, readonly) BOOL usesAutomaticFooterHeights;
/// 使用了自定义的分隔线边距
@property (nonatomic, readonly) BOOL usesCustomSeparatorInset;

/// 选中时是否改变外观（比如改变文本和模板图片颜色）
@property (nonatomic, assign) KKTableViewInteriorBackgroundStyle interiorBackgroundStyle;
/// 选择样式
@property (nonatomic, assign) KKTableViewSelectionStyle selectionStyle;
/// 选中时的图标
@property (nonatomic, readwrite) NSImage *selectedImage;
/// 未选中时的图标
@property (nonatomic, readwrite) NSImage *unselectedImage;
/// 选中时的背景色
@property (nonatomic, strong) NSColor *selectionBackgroundColor;
/// 选中时的背景渐变色
@property (nonatomic, strong) NSArray <NSColor *>*selectionBackgroundColors;
/// 选中时的背景图片
@property (nonatomic, strong) NSImage *selectionBackgroundImage;
/// 选中时的背景渐变色(CGColor)
@property (nonatomic, readonly) NSArray *selectionBackgroundCGColors;
/// 选中时的背景图片(NSImageRep)
@property (nonatomic, readonly) NSImageRep *selectionBackgroundImageRep;
/// 假如为NO，选中的背景色会在视图失去焦点时变为灰色，否则保持原来的颜色
@property (nonatomic, assign) BOOL alwaysEmphasizedSelectionBackground;
/// 允许选择，默认：YES
@property (nonatomic, assign) BOOL allowsSelection;
/// 允许不选，默认：YES
@property (nonatomic, readwrite) BOOL allowsEmptySelection;
/// 允许多选，默认：NO
@property (nonatomic, readwrite) BOOL allowsMultipleSelection;
/// 排序
@property (nonatomic, assign) KKTableViewSortStyle sortStyle;
/// 默认：NSImageNameListViewTemplate
@property (nonatomic, strong) NSImage *sortingImage;
/// 已选行数
@property (nonatomic, readonly) NSInteger numberOfSelectedRows;
/// 已选的索引
@property (nonatomic, readonly) NSIndexPath *indexPathForSelectedRow;
/// 已选的索引列表
@property (nonatomic, readonly) NSArray<NSIndexPath *> *indexPathsForSelectedRows;
/// 有未提交的更新
@property (nonatomic, readonly) BOOL hasUncommittedUpdates;
/// 重用Cell
- (__kindof NSView *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
/// 取出Cell
- (__kindof NSView *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
/// 获取这个位置的Cell的索引
- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point;
/// 获取此Cell的索引
- (NSIndexPath *)indexPathForCell:(NSView *)cell;
/// 获取此范围的Cell的索引
- (NSArray<NSIndexPath *> *)indexPathsForRowsInRect:(CGRect)rect;
/// 此Section的行数
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
/// 页眉的位置大小
- (CGRect)rectForHeaderInSection:(NSInteger)section;
/// 页尾的位置大小
- (CGRect)rectForFooterInSection:(NSInteger)section;
/// Cell的位置大小
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;
/// 多选
- (void)selectRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
/// 选中全部
- (void)selectAll;
/// 选择
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath;
/// 选择并滚动
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(KKScrollViewScrollPosition)scrollPosition;
/// 反选
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath;
/// 取消全部选择
- (void)deselectAll;
/// 滚动
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(KKScrollViewScrollPosition)scrollPosition animated:(BOOL)animated;
/// 重新加载
- (void)reloadData;
/// 开始更新
- (void)beginUpdates;
/// 提交更新
- (void)endUpdates;

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)insertSection:(NSInteger)section withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)deleteSection:(NSInteger)section withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)reloadSection:(NSInteger)section withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(NSTableViewAnimationOptions)animation;
- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(NSTableViewAnimationOptions)animation;

- (void)noteHeightOfRowWithIndexPathChanged:(NSIndexPath *)indexPath;
- (void)noteHeightOfHeaderWithSectionChanged:(NSInteger)section;
- (void)noteHeightOfFooterWithSectionChanged:(NSInteger)section;
- (void)noteHeightOfTableHeaderViewChanged;
- (void)noteHeightOfTableFooterViewChanged;
- (void)noteHeightOfRowWithCellChanged:(__kindof NSView *)cell height:(CGFloat)height;
- (BOOL)isAutomaticRowHeight:(__kindof NSView *)cell;

/// 注册Nib
- (void)registerNib:(NSNib *)nib forIdentifier:(NSString *)identifier;
/// 注册Class
- (void)registerClass:(Class)cellClass forIdentifier:(NSString *)identifier;

@end


@interface NSImage (KKTableView)

/// 选中的图标
/// @param tintColor 中间勾号的颜色
/// @param backgroundColor 背景色
/// @param size 大小
+ (NSImage *)kktableViewSelectedImageWithTintColor:(NSColor *)tintColor
                                   backgroundColor:(NSColor *)backgroundColor
                                              size:(CGSize)size;

/// 未选中的图标
/// @param borderColor 边框颜色
/// @param lineWidth 边框线粗细
/// @param size 大小
+ (NSImage *)kktableViewUnselectedImageWithBorderColor:(NSColor *)borderColor
                                             lineWidth:(CGFloat)lineWidth
                                                  size:(CGSize)size;

@end
