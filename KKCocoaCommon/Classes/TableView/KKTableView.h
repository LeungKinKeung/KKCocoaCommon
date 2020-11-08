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

/********************* 数据源 ******************************/
@protocol KKTableViewDataSource<NSObject>

@required
- (NSInteger)tableView:(KKTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSView *)tableView:(KKTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

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
- (void)tableView:(KKTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(KKTableView *)tableView didClickHeaderAtSection:(NSInteger)section;
- (void)tableView:(KKTableView *)tableView didClickFooterAtSection:(NSInteger)section;
- (void)tableView:(KKTableView *)tableView didDoubleClickRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(KKTableView *)tableView didDoubleClickHeaderAtSection:(NSInteger)section;
- (void)tableView:(KKTableView *)tableView didDoubleClickFooterAtSection:(NSInteger)section;
- (NSView *)tableView:(KKTableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (NSView *)tableView:(KKTableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(KKTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(KKTableView *)tableView heightForFooterInSection:(NSInteger)section;

@end

typedef NS_ENUM(NSInteger, KKTableViewStyle)
{
    KKTableViewStylePlain,
    KKTableViewStyleGrouped
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
/// 表视图
@property (nonatomic, readonly) NSTableView *tableView;
/// 样式
@property (nonatomic, readonly) KKTableViewStyle style;
/// 可见的Cell
@property (nonatomic, readonly) NSArray <__kindof NSView *>*visibleCells;
/// 可见的Cell索引
@property (nonatomic, readonly) NSArray <NSIndexPath *> *indexPathsForVisibleRows;
/// 默认行高，默认：KKTableViewAutomaticDimension
@property (nonatomic) CGFloat rowHeight;
/// 默认页眉高度，默认：KKTableViewAutomaticDimension
@property (nonatomic) CGFloat sectionHeaderHeight;
/// 默认页尾高度，默认：KKTableViewAutomaticDimension
@property (nonatomic) CGFloat sectionFooterHeight;
/// 估算的行高，默认：KKTableViewAutomaticDimension，设为0禁用
@property (nonatomic) CGFloat estimatedRowHeight;
/// 估算的页眉高度，默认：KKTableViewAutomaticDimension，设为0禁用
@property (nonatomic) CGFloat estimatedSectionHeaderHeight;
/// 估算的页尾高度，默认：KKTableViewAutomaticDimension，设为0禁用
@property (nonatomic) CGFloat estimatedSectionFooterHeight;

/// 允许选择，默认：YES
@property (nonatomic, assign) BOOL allowsSelection;
/// 允许不选，默认：YES
@property (nonatomic, readwrite) BOOL allowsEmptySelection;
/// 允许多选，默认：NO
@property (nonatomic, readwrite) BOOL allowsMultipleSelection;
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
/// 获取此Cell的索引
- (NSIndexPath *)indexPathForCell:(NSView *)cell;
/// 选择
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath;
/// 选择并滚动
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(KKScrollViewScrollPosition)scrollPosition;
/// 反选
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath;
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

/// 注册Nib
- (void)registerNib:(NSNib *)nib forIdentifier:(NSString *)identifier;
/// 注册Class
- (void)registerClass:(Class)cellClass forIdentifier:(NSString *)identifier;



@end
