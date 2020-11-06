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
@property (nonatomic, assign, getter=isViewDidAppear) BOOL viewDidAppear;

@property (nonatomic, strong) NSMutableArray <NSMutableArray <KKTableViewRowModel *>*>*sections;
@property (nonatomic, strong) NSMutableDictionary <NSString *,Class>*cellClassMap;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;

@end

@implementation KKTableView

#pragma mark - 初始化
- (instancetype)initWithStyle:(KKTableViewStyle)style
{
    self = [super init];
    if (self) {
        self.style = style;
        [self tableView];
    }
    return self;
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewCellHeightDidChange:) name:KKTableViewCellHeightDidChangeNotification object:nil];
    }
    return _tableView;
}

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

- (void)viewWillDraw
{
    [super viewWillDraw];
    if (self.isViewDidAppear) {
        return;
    }
    self.viewDidAppear = YES;
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
    bool isHeader = [self isHeaderForRow:row];
    return isHeader;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
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
    BOOL isSelected = YES;
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        isSelected  = [self.delegate tableView:self willSelectRowAtIndexPath:indexPath];
    }
    if (isSelected) {
       self.lastSelectedIndexPath  = indexPath;
    }
    return YES;
}

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
    return [self cellForRowAtIndexPath:indexPath makeIfNecessary:YES];
}

- (__kindof NSView *)cellForRowAtIndexPath:(NSIndexPath *)indexPath makeIfNecessary:(BOOL)makeIfNecessary
{
    NSInteger row   = [self rowForIndexPath:indexPath];
    NSView *cell    = [self.tableView viewAtColumn:0 row:row makeIfNecessary:makeIfNecessary];
    return cell;
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
    if (self.isViewDidAppear == NO) {
        return;
    }
    [self.tableView reloadData];
}
- (void)beginUpdates
{
    [self.tableView beginUpdates];
}
- (void)endUpdates
{
    [self.tableView endUpdates];
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

#pragma mark 获取此IndexPath在NSTableView上的row
- (NSInteger)rowForIndexPath:(NSIndexPath *)indexPath
{
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
