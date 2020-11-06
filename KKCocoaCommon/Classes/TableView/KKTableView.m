//
//  KKTableView.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKTableView.h"

const CGFloat KKTableViewAutomaticDimension     = 25.0;
static NSInteger KKTableViewHeaderTag           = -1;
static NSInteger KKTableViewFooterTag           = -2;

static NSString *KKTableRowViewIdentifier       = @"KKTableRowViewIdentifier";
static NSString *KKTableViewHeaderIdentifier    = @"KKTableViewHeaderIdentifier";
static NSString *KKTableViewFooterIdentifier    = @"KKTableViewFooterIdentifier";

#pragma mark - KKTableViewSection
@interface KKTableViewRowModel : NSObject
@property (nonatomic, assign) BOOL isHeader;
@property (nonatomic, assign) BOOL isFooter;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@end
@implementation KKTableViewRowModel
+ (instancetype)header
{
    KKTableViewRowModel *row = [KKTableViewRowModel new];
    row.isHeader = YES;
    return row;
}
+ (instancetype)row
{
    KKTableViewRowModel *row = [KKTableViewRowModel new];
    return row;
}
+ (instancetype)footer
{
    KKTableViewRowModel *row = [KKTableViewRowModel new];
    row.isFooter = YES;
    return row;
}
@end

#pragma mark - KKTableRowView
@interface KKTableRowView : NSTableRowView
@end
@implementation KKTableRowView
- (void)layout
{
    [super layout];
    NSArray *subViews = self.subviews;
    for (NSView *subview in subViews) {
        if ([subview isKindOfClass:[NSTableCellView class]]) {
            subview.frame = self.bounds;
            break;
        }
    }
}
@end

#pragma mark - KKTableView
@interface KKTableView ()<NSTableViewDelegate,NSTableViewDataSource>

@property (nonatomic, strong) NSTableView *tableView;
@property (nonatomic, assign) KKTableViewStyle style;
@property (nonatomic, assign) BOOL usesAutomaticRowHeights;
@property (nonatomic, assign) BOOL usesAutomaticHeaderHeights;
@property (nonatomic, assign) BOOL usesAutomaticFooterHeights;
@property (nonatomic, assign, getter=isViewAppeared) BOOL viewAppeared;
@property (nonatomic, assign) BOOL hasUncommittedUpdates;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <KKTableViewRowModel *>*>*sections;
@property (nonatomic, strong) NSMutableDictionary <NSString *,Class>*cellClassMap;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic, strong) NSIndexSet *columnIndexSet;

@end

@implementation KKTableView

#pragma mark - 初始化
- (instancetype)initWithStyle:(KKTableViewStyle)style
{
    return [self initWithFrame:CGRectZero style:style];
}

- (instancetype)initWithFrame:(CGRect)frame style:(KKTableViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
        [self tableView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self tableView];
}

- (NSTableView *)tableView
{
    if (_tableView == nil)
    {
        NSTableView *tableView      = [[NSTableView alloc] init];
        _tableView                  = tableView;
        tableView.frame             = self.bounds;
        self.contentView.documentView   = tableView;
        NSTableColumn *columen      = [[NSTableColumn alloc] initWithIdentifier:[self className]];
        columen.resizingMask        = NSTableColumnAutoresizingMask;
        [tableView addTableColumn:columen];
        tableView.headerView        = nil;
        tableView.delegate          = self;
        tableView.dataSource        = self;
        tableView.doubleAction      = @selector(tableViewCellDoubleClicked:);
        tableView.target            = self;
        tableView.floatsGroupRows   = self.style == KKTableViewStylePlain;
        tableView.allowsEmptySelection      = YES;
        tableView.selectionHighlightStyle   = NSTableViewSelectionHighlightStyleRegular;
        
        self.hasVerticalScroller    = YES;
        self.hasHorizontalScroller  = NO;
        self.autohidesScrollers     = YES;
        self.scrollerStyle          = NSScrollerStyleOverlay;
        self.verticalScrollElasticity       = NSScrollElasticityAllowed;
        
        self.rowHeight                      =
        self.sectionHeaderHeight            =
        self.sectionFooterHeight            =
        self.estimatedRowHeight             =
        self.estimatedSectionHeaderHeight   =
        self.estimatedSectionFooterHeight   = KKTableViewAutomaticDimension;
        self.columnIndexSet                 = [NSIndexSet indexSetWithIndex:0];
        _allowsSelection                    = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewCellHeightDidChange:) name:KKTableViewCellHeightDidChangeNotification object:nil];
    }
    return _tableView;
}

#pragma mark Cell的高度已更改
- (void)tableViewCellHeightDidChange:(NSNotification *)noti
{
    NSView *view    = noti.object;
//    if ([view isKindOfClass:[NSView class]] == NO) {
//        return;
//    }
    NSInteger row   = [self.tableView rowForView:view];
    KKTableViewRowModel *rowModel = [self rowModelForRow:row];
    rowModel.height = [view intrinsicContentSize].height;
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:row];
    [self.tableView noteHeightOfRowsWithIndexesChanged:set];
}

#pragma mark 双击
- (void)tableViewCellDoubleClicked:(NSTableView *)sender
{
    NSIndexPath *indexPath = [self indexPathForRow:sender.clickedRow];
    if ([self isHeaderForIndexPath:indexPath]) {
        if ([self.delegate respondsToSelector:@selector(tableView:didDoubleClickHeaderAtSection:)]) {
            [self.delegate tableView:self didDoubleClickHeaderAtSection:indexPath.section];
        }
    } else if ([self isFooterForIndexPath:indexPath]) {
        if ([self.delegate respondsToSelector:@selector(tableView:didDoubleClickFooterAtSection:)]) {
            [self.delegate tableView:self didDoubleClickFooterAtSection:indexPath.section];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(tableView:didDoubleClickRowAtIndexPath:)]) {
            [self.delegate tableView:self didDoubleClickRowAtIndexPath:indexPath];
        }
    }
}

#pragma mark 将要绘制（重绘）
- (void)viewWillDraw
{
    [super viewWillDraw];
    if (self.isViewAppeared) {
        return;
    }
    self.viewAppeared = YES;
    [self reloadData];
}

- (void)setDelegate:(id<KKTableViewDelegate>)delegate
{
    _delegate = delegate;
    // 是否使用自动布局
    self.usesAutomaticRowHeights    =
    [delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)] == NO;
    self.usesAutomaticHeaderHeights =
    [delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)] == NO;
    self.usesAutomaticFooterHeights =
    [delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)] == NO;
    
    [self reloadData];
}

- (void)setDataSource:(id<KKTableViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self reloadData];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    [self.sections removeAllObjects];
    
    if (![self.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        return 0;
    }
    // 节数
    NSInteger sectionCount = 0;
    // 总的行计数
    NSInteger totalCount    = 0;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sectionCount = [self.dataSource numberOfSectionsInTableView:self];
        if (sectionCount <= 0) {
            return 0;
        }
    } else {
        sectionCount = 1;
    }
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        NSMutableArray *rowModels   = [NSMutableArray array];
        if ([self hasHeaderInSection:section]) {
            [rowModels addObject:[KKTableViewRowModel header]];
        }
        NSInteger numberOfRows      = [self.dataSource tableView:self numberOfRowsInSection:section];
        for (NSInteger row = 0; row < numberOfRows; row++) {
            [rowModels addObject:[KKTableViewRowModel row]];
        }
        if ([self hasFooterInSection:section]) {
            [rowModels addObject:[KKTableViewRowModel footer]];
        }
        totalCount                  = totalCount + rowModels.count;
        [self.sections addObject:rowModels];
    }
    return totalCount;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    KKTableRowView *view = [tableView makeViewWithIdentifier:KKTableRowViewIdentifier owner:self];
    if (view == nil) {
        view                = [KKTableRowView new];
        view.identifier     = KKTableRowViewIdentifier;
        view.groupRowStyle  = NO;
    }
    return view;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    // Warning:如果KKTableView/NSTableView的视图为不可见或frame为{0,0,0,0}，此方法将不执行
    NSIndexPath *indexPath  = [self indexPathForRow:row];
    KKTableViewCell *cell   = nil;
    if ([self isHeaderForIndexPath:indexPath]) {
        // Header
        if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
            NSView *view = [self.delegate tableView:self viewForHeaderInSection:indexPath.section];
            if (view.identifier != nil && [view.identifier isEqualToString:@""] == NO) {
                cell = (KKTableViewCell *)view;
                
            } else {
                cell = [self dequeueReusableCellWithIdentifier:KKTableViewHeaderIdentifier];
                if (cell.subviews.firstObject != view) {
                    NSArray *subviews = cell.subviews.copy;
                    for (NSView *subview in subviews) {
                        [subview removeFromSuperview];
                    }
                    [cell addSubview:view];
                    view.frame = cell.bounds;
                    view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
                }
            }
        } else if ([self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            NSString *title = [self.dataSource tableView:self titleForHeaderInSection:indexPath.section];
            cell = [self dequeueReusableCellWithIdentifier:KKTableViewHeaderIdentifier];
            cell.textLabel.stringValue = title ? title : @"";
        }
        if ([cell isKindOfClass:[KKTableViewCell class]]) {
            cell.usesAutomaticRowHeights = self.usesAutomaticHeaderHeights;
        }
        
    } else if ([self isFooterForIndexPath:indexPath]) {
        // Footer
        if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
            NSView *view = [self.delegate tableView:self viewForFooterInSection:indexPath.section];
            if (view.identifier != nil && [view.identifier isEqualToString:@""] == NO) {
                cell = (KKTableViewCell *)view;
                
            } else {
                cell = [self dequeueReusableCellWithIdentifier:KKTableViewFooterIdentifier];
                if (cell.subviews.firstObject != view) {
                    NSArray *subviews = cell.subviews.copy;
                    for (NSView *subview in subviews) {
                        [subview removeFromSuperview];
                    }
                    [cell addSubview:view];
                    view.frame = cell.bounds;
                    view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
                }
            }
        } else if ([self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
            NSString *title = [self.dataSource tableView:self titleForFooterInSection:indexPath.section];
            cell = [self dequeueReusableCellWithIdentifier:KKTableViewFooterIdentifier];
            cell.textLabel.stringValue = title ? title : @"";
        }
        if ([cell isKindOfClass:[KKTableViewCell class]]) {
            cell.usesAutomaticRowHeights = self.usesAutomaticFooterHeights;
        }
        
    } else if ([self.dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        cell = (KKTableViewCell *)[self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[KKTableViewCell class]]) {
            cell.usesAutomaticRowHeights = self.usesAutomaticRowHeights;
        }
    }
    return cell;
}
#pragma mark - NSTableViewDelegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSIndexPath *indexPath  = [self indexPathForRow:row];
    if ([self isHeaderForIndexPath:indexPath]) {
        if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
            return [self.delegate tableView:self heightForHeaderInSection:indexPath.section];
        }
    } else if ([self isFooterForIndexPath:indexPath]) {
        if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
            return [self.delegate tableView:self heightForFooterInSection:indexPath.section];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
            return [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
        }
    }
    CGFloat height = 0;
    KKTableViewRowModel *rowModel = [self rowModelForRow:row];
    if (rowModel == nil) {
        if ([self isHeaderForIndexPath:indexPath]) {
            height  = self.estimatedSectionHeaderHeight;
        } else if ([self isFooterForIndexPath:indexPath]) {
            height  = self.estimatedSectionFooterHeight;
        } else {
            height  = self.estimatedRowHeight;
        }
    }
    if (height > 0) {
        return height;
    }
    height = rowModel.height;
    if (height == 0) {
        if ([self isHeaderForIndexPath:indexPath]) {
            height  = self.sectionHeaderHeight;
        } else if ([self isFooterForIndexPath:indexPath]) {
            height  = self.sectionFooterHeight;
        } else {
            height  = self.rowHeight;
        }
    }
    return height;
}

#pragma mark 假如是Header且style为KKTableViewStylePlain就设为浮动
- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
    if (self.style == KKTableViewStyleGrouped) {
        return NO;
    }
    return [self isHeaderForRow:row];
}

#pragma mark 选择
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    if (self.allowsSelection == NO) {
        return NO;
    }
    self.lastSelectedIndexPath  = nil;
    NSIndexPath *indexPath      = [self indexPathForRow:row];
    if ([self isHeaderForIndexPath:indexPath]) {
        if ([self.delegate respondsToSelector:@selector(tableView:didClickHeaderAtSection:)]) {
            [self.delegate tableView:self didClickHeaderAtSection:indexPath.section];
        }
        return NO;
    }
    if ([self isFooterForIndexPath:indexPath]) {
        if ([self.delegate respondsToSelector:@selector(tableView:didClickFooterAtSection:)]) {
            [self.delegate tableView:self didClickFooterAtSection:indexPath.section];
        }
        return NO;
    }
    NSIndexPath *selectedIndexPath = nil;
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        selectedIndexPath = [self.delegate tableView:self willSelectRowAtIndexPath:indexPath];
        if (selectedIndexPath == nil) {
            return NO;
        }
        // 改选
        if (selectedIndexPath.section != indexPath.section ||
            selectedIndexPath.row != indexPath.row) {
            [self selectRowAtIndexPath:selectedIndexPath];
            return NO;
        }
    }
    if (selectedIndexPath == nil) {
       self.lastSelectedIndexPath  = indexPath;
    }
    return YES;
}

#pragma mark 选择已更改
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (notification.object != self.tableView) {
        return;
    }
    NSIndexPath *indexPath      = self.lastSelectedIndexPath;
    self.lastSelectedIndexPath  = nil;
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark 索引
- (BOOL)isHeaderForRow:(NSInteger)row
{
    return [self isHeaderForIndexPath:[self indexPathForRow:row]];
}

- (BOOL)isFooterForRow:(NSInteger)row
{
    return [self isFooterForIndexPath:[self indexPathForRow:row]];
}

- (BOOL)isHeaderForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == KKTableViewHeaderTag;
}

- (BOOL)isFooterForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == KKTableViewFooterTag;
}

#pragma mark 重用Cell
- (__kindof NSView *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (identifier == nil) {
        return nil;
    }
    NSTableCellView *cell = [self.tableView makeViewWithIdentifier:identifier owner:self];
    if (cell != nil) {
        return cell;
    }
    // 如果为预设的Cell
    if ([KKTableViewHeaderIdentifier isEqualToString:identifier]) {
        return [[KKTableViewCell alloc] initWithStyle:KKTableViewCellStyleHeader reuseIdentifier:identifier];
    } else if ([KKTableViewFooterIdentifier isEqualToString:identifier]) {
        return [[KKTableViewCell alloc] initWithStyle:KKTableViewCellStyleFooter reuseIdentifier:identifier];
    }
    
    Class cellClass = [self.cellClassMap valueForKey:identifier];
    if (cellClass == NULL) {
        return nil;
    }
    cell            = [cellClass new];
    cell.identifier = identifier;
    return cell;
}

#pragma mark 取出Cell
- (__kindof NSView *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row   = [self rowForIndexPath:indexPath];
    NSView *cell    = [self.tableView viewAtColumn:0 row:row makeIfNecessary:YES];
    return cell;
}

- (NSTableRowView *)rowViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row           = [self rowForIndexPath:indexPath];
    NSTableRowView *view    = [self.tableView rowViewAtRow:row makeIfNecessary:YES];
    return view;
}

- (NSIndexPath *)indexPathForCell:(NSView *)cell
{
    NSInteger row   = [self.tableView rowForView:cell];
    if (row == -1) {
        return nil;
    }
    return [self indexPathForRow:row];
}

#pragma mark - 关联方法
- (void)reloadData
{
    if (self.viewAppeared == NO) {
        return;
    }
    [self.tableView reloadData];
}

- (void)beginUpdates
{
    _hasUncommittedUpdates = YES;
    [self.tableView beginUpdates];
}

- (void)endUpdates
{
    _hasUncommittedUpdates = NO;
    [self.tableView endUpdates];
}

- (BOOL)hasUncommittedUpdates
{
    return _hasUncommittedUpdates;
}

#pragma mark 插入Sections
- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(NSTableViewAnimationOptions)animation
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSInteger begin = [self rowForSection:idx];
         
        NSMutableArray *rowModels   = [NSMutableArray array];
        if ([self hasHeaderInSection:idx]) {
            [rowModels addObject:[KKTableViewRowModel header]];
        }
        NSInteger numberOfRows =
        [self.dataSource tableView:self numberOfRowsInSection:idx];
        
        for (NSInteger row = 0; row < numberOfRows; row++) {
            [rowModels addObject:[KKTableViewRowModel row]];
        }
        if ([self hasFooterInSection:idx]) {
            [rowModels addObject:[KKTableViewRowModel footer]];
        }
        [self.sections insertObject:rowModels atIndex:idx];
        
        NSRange range           = NSMakeRange(begin, rowModels.count);
        NSIndexSet *indexSet    = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView insertRowsAtIndexes:indexSet withAnimation:animation];
    }];
}

#pragma mark 移除Sections
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(NSTableViewAnimationOptions)animation
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray *models  = [self.sections objectAtIndex:idx];
        NSInteger begin         = [self rowForSection:idx];
        NSRange range           = NSMakeRange(begin, models.count);
        NSIndexSet *indexSet    = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView removeRowsAtIndexes:indexSet withAnimation:animation];
    }];
    [self.sections removeObjectsAtIndexes:sections];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(NSTableViewAnimationOptions)animation
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray *models  = [self.sections objectAtIndex:idx];
        NSInteger begin         = [self rowForSection:idx];
        NSRange range           = NSMakeRange(begin, models.count);
        NSIndexSet *indexSet    = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadDataForRowIndexes:indexSet columnIndexes:self.columnIndexSet];
    }];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    NSArray *fromSection    = [self.sections objectAtIndex:section];
    NSArray *toSection      = [self.sections objectAtIndex:newSection];
    NSInteger begin         = 0;
    NSRange range           = NSMakeRange(0, 0);
    NSIndexSet *indexSet    = nil;
    NSTableViewAnimationOptions opt = NSTableViewAnimationEffectNone;
    {
        // 移除
        begin               = [self rowForSection:section];
        range               = NSMakeRange(begin, fromSection.count);
        indexSet            = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView removeRowsAtIndexes:indexSet withAnimation:opt];
        
        // 插入
        [self.sections insertObject:toSection atIndex:section];
        range               = NSMakeRange(begin, toSection.count);
        indexSet            = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView insertRowsAtIndexes:indexSet withAnimation:opt];
    }
    {
        // 移除
        begin               = [self rowForSection:newSection];
        range               = NSMakeRange(begin, toSection.count);
        indexSet            = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView removeRowsAtIndexes:indexSet withAnimation:opt];
        
        // 插入
        [self.sections insertObject:fromSection atIndex:newSection];
        range               = NSMakeRange(begin, fromSection.count);
        indexSet            = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView insertRowsAtIndexes:indexSet withAnimation:opt];
    }
}

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(NSTableViewAnimationOptions)animation
{
    for (NSIndexPath *indexPath in indexPaths) {
        
        NSMutableArray <KKTableViewRowModel *>*section =
        [self.sections objectAtIndex:indexPath.section];
        
        [section insertObject:[KKTableViewRowModel row] atIndex:(section.firstObject.isHeader ? 1 : 0)];
        
        NSInteger row = [self rowForIndexPath:indexPath];
        
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:animation];
    }
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(NSTableViewAnimationOptions)animation
{
    for (NSIndexPath *indexPath in indexPaths) {
        
        NSMutableArray <KKTableViewRowModel *>*section =
        [self.sections objectAtIndex:indexPath.section];
        
        NSInteger row = [self rowForIndexPath:indexPath];
        
        [section removeObjectAtIndex:(section.firstObject.isHeader ? 1 : 0)];
        
        [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:animation];
    }
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(NSTableViewAnimationOptions)animation
{
    for (NSIndexPath *indexPath in indexPaths) {
        
        NSInteger row = [self rowForIndexPath:indexPath];
        
        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:self.columnIndexSet];
    }
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    NSInteger row       = [self rowForIndexPath:indexPath];
    NSInteger newRow    = [self rowForIndexPath:newIndexPath];
    
    NSMutableArray <KKTableViewRowModel *>*section =
    [self.sections objectAtIndex:indexPath.section];
    [section removeObjectAtIndex:(section.firstObject.isHeader ? 1 : 0)];
    
    NSMutableArray <KKTableViewRowModel *>*newSection =
    [self.sections objectAtIndex:newIndexPath.section];
    [newSection insertObject:[KKTableViewRowModel row] atIndex:(newSection.firstObject.isHeader ? 1 : 0)];
    
    [self.tableView moveRowAtIndex:row toIndex:newRow];
}

- (void)insertSection:(NSInteger)section withRowAnimation:(NSTableViewAnimationOptions)animation
{
    [self insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
}

- (void)deleteSection:(NSInteger)section withRowAnimation:(NSTableViewAnimationOptions)animation
{
    [self deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
}

- (void)reloadSection:(NSInteger)section withRowAnimation:(NSTableViewAnimationOptions)animation
{
    [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
}

- (void)insertRowsAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(NSTableViewAnimationOptions)animation
{
    if (indexPath == nil) {
        return;
    }
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)deleteRowsAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(NSTableViewAnimationOptions)animation
{
    if (indexPath == nil) {
        return;
    }
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)reloadRowsAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(NSTableViewAnimationOptions)animation
{
    if (indexPath == nil) {
        return;
    }
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)noteHeightOfRowWithIndexPathChanged:(NSIndexPath *)indexPath
{
    NSInteger row           = [self rowForIndexPath:indexPath];
    NSIndexSet *indexSet    = [NSIndexSet indexSetWithIndex:row];
    [self.tableView noteHeightOfRowsWithIndexesChanged:indexSet];
}

- (void)noteHeightOfHeaderWithSectionChanged:(NSInteger)section
{
    NSIndexPath *indexPath  = [NSIndexPath indexPathForRow:KKTableViewHeaderTag inSection:section];
    NSInteger row           = [self rowForIndexPath:indexPath];
    NSIndexSet *indexSet    = [NSIndexSet indexSetWithIndex:row];
    [self.tableView noteHeightOfRowsWithIndexesChanged:indexSet];
}

- (void)noteHeightOfFooterWithSectionChanged:(NSInteger)section
{
    NSIndexPath *indexPath  = [NSIndexPath indexPathForRow:KKTableViewFooterTag inSection:section];
    NSInteger row           = [self rowForIndexPath:indexPath];
    NSIndexSet *indexSet    = [NSIndexSet indexSetWithIndex:row];
    [self.tableView noteHeightOfRowsWithIndexesChanged:indexSet];
}

#pragma mark 注册Class
- (void)registerClass:(Class)cellClass forIdentifier:(NSString *)identifier
{
    [self.cellClassMap setValue:cellClass forKey:identifier];
}

#pragma mark 注册Nib
- (void)registerNib:(NSNib *)nib forIdentifier:(NSString *)identifier
{
    [self.tableView registerNib:nib forIdentifier:identifier];
}

#pragma mark 获取NSTableView上的此row映射的IndexPath
- (NSIndexPath *)indexPathForRow:(NSInteger)row
{
    NSInteger sectionCount  = self.sections.count;
    NSInteger remainingRows = row;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        // 减去当前Section的行数，减到为负数为止
        NSArray <KKTableViewRowModel *>*rowModels = [self.sections objectAtIndex:section];
        NSInteger diff      = remainingRows - rowModels.count;
        // 为负数，代表Row在这个Section
        if (diff < 0) {
            NSInteger indexPathRow = 0;
            // 假如剩余行数等于这个section的行数-1，就代表是最后一行footer
            if (rowModels.lastObject.isFooter && remainingRows == rowModels.count - 1) {
                indexPathRow = KKTableViewFooterTag;
            } else if (rowModels.firstObject.isHeader) {
                indexPathRow = remainingRows - 1;
            } else {
                indexPathRow = remainingRows;
            }
            return [NSIndexPath indexPathForRow:indexPathRow inSection:section];
        }
        remainingRows = diff;
    }
    return nil;
}

#pragma mark 获取此Section的起始行
- (NSInteger)rowForSection:(NSInteger)section
{
    if (section <= 0) {
        return 0;
    }
    NSInteger row = 0;
    for (NSInteger i = 0; i < section; i++) {
        NSArray *rows = [self.sections objectAtIndex:i];
        row = row + rows.count;
    }
    return row;
}

#pragma mark 获取此IndexPath在NSTableView上的row
- (NSInteger)rowForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < 0 || indexPath.section >= self.sections.count) {
        return NSNotFound;
    }
    NSInteger row = indexPath.row;
    for (NSInteger section = 0;section < indexPath.section; section++) {
        row = row + [self.sections objectAtIndex:section].count;
    }
    NSArray <KKTableViewRowModel *>*rows = [self.sections objectAtIndex:indexPath.section];
    if (indexPath.row == KKTableViewFooterTag) {
        row = row + labs(KKTableViewFooterTag);
    } else if (rows.firstObject.isHeader) {
        row = row + labs(KKTableViewHeaderTag);
    }
    return row;
}

#pragma mark 取出Model
- (KKTableViewRowModel *)rowModelForRow:(NSInteger)row
{
    if (row < 0) {
        return nil;
    }
    NSInteger sectionCount  = self.sections.count;
    NSInteger remainingRows = row;
    for (NSInteger section = 0; section < sectionCount; section++) {
        // 减去当前Section的行数，减到为负数为止
        NSArray <KKTableViewRowModel *>*rowModels = [self.sections objectAtIndex:section];
        NSInteger diff      = remainingRows - rowModels.count;
        // 为负数，代表Row在这个Section
        if (diff < 0) {
            return [rowModels objectAtIndex:remainingRows];
        }
        remainingRows = diff;
    }
    return nil;
}

#pragma mark 此Section有页眉
- (BOOL)hasHeaderInSection:(NSInteger)section
{
    if (![self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)] &&
        ![self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.delegate tableView:self heightForHeaderInSection:section] > 0;
    }
    if ([self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [self.dataSource tableView:self titleForHeaderInSection:section] ? YES : NO;
    }
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.delegate tableView:self viewForHeaderInSection:section] ? YES : NO;
    }
    return NO;
}

#pragma mark 此Section有页尾
- (BOOL)hasFooterInSection:(NSInteger)section
{
    if (![self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)] &&
        ![self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.delegate tableView:self heightForFooterInSection:section] > 0;
    }
    if ([self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        return [self.dataSource tableView:self titleForFooterInSection:section] ? YES : NO;
    }
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.delegate tableView:self viewForFooterInSection:section] ? YES : NO;
    }
    return NO;
}

#pragma mark 可见Cell
- (NSArray<__kindof NSView *> *)visibleCells
{
    NSRect rect             = self.documentVisibleRect;
    NSRange range           = [self.tableView rowsInRect:rect];
    NSMutableArray *list    = [NSMutableArray array];
    NSInteger endIndex      = range.location + range.length;
    for (NSInteger i = range.location; i < endIndex; i++) {
        NSView *cell        =
        [self.tableView viewAtColumn:0 row:i makeIfNecessary:NO];
        if (cell) {
            [list addObject:cell];
        }
    }
    return list;
}

#pragma mark 可见IndexPath
- (NSArray<NSIndexPath *> *)indexPathsForVisibleRows
{
    NSRect rect             = self.documentVisibleRect;
    NSRange range           = [self.tableView rowsInRect:rect];
    NSMutableArray *list    = [NSMutableArray array];
    NSInteger endIndex      = range.location + range.length;
    for (NSInteger i = range.location; i < endIndex; i++) {
        if ([self.tableView viewAtColumn:0 row:i makeIfNecessary:NO]) {
            [list addObject:[self indexPathForRow:i]];
        }
    }
    return list;
}

- (void)setAllowsSelection:(BOOL)allowsSelection
{
    _allowsSelection = allowsSelection;
    if (self.tableView.numberOfSelectedRows > 0) {
        [self.tableView deselectAll:nil];
    }
}

- (void)setAllowsEmptySelection:(BOOL)allowsEmptySelection
{
    self.tableView.allowsEmptySelection = allowsEmptySelection;
}

- (BOOL)allowsEmptySelection
{
    return self.tableView.allowsEmptySelection;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    self.tableView.allowsMultipleSelection = allowsMultipleSelection;
}

- (BOOL)allowsMultipleSelection
{
    return self.tableView.allowsMultipleSelection;
}

- (NSInteger)numberOfSelectedRows
{
    return self.tableView.numberOfSelectedRows;
}

- (NSIndexPath *)indexPathForSelectedRow
{
    if (self.numberOfSelectedRows == 0) {
        return nil;
    }
    return [self indexPathForRow:self.tableView.selectedRow];
}

- (NSArray<NSIndexPath *> *)indexPathsForSelectedRows
{
    if (self.numberOfSelectedRows == 0) {
        return nil;
    }
    NSIndexSet *indexSet = self.tableView.selectedRowIndexes;
    NSMutableArray *indexPaths = NSMutableArray.new;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[self indexPathForRow:idx]];
    }];
    return indexPaths;
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index         = [self rowForIndexPath:indexPath];
    NSIndexSet *indexSet    = [NSIndexSet indexSetWithIndex:index];
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(KKScrollViewScrollPosition)scrollPosition
{
    [self selectRowAtIndexPath:indexPath];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(KKScrollViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    [self cellForRowAtIndexPath:indexPath];
    NSTableRowView *view = [self rowViewForRowAtIndexPath:indexPath];
    [self scrollToRect:view.frame atScrollPosition:scrollPosition animated:animated];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [self rowForIndexPath:indexPath];
    [self.tableView deselectRow:index];
}

#pragma mark - 列表、字典
- (NSMutableArray<NSMutableArray<KKTableViewRowModel *> *> *)sections
{
    if (_sections == nil) {
        _sections = [NSMutableArray array];
    }
    return _sections;
}

- (NSMutableDictionary<NSString *,Class> *)cellClassMap
{
    if (_cellClassMap == nil) {
        _cellClassMap = [NSMutableDictionary dictionary];
    }
    return _cellClassMap;
}

@end
