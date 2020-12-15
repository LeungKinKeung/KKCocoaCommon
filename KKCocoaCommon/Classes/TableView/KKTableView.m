//
//  KKTableView.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKTableView.h"
#import <CoreGraphics/CoreGraphics.h>

const CGFloat KKTableViewAutomaticDimension     = 25.0;
const NSInteger KKTableViewHeaderTag            = -1;
const NSInteger KKTableViewFooterTag            = -2;
const NSInteger KKTableHeaderViewTag            = -3;
const NSInteger KKTableFooterViewTag            = -4;

static NSString *const KKTableRowViewIdentifier     = @"KKTableRowViewIdentifier";
static NSString *const KKTableViewHeaderIdentifier  = @"KKTableViewHeaderIdentifier";
static NSString *const KKTableViewFooterIdentifier  = @"KKTableViewFooterIdentifier";
static NSPasteboardType const KKTableViewDragAndDropDataType = @"KKTableViewDragAndDropDataType";

#pragma mark - KKTableViewSection
@interface KKTableViewRowModel : NSObject
@property (nonatomic, assign) BOOL isHeader;
@property (nonatomic, assign) BOOL isFooter;
@property (nonatomic, assign) CGFloat height;
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

@property (nonatomic, weak) KKTableView *tableView;
@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, strong) NSIndexPath *rowIndexPath;
@property (nonatomic, strong) NSImageView *checkmarkImageView;
@property (nonatomic, strong) NSImageView *sortingImageView;
@property (nonatomic, readonly) NSTableCellView *tableCellView;
@property (nonatomic, readonly) KKTableViewCell *kktableViewCell;
@property (nonatomic, readonly) NSColor *selectionBackgroundColor;
@property (nonatomic, readonly) NSArray *selectionBackgroundCGColors;
@property (nonatomic, readonly) NSImageRep *selectionBackgroundImageRep;
@property (nonatomic, readonly) BOOL alwaysEmphasizedSelectionBackground;
@property (nonatomic, assign, getter=isFloatingRowStyle) BOOL floatingRowStyle;

@end

@implementation KKTableRowView

- (void)layout
{
    [super layout];
    [self layoutRowViewSubviews];
}

- (void)layoutRowViewSubviews
{
    NSTableCellView *cell   = self.tableCellView;
    
    if (self.tableView.selectionStyle != KKTableViewSelectionStyleCheckmark ||
        self.rowIndexPath.row < 0) {
        if (_checkmarkImageView && _checkmarkImageView.isHidden == NO) {
            _checkmarkImageView.hidden = YES;
        }
    }
    
    // 显示选择状态图标的样式
    if (self.tableView.selectionStyle == KKTableViewSelectionStyleCheckmark &&
        self.tableView.allowsSelection == YES &&
        self.rowIndexPath.row >= 0) {
        if (self.checkmarkImageView.isHidden) {
            self.checkmarkImageView.hidden = NO;
        }
        CGFloat spacing     = 20;
        CGSize imageSize    = [self.checkmarkImageView intrinsicContentSize];
        CGRect imageFrame   = CGRectMake(spacing, (self.bounds.size.height - imageSize.height) * 0.5, imageSize.width, imageSize.height);
        self.checkmarkImageView.frame = imageFrame;
        CGFloat cellMinX    = CGRectGetMaxX(imageFrame) + spacing;
        cell.frame          = CGRectMake(cellMinX, 0, self.bounds.size.width - cellMinX, self.bounds.size.height);
        return;
    }
    
    // 排序中
    if (self.tableView.sortStyle == KKTableViewSortStyleDisplaySortImage) {
        if (self.rowIndexPath.row < 0) {
            if (_sortingImageView.isHidden == NO){
                _sortingImageView.hidden = YES;
            }
        } else {
            if (_sortingImageView.isHidden){
                _sortingImageView.hidden = NO;
            }
            CGFloat spacing     = 20;
            CGSize imageSize    = [self.sortingImageView intrinsicContentSize];
            CGFloat cellWidth   = self.bounds.size.width - spacing * 2 - imageSize.width;
            CGRect imageFrame   = CGRectMake(cellWidth + spacing, (self.bounds.size.height - imageSize.height) * 0.5, imageSize.width, imageSize.height);
            self.sortingImageView.frame = imageFrame;
            cell.frame          = CGRectMake(0, 0, cellWidth, self.bounds.size.height);
            return;
        }
    } else {
        [_sortingImageView removeFromSuperview];
        _sortingImageView = nil;
    }
    
    // 默认
    cell.frame          = self.bounds;
}

- (void)updateSelectionImageIfNeeded
{
    if (self.tableView.selectionStyle != KKTableViewSelectionStyleCheckmark ||
        self.tableView.allowsSelection == NO) {
        if (_checkmarkImageView) {
            [_checkmarkImageView removeFromSuperview];
            _checkmarkImageView = nil;
            [self layoutRowViewSubviews];
        }
        return;
    }
    NSImageView *imageView  = self.checkmarkImageView;
    CGSize imageSize        = [imageView intrinsicContentSize];
    imageView.image         = self.isSelected ? self.tableView.selectedImage : self.tableView.unselectedImage;
    
    if (CGSizeEqualToSize(imageSize, [imageView intrinsicContentSize]) == NO) {
        [self layoutRowViewSubviews];
    }
}

- (NSImageView *)checkmarkImageView
{
    if (_checkmarkImageView == nil) {
        _checkmarkImageView = [NSImageView new];
        [self addSubview:_checkmarkImageView];
    }
    return _checkmarkImageView;
}

- (NSImageView *)sortingImageView
{
    if (_sortingImageView == nil) {
        _sortingImageView = [NSImageView new];
        _sortingImageView.image = self.tableView.sortingImage;
        [self addSubview:_sortingImageView];
    }
    return _sortingImageView;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (self.tableView.selectionStyle == KKTableViewSelectionStyleCheckmark && self.tableView.allowsSelection) {
        self.checkmarkImageView.image = self.isSelected ? self.tableView.selectedImage : self.tableView.unselectedImage;
    }
}

- (BOOL)isGroupRowStyle
{
    return self.isFloating || self.isFloatingRowStyle;
}

- (NSTableCellView *)tableCellView
{
    NSArray *subViews = self.subviews;
    for (NSView *subview in subViews) {
        if ([subview isKindOfClass:[NSTableCellView class]]) {
            return (NSTableCellView *)subview;
        }
    }
    return nil;
}

- (KKTableViewCell *)kktableViewCell
{
    KKTableViewCell *cell = (KKTableViewCell *)self.tableCellView;
    if ([cell isKindOfClass:[KKTableViewCell class]]) {
        return cell;
    }
    return nil;
}

- (void)setNextRowSelected:(BOOL)nextRowSelected
{
    [super setNextRowSelected:nextRowSelected];
    if (self.tableView.separatorStyle != KKTableViewCellSeparatorStyleNone) {
        [self setNeedsDisplay:YES];
    }
}

- (void)drawSeparatorInRect:(NSRect)dirtyRect
{
    if (self.tableView.separatorStyle == KKTableViewCellSeparatorStyleNone) {
        return;
    }
    if (self.tableView.separatorColor == nil) {
        return;
    }
    if (self.isSelected) {
        return;
    }
    
    KKTableView *tableView  = self.tableView;
    NSIndexPath *indexPath  = self.rowIndexPath;
    if (indexPath.row < 0) {
        // header和footer不绘制
        return;
    }
    // 画线
    NSEdgeInsets separatorInset = NSEdgeInsetsZero;
    if (tableView.usesCustomSeparatorInset) {
        separatorInset = tableView.separatorInset;
    } else if (self.kktableViewCell) {
        separatorInset = self.kktableViewCell.separatorInset;
    }
    CGFloat lineWidth           = tableView.separatorLineWidth * 2;
    KKTableViewStyle isGrouped  = tableView.style == KKTableViewStyleGrouped;
    KKTableViewStyle isPlain    = isGrouped == NO;
    BOOL isFirstRow             = indexPath.row == 0;
    if (isGrouped && isFirstRow) {
        NSBezierPath *path  = [NSBezierPath bezierPath];
        CGFloat lineY       = self.superview.isFlipped ? 0 : dirtyRect.size.height;
        NSPoint beginPoint  = NSMakePoint(0, lineY);
        NSPoint endPoint    = NSMakePoint(dirtyRect.size.width - separatorInset.right, lineY);

        [path moveToPoint:beginPoint];
        [path lineToPoint:endPoint];
        [path setLineWidth:lineWidth];
        [tableView.separatorColor setStroke];
        [path stroke];
    }

    BOOL isLastRow = [tableView numberOfRowsInSection:indexPath.section] - 1 == indexPath.row;
    if (isPlain && isLastRow) {
        return;
    }
    if (self.isNextRowSelected) {
        return;
    }
    NSBezierPath *path  = [NSBezierPath bezierPath];
    CGFloat lineY       = self.superview.isFlipped ? dirtyRect.size.height : 0;
    NSPoint beginPoint  = NSMakePoint(isGrouped && isLastRow? 0 : separatorInset.left, lineY);
    NSPoint endPoint    = NSMakePoint(dirtyRect.size.width - separatorInset.right, lineY);

    [path moveToPoint:beginPoint];
    [path lineToPoint:endPoint];
    [path setLineWidth:lineWidth];
    [tableView.separatorColor setStroke];
    [path stroke];
}

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    if (self.selectionHighlightStyle == NSTableViewSelectionHighlightStyleNone) {
        return;
    }
    if (dirtyRect.size.height == 0 || dirtyRect.size.width == 0) {
        return;
    }
    if ((self.selectionBackgroundColor == nil &&
         self.selectionBackgroundCGColors == nil &&
         self.selectionBackgroundImageRep == nil) ||
        self.isEmphasized == NO) {
        [[self defaultBackgroundColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:dirtyRect];
        [path fill];
        return;
    }
    if (self.selectionBackgroundColor) {
        /// 纯色
        [self.selectionBackgroundColor setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:dirtyRect];
        [path fill];
    } else if (self.selectionBackgroundCGColors) {
        /// 渐变色
        CGContextRef context = [NSGraphicsContext currentContext].CGContext;
        CGContextSaveGState(context);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = { 0.0, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)self.selectionBackgroundCGColors, locations);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0.0), CGPointMake(dirtyRect.size.width, 0.0), 0);
        CGContextRestoreGState(context);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
    } else if (self.selectionBackgroundImageRep) {
        /// 图像
        NSImageRep *imageRep        = self.selectionBackgroundImageRep;
        CGFloat imageWidth          = imageRep.size.width;
        CGFloat imageHeight         = imageRep.size.height;
        if (imageHeight == 0) {
            return;
        }
        CGFloat imageAspectRatio    = imageWidth / imageHeight;
        CGFloat viewAspectRatio     = dirtyRect.size.width / dirtyRect.size.height;
        CGRect drawInRect           = CGRectZero;
        if (viewAspectRatio  > imageAspectRatio) {
            drawInRect.size.width     = dirtyRect.size.width;
            drawInRect.size.height    = drawInRect.size.width / imageAspectRatio;
            drawInRect.origin.y       = (dirtyRect.size.height - drawInRect.size.height) * 0.5;
        } else {
            drawInRect.size.height    = dirtyRect.size.height;
            drawInRect.size.width     = drawInRect.size.height * imageAspectRatio;
            drawInRect.origin.x       = (dirtyRect.size.height - drawInRect.size.width) * 0.5;
        }
        [imageRep drawInRect:drawInRect fromRect:CGRectMake(0, 0, imageWidth, imageHeight) operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:self.isFlipped hints:nil];
    }
}

- (NSColor *)defaultBackgroundColor
{
    if (@available(macOS 10.14, *)) {
        if (self.isEmphasized) {
            return NSColor.selectedContentBackgroundColor;
        } else {
            return NSColor.unemphasizedSelectedContentBackgroundColor;
        }
    } else {
        if (self.window.isKeyWindow) {
            return NSColor.alternateSelectedControlColor;
        } else {
            return NSColor.secondarySelectedControlColor;
        }
    }
}

- (BOOL)isEmphasized
{
    if (self.alwaysEmphasizedSelectionBackground) {
        return YES;
    }
    return [super isEmphasized];
}

- (NSBackgroundStyle)interiorBackgroundStyle
{
    if (self.tableView.interiorBackgroundStyle == KKTableViewInteriorBackgroundStyleDefault) {
        return [super interiorBackgroundStyle];
    }
    return NSBackgroundStyleNormal;
}

- (NSColor *)selectionBackgroundColor
{
    return self.tableView.selectionBackgroundColor;
}

- (NSArray *)selectionBackgroundCGColors
{
    return self.tableView.selectionBackgroundCGColors;
}

- (NSImageRep *)selectionBackgroundImageRep
{
    return self.tableView.selectionBackgroundImageRep;
}

- (BOOL)alwaysEmphasizedSelectionBackground
{
    return self.tableView.alwaysEmphasizedSelectionBackground;
}

@end

#pragma mark - KKTableView

@protocol KKPrivateTableViewDelegate <NSObject>
@required
- (BOOL)privateTableView:(NSTableView *)tableView mouseDown:(NSEvent *)event;
- (BOOL)privateTableView:(NSTableView *)tableView mouseDragged:(NSEvent *)event;
@end

@interface KKPrivateTableView : NSTableView
@property (nonatomic, weak) id<KKPrivateTableViewDelegate> privateDelegate;
@end

@implementation KKPrivateTableView

- (void)mouseDown:(NSEvent *)event
{
    if ([self.privateDelegate privateTableView:self mouseDown:event]) {
        [super mouseDown:event];
    }
}

- (void)mouseDragged:(NSEvent *)event
{
    if ([self.privateDelegate privateTableView:self mouseDragged:event]) {
        [super mouseDragged:event];
    }
}

@end


@interface KKTableView ()<NSTableViewDelegate, NSTableViewDataSource, KKPrivateTableViewDelegate>
{
    NSImage *_selectedImage;
    NSImage *_unselectedImage;
}
@property (nonatomic, strong) NSTableView *tableView;
@property (nonatomic, assign) KKTableViewStyle style;
@property (nonatomic, assign) BOOL usesAutomaticRowHeights;
@property (nonatomic, assign) BOOL usesAutomaticHeaderHeights;
@property (nonatomic, assign) BOOL usesAutomaticFooterHeights;
@property (nonatomic, assign, getter=isViewAppeared) BOOL viewAppeared;
@property (nonatomic, assign, getter=isTableViewDataLoaded) BOOL tableViewDataLoaded;
@property (nonatomic, assign) BOOL usesCachedRowModels;
@property (nonatomic, assign) BOOL hasUncommittedUpdates;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <KKTableViewRowModel *>*>*sections;
@property (nonatomic, strong) NSMutableDictionary <NSString *,Class>*cellClassMap;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic, strong) NSIndexSet *columnIndexSet;
@property (nonatomic, strong) NSArray *selectionBackgroundCGColors;
@property (nonatomic, strong) NSImageRep *selectionBackgroundImageRep;
@property (nonatomic, assign) BOOL usesCustomSeparatorInset;
@property (nonatomic, strong) NSIndexPath *deselectedIndexPath;
@property (nonatomic, strong) NSImage *preferredSelectedImage;
@property (nonatomic, strong) NSImage *preferredUnselectedImage;

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

- (void)layout
{
    [super layout];
    
    if (self.sortStyle != KKTableViewSortStyleNone) {
        self.tableView.tableColumns.firstObject.width = self.frame.size.width;
    }
}

- (NSTableView *)tableView
{
    if (_tableView == nil)
    {
        KKPrivateTableView *tableView = [[KKPrivateTableView alloc] init];
        _tableView                  = tableView;
        tableView.privateDelegate   = self;
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
        tableView.gridStyleMask     = NSTableViewSolidHorizontalGridLineMask;
        tableView.gridColor         = NSColor.clearColor;
        tableView.intercellSpacing  = NSMakeSize(0, 0);
        tableView.allowsEmptySelection      = YES;
        tableView.selectionHighlightStyle   = NSTableViewSelectionHighlightStyleRegular;
        
        self.hasVerticalScroller    = YES;
        self.hasHorizontalScroller  = NO;
        self.autohidesScrollers     = YES;
        self.scrollerStyle          = NSScrollerStyleOverlay;
        self.drawsBackground        = NO;
        self.verticalScrollElasticity       = NSScrollElasticityAllowed;
        self.automaticallyAdjustsContentInsets = NO;
        
        self.rowHeight                      =
        self.sectionHeaderHeight            =
        self.sectionFooterHeight            =
        self.estimatedRowHeight             =
        self.estimatedSectionHeaderHeight   =
        self.estimatedSectionFooterHeight   = KKTableViewAutomaticDimension;
        self.columnIndexSet                 = [NSIndexSet indexSetWithIndex:0];
        _allowsSelection                    = YES;
        
        _separatorStyle         = KKTableViewCellSeparatorStyleSingleLine;
        _separatorColor         = [NSColor colorWithWhite:0.5 alpha:0.5];
        _separatorInset         = NSEdgeInsetsMake(0, 0, 0, 0);
        _separatorLineWidth     = 0.5;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemColorsDidChangeNotification:) name:NSSystemColorsDidChangeNotification object:nil];
        
        [tableView registerForDraggedTypes:@[KKTableViewDragAndDropDataType]];
    }
    return _tableView;
}

/*
#pragma mark 将要绘制（重绘）
- (void)viewWillDraw
{
    [super viewWillDraw];
    if (self.isViewAppeared) {
        return;
    }
    self.viewAppeared = YES;
    self.tableView.selectionHighlightStyle =
    self.isTranslucent ?
    NSTableViewSelectionHighlightStyleSourceList :
    NSTableViewSelectionHighlightStyleRegular;
 
    [self reloadData];
}
 */

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    
    // 已添加到窗口表示已显示
    self.viewAppeared = YES;
    
    // 假如不刷新一下可能会导致行高不正常
    [self reloadData];
    
    if (self.solidBackgroundColor) {
        self.solidBackgroundColor = self.solidBackgroundColor;
    }
}

- (void)scrollPoint:(NSPoint)point
{
    [super scrollPoint:point];
    [self.contentView scrollPoint:point];
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

- (void)setTableHeaderView:(NSView *)tableHeaderView
{
    if (_tableHeaderView == nil && tableHeaderView == nil) {
        return;
    }
    BOOL existed        = _tableHeaderView != nil;
    _tableHeaderView    = tableHeaderView;
    if (self.isTableViewDataLoaded == NO) {
        return;
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    if (existed && tableHeaderView) {
        // 重载
        [self.tableView reloadDataForRowIndexes:indexSet columnIndexes:self.columnIndexSet];
    } if (existed == NO && tableHeaderView) {
        // 插入
        [self beginUpdates];
        [self.tableView insertRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationSlideUp];
        [self endUpdates];
    } else {
        // 移除
        [self beginUpdates];
        [self.tableView removeRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationSlideDown];
        [self endUpdates];
    }
}

- (void)setTableFooterView:(NSView *)tableFooterView
{
    if (_tableFooterView == nil && tableFooterView == nil) {
        return;
    }
    BOOL existed        = _tableFooterView != nil;
    _tableFooterView    = tableFooterView;
    if (self.isTableViewDataLoaded == NO) {
        return;
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self rowForTableFooterView]];
    if (existed && tableFooterView) {
        // 重载
        [self.tableView reloadDataForRowIndexes:indexSet columnIndexes:self.columnIndexSet];
    } if (existed == NO && tableFooterView) {
        // 插入
        [self beginUpdates];
        [self.tableView insertRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationEffectNone];
        [self endUpdates];
    } else {
        // 移除
        [self beginUpdates];
        [self.tableView removeRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationEffectNone];
        [self endUpdates];
    }
}

- (void)setTranslucent:(BOOL)translucent
{
    _translucent = translucent;
    
    if (self.sections.count > 0 && self.isTableViewDataLoaded) {
        self.usesCachedRowModels = YES;
    }
    
    self.tableView.selectionHighlightStyle =
    translucent ?
    NSTableViewSelectionHighlightStyleSourceList :
    NSTableViewSelectionHighlightStyleRegular;
}

- (void)setSolidBackgroundColor:(NSColor *)solidBackgroundColor
{
    _solidBackgroundColor = solidBackgroundColor;
    self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleSourceList;
    self.tableView.backgroundColor = solidBackgroundColor;
}

- (void)setSeparatorStyle:(KKTableViewCellSeparatorStyle)separatorStyle
{
    _separatorStyle = separatorStyle;
    [self redrawTableRowViews:NO];
}

- (void)setSeparatorColor:(NSColor *)separatorColor
{
    _separatorColor = separatorColor;
    [self redrawTableRowViews:NO];
}

- (void)setSeparatorInset:(NSEdgeInsets)separatorInset
{
    _separatorInset = separatorInset;
    [self setUsesCustomSeparatorInset:YES];
    [self redrawTableRowViews:NO];
}

- (void)setSeparatorLineWidth:(CGFloat)separatorLineWidth
{
    _separatorLineWidth = separatorLineWidth;
    [self redrawTableRowViews:NO];
}

- (void)redrawTableRowViews:(BOOL)flag
{
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        if (flag && rowView.isSelected == NO) {
            return;
        }
        [rowView setNeedsDisplay:YES];
    }];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    self.tableViewDataLoaded = YES;
    
    // 总的行计数
    NSInteger totalCount    = (self.tableHeaderView ? 1 : 0) + (self.tableFooterView ? 1 : 0);
    
    if (self.usesCachedRowModels) {
        for (NSArray *rows in self.sections) {
            totalCount += rows.count;
        }
        self.usesCachedRowModels = NO;
        return totalCount;
    }
    
    if (![self.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        return totalCount;
    }
    // 节数
    NSInteger sectionCount = 0;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sectionCount = [self.dataSource numberOfSectionsInTableView:self];
        if (sectionCount <= 0) {
            return totalCount;
        }
    } else {
        sectionCount = 1;
    }
    
    [self.sections removeAllObjects];
    
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
        view.tableView      = self;
    }
    if (self.style == KKTableViewStylePlain) {
        view.floatingRowStyle   = [self isHeaderForRow:row] || [self isFooterForRow:row];
    }
    view.rowIndex           = row;
    view.rowIndexPath       = [self indexPathForRow:row];
    return view;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    // Warning:如果KKTableView/NSTableView的视图为不可见或frame为{0,0,0,0}，此方法将不执行
    if ([self isTableHeaderViewForRow:row]) {
        return self.tableHeaderView;
    } else if ([self isTableFooterViewForRow:row]){
        return self.tableFooterView;
    }
    NSIndexPath *indexPath  = [self indexPathForRow:row];
    KKTableViewCell *cell   = nil;
    if ([self isHeaderForIndexPath:indexPath]) {
        // Header
        if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
            cell = (KKTableViewCell *)[self.delegate tableView:self viewForHeaderInSection:indexPath.section];
        } else if ([self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            NSString *title = [self.dataSource tableView:self titleForHeaderInSection:indexPath.section];
            cell = [self dequeueReusableCellWithIdentifier:KKTableViewHeaderIdentifier];
            cell.textLabel.stringValue = title ? title : @"";
        }
        
    } else if ([self isFooterForIndexPath:indexPath]) {
        // Footer
        if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
            cell = (KKTableViewCell *)[self.delegate tableView:self viewForFooterInSection:indexPath.section];
        } else if ([self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
            NSString *title = [self.dataSource tableView:self titleForFooterInSection:indexPath.section];
            cell = [self dequeueReusableCellWithIdentifier:KKTableViewFooterIdentifier];
            cell.textLabel.stringValue = title ? title : @"";
        }
        
    } else if ([self.dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        cell = (KKTableViewCell *)[self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - NSTableViewDelegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if ([self isTableHeaderViewForRow:row]) {
        return self.tableHeaderView.frame.size.height;
    } else if ([self isTableFooterViewForRow:row]) {
        return self.tableFooterView.frame.size.height;
    }
    
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

#pragma mark - 索引
- (BOOL)isHeaderForRow:(NSInteger)row
{
    if (row < 0) {
        return NO;
    }
    return [self isHeaderForIndexPath:[self indexPathForRow:row]];
}

- (BOOL)isFooterForRow:(NSInteger)row
{
    if (row >= self.tableView.numberOfRows) {
        return NO;
    }
    return [self isFooterForIndexPath:[self indexPathForRow:row]];
}

- (BOOL)isTableHeaderViewForRow:(NSInteger)row
{
    return self.tableHeaderView && row == 0;
}

- (BOOL)isTableFooterViewForRow:(NSInteger)row
{
    return self.tableFooterView && row == [self rowForTableFooterView];
}

- (BOOL)isHeaderForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == KKTableViewHeaderTag;
}

- (BOOL)isFooterForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == KKTableViewFooterTag;
}

- (BOOL)isRowForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row >= 0;
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
    if ([KKTableViewHeaderIdentifier isEqualToString:identifier] ||
        [KKTableViewFooterIdentifier isEqualToString:identifier]) {
        KKTableViewCellStyle style =
        self.style == KKTableViewStylePlain ?
        KKTableViewCellStylePlain :
        KKTableViewCellStyleGrouped;
        return [[KKTableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
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

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point
{
    NSInteger row   = [self.tableView rowAtPoint:point];
    return [self indexPathForRow:row];
}

- (NSIndexPath *)indexPathForCell:(NSView *)cell
{
    NSInteger row   = [self.tableView rowForView:cell];
    if (row == -1) {
        return nil;
    }
    return [self indexPathForRow:row];
}

- (NSArray<NSIndexPath *> *)indexPathsForRowsInRect:(CGRect)rect
{
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

- (NSInteger)numberOfSections
{
    return self.sections.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    NSArray <KKTableViewRowModel *>*rows = [self.sections objectAtIndex:section];
    NSInteger count = rows.count;
    if (rows.firstObject.isHeader) {
        count--;
    }
    if (rows.lastObject.isFooter) {
        count--;
    }
    return count;
}

- (CGRect)rectForHeaderInSection:(NSInteger)section
{
    NSInteger row = [self rowForSection:section];
    return [self.tableView rectOfRow:row];
}

- (CGRect)rectForFooterInSection:(NSInteger)section
{
    NSArray <KKTableViewRowModel *>*rows = [self.sections objectAtIndex:section];
    if (rows.lastObject.isFooter == NO) {
        return CGRectZero;
    }
    NSInteger headerIndex   = [self rowForSection:section];
    NSInteger footerIndex   = headerIndex + rows.count - 1;
    return [self.tableView rectOfRow:footerIndex];
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self rowForIndexPath:indexPath];
    return [self.tableView rectOfRow:row];
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
    if (section == newSection) {
        return;
    }
    
    BOOL isMoveFromTopToBottom      = section < newSection;
    NSInteger srcBeginRow           = [self rowForSection:section];
    NSInteger destBeginRow          = [self rowForSection:newSection];
    if (isMoveFromTopToBottom) {
        destBeginRow                = destBeginRow + [self.sections objectAtIndex:newSection].count;
    }
    NSMutableArray *rows            = [self.sections objectAtIndex:section];
    NSRange srcRowRange             = NSMakeRange(srcBeginRow, rows.count);
    NSIndexSet *rowIndexes          = [NSIndexSet indexSetWithIndexesInRange:srcRowRange];
    
    NSMutableArray *sections        = self.sections;
    [sections removeObjectAtIndex:section];
    [sections insertObject:rows atIndex:newSection];
    
    __block NSInteger srcOffset     = 0;
    __block NSInteger destOffset    = isMoveFromTopToBottom ? -1 : 0;
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger destinationRow    = destBeginRow + destOffset;
        if (isMoveFromTopToBottom) {
            NSLog(@"1.from:%ld   to:%ld",(idx - srcOffset),destinationRow);
            [self.tableView moveRowAtIndex:(idx - srcOffset) toIndex:destinationRow];
        } else {
            NSLog(@"2.from:%ld   to:%ld",idx,destinationRow);
            [self.tableView moveRowAtIndex:idx toIndex:destinationRow];
            destOffset++;
        }
        srcOffset++;
    }];
}

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(NSTableViewAnimationOptions)animation
{
    for (NSIndexPath *indexPath in indexPaths) {
        NSMutableArray <KKTableViewRowModel *>*section =
        [self.sections objectAtIndex:indexPath.section];
        NSInteger index = indexPath.row + (section.firstObject.isHeader ? 1 : 0);
        [section insertObject:[KKTableViewRowModel row] atIndex:index];
        NSInteger row   = [self rowForIndexPath:indexPath];
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:animation];
    }
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(NSTableViewAnimationOptions)animation
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in indexPaths) {
        NSMutableArray *rowModels       = [self.sections objectAtIndex:indexPath.section];
        NSInteger row                   = [self rowForIndexPath:indexPath];
        KKTableViewRowModel *firstRow   = rowModels.firstObject;
        NSInteger index                 = indexPath.row + (firstRow.isHeader ? 1 : 0);
        [rowModels replaceObjectAtIndex:index withObject:[NSNull null]];
        [indexSet addIndex:row];
    }
    for (NSIndexPath *indexPath in indexPaths) {
        NSMutableArray *rowModels       = [self.sections objectAtIndex:indexPath.section];
        [rowModels removeObject:[NSNull null]];
    }
    [self.tableView removeRowsAtIndexes:indexSet withAnimation:animation];
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(NSTableViewAnimationOptions)animation
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in indexPaths) {
        NSInteger row = [self rowForIndexPath:indexPath];
        [indexSet addIndex:row];
    }
    [self.tableView reloadDataForRowIndexes:indexSet columnIndexes:self.columnIndexSet];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    if (indexPath.section == newIndexPath.section &&
        indexPath.row == newIndexPath.row) {
        return;
    }
    NSInteger srcRow    = [self rowForIndexPath:indexPath];
    NSInteger destRow   = [self rowForIndexPath:newIndexPath];
    if (srcRow < destRow) {
        destRow--;
    }
    
    NSMutableArray <KKTableViewRowModel *>*srcRows =
    [self.sections objectAtIndex:indexPath.section];
    
    NSMutableArray <KKTableViewRowModel *>*destRows =
    [self.sections objectAtIndex:newIndexPath.section];
    
    NSInteger srcIndex  = indexPath.row + (srcRows.firstObject.isHeader ? 1 : 0);
    NSInteger destIndex = newIndexPath.row + (destRows.firstObject.isHeader ? 1 : 0);
    
    KKTableViewRowModel *rowModel = [srcRows objectAtIndex:srcIndex];
    [srcRows removeObjectAtIndex:srcIndex];
    [destRows insertObject:rowModel atIndex:destIndex];
    
    [self.tableView moveRowAtIndex:srcRow toIndex:destRow];
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

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(NSTableViewAnimationOptions)animation
{
    if (indexPath == nil) {
        return;
    }
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(NSTableViewAnimationOptions)animation
{
    if (indexPath == nil) {
        return;
    }
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(NSTableViewAnimationOptions)animation
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

- (void)noteHeightOfTableHeaderViewChanged
{
    NSIndexSet *indexSet    = [NSIndexSet indexSetWithIndex:0];
    [self.tableView noteHeightOfRowsWithIndexesChanged:indexSet];
}

- (void)noteHeightOfTableFooterViewChanged
{
    NSInteger index         = [self rowForTableFooterView];
    NSIndexSet *indexSet    = [NSIndexSet indexSetWithIndex:index];
    [self.tableView noteHeightOfRowsWithIndexesChanged:indexSet];
}

- (void)noteHeightOfRowWithCellChanged:(__kindof NSView *)cell height:(CGFloat)height
{
    NSInteger row       = [self.tableView rowForView:cell];
    KKTableViewRowModel *rowModel = [self rowModelForRow:row];
    if (rowModel.height == height) {
        return;
    }
    rowModel.height     = height;
    NSIndexSet *set     = [NSIndexSet indexSetWithIndex:row];
    [self.tableView noteHeightOfRowsWithIndexesChanged:set];
}

- (BOOL)isAutomaticRowHeight:(__kindof NSView *)cell
{
    NSIndexPath *indexPath  = [self indexPathForCell:self];
    if (indexPath.row == KKTableViewHeaderTag) {
        return self.usesAutomaticHeaderHeights;
    } else if (indexPath.row == KKTableViewFooterTag) {
        return self.usesAutomaticFooterHeights;
    } else {
        return self.usesAutomaticRowHeights;
    }
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
    if (row < 0 || row >= self.tableView.numberOfRows) {
        return nil;
    }
    if (self.tableHeaderView && row == 0) {
        return [NSIndexPath indexPathForRow:KKTableHeaderViewTag inSection:0];
    } else if (self.tableFooterView && row == [self rowForTableFooterView]) {
        return [NSIndexPath indexPathForRow:KKTableFooterViewTag inSection:0];
    }
    NSInteger sectionCount  = self.sections.count;
    NSInteger remainingRows = row - (self.tableHeaderView ? 1 : 0);
    
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
    NSInteger row = 0;
    if (section <= 0) {
        return 0;
    }
    for (NSInteger i = 0; i < section; i++) {
        NSArray *rows = [self.sections objectAtIndex:i];
        row = row + rows.count;
    }
    return row;
}

#pragma mark 获取此IndexPath在NSTableView上的row
- (NSInteger)rowForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == KKTableHeaderViewTag && self.tableHeaderView) {
        return 0;
    } else if (indexPath.row == KKTableFooterViewTag && self.tableFooterView) {
        return [self rowForTableFooterView];
    }
    if (indexPath.section < 0 || indexPath.section >= self.sections.count) {
        return NSNotFound;
    }
    NSInteger row = self.tableHeaderView ? 1 : 0;
    for (NSInteger section = 0;section < indexPath.section; section++) {
        row = row + [self.sections objectAtIndex:section].count;
    }
    
    NSInteger numberOfRowsInSection         = [self numberOfRowsInSection:indexPath.section];
    NSArray <KKTableViewRowModel *>*rows    = [self.sections objectAtIndex:indexPath.section];
    
    if (indexPath.row >= 0) {
        // 假如不是header或footer，就加上索引值
        row = row + indexPath.row;
    }
    if (rows.firstObject.isHeader && indexPath.row != KKTableViewHeaderTag) {
        // 假如不是此secion的header，且此secion包含header，就偏移1个索引值
        row = row + 1;
    }
    if (indexPath.row == KKTableViewFooterTag) {
        // 假如是此secion的footer，就增加行数
        row = row + numberOfRowsInSection; // row + (numberOfRowsInSection - 1) + 1;
    }
    return row;
}

#pragma mark 获取页尾的索引
- (NSInteger)rowForTableFooterView
{
    NSInteger index = self.tableHeaderView ? 1 : 0;
    for (NSArray *rows in self.sections) {
        index       = index + rows.count;
    }
    return index;
}

#pragma mark 取出Model
- (KKTableViewRowModel *)rowModelForRow:(NSInteger)row
{
    if (row < 0) {
        return nil;
    }
    NSInteger sectionCount  = self.sections.count;
    NSInteger remainingRows = row - (self.tableHeaderView ? 1 : 0);
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

- (KKTableViewRowModel *)rowModelForIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray <KKTableViewRowModel *>*rowModels = [self.sections objectAtIndex:indexPath.section];
    if (indexPath.row == KKTableViewFooterTag) {
        return rowModels.lastObject;
    }
    if (indexPath.row == KKTableViewHeaderTag) {
        return rowModels.firstObject;
    }
    if (indexPath.row < 0) {
        // tableHeaderView/tableFooterView
        return nil;
    }
    NSInteger index = rowModels.firstObject.isHeader ? indexPath.row + 1 : indexPath.row;
    KKTableViewRowModel *rowModel = [rowModels objectAtIndex:index];
    return rowModel;
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
    NSRect rect = self.documentVisibleRect;
    return [self indexPathsForRowsInRect:rect];
}

#pragma mark - 选择
- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    if (proposedSelectionIndexes.count == 1) {
        NSIndexPath *indexPath = [self indexPathForRow:proposedSelectionIndexes.firstIndex];
        if ([self isHeaderForIndexPath:indexPath] &&
            [self.delegate respondsToSelector:@selector(tableView:didClickHeaderAtSection:)]) {
            [self.delegate tableView:self didClickHeaderAtSection:indexPath.section];
        }
        if ([self isFooterForIndexPath:indexPath] &&
            [self.delegate respondsToSelector:@selector(tableView:didClickFooterAtSection:)]) {
            [self.delegate tableView:self didClickFooterAtSection:indexPath.section];
        }
        if (indexPath.row < 0) {
            return tableView.selectedRowIndexes;
        }
    }
    
    if (self.allowsSelection == NO) {
        return nil;
    }
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [proposedSelectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isHeaderForRow:idx] || [self isFooterForRow:idx]) {
            // 移除header和footer
            return;
        }
        [indexSet addIndex:idx];
    }];
    
    if (self.allowsMultipleSelection && self.selectionStyle != KKTableViewSelectionStyleSystem) {
        [indexSet addIndexes:self.tableView.selectedRowIndexes];
    }
    
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowsAtIndexPaths:)]) {
        NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [indexPaths addObject:[self indexPathForRow:idx]];
        }];
        NSArray *newIndexPaths = [self.delegate tableView:self willSelectRowsAtIndexPaths:indexPaths];
        indexSet = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in newIndexPaths) {
            [indexSet addIndex:[self rowForIndexPath:indexPath]];
        }
    } else if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        NSIndexPath *newIndexPath =
        [self.delegate tableView:self willSelectRowAtIndexPath:[self indexPathForRow:indexSet.firstIndex]];
        indexSet = [NSMutableIndexSet indexSet];
        if (newIndexPath) {
            [indexSet addIndex:[self rowForIndexPath:newIndexPath]];
        }
    }
    return indexSet;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (notification.object != self.tableView) {
        return;
    }
    if (self.deselectedIndexPath) {
        NSIndexPath *indexPath      = self.deselectedIndexPath;
        self.deselectedIndexPath    = nil;
        if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
            [self.delegate tableView:self didDeselectRowAtIndexPath:indexPath];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.delegate tableView:self didSelectRowAtIndexPath:self.indexPathForSelectedRow];
        }
        if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowsAtIndexPaths:)]) {
            [self.delegate tableView:self didSelectRowsAtIndexPaths:self.indexPathsForSelectedRows];
        }
    }
}

- (BOOL)privateTableView:(NSTableView *)tableView mouseDown:(NSEvent *)event
{
    if (self.selectionStyle == KKTableViewSelectionStyleSystem) {
        return YES;
    }
    if (event.modifierFlags & NSEventModifierFlagShift) {
        return YES;
    }
    NSPoint globalLocation  = [event locationInWindow];
    NSPoint localLocation   = [tableView convertPoint:globalLocation fromView:nil];
    NSInteger clickedRow    = [tableView rowAtPoint:localLocation];
    if ([tableView.selectedRowIndexes containsIndex:clickedRow]) {
        if (tableView.allowsEmptySelection == NO && tableView.selectedRowIndexes.count == 1) {
            // 不能空选，目前已选了一个，所以不能取消这个已选的
            return YES;
        } else {
            NSIndexPath *indexPath          = [self indexPathForRow:clickedRow];
            if ([self.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
                self.deselectedIndexPath    = [self.delegate tableView:self willDeselectRowAtIndexPath:indexPath];
                if (self.deselectedIndexPath) {
                    NSInteger deselectIndex = [self rowForIndexPath:self.deselectedIndexPath];
                    [tableView deselectRow:deselectIndex];
                }
            } else {
                self.deselectedIndexPath    = indexPath;
                [tableView deselectRow:clickedRow];
            }
        }
        return NO;
    }
    return YES;
}

- (BOOL)privateTableView:(NSTableView *)tableView mouseDragged:(NSEvent *)event
{
    if (self.selectionStyle == KKTableViewSelectionStyleSystem) {
        return YES;
    }
    // 拖拽批量取消
    return [self privateTableView:tableView mouseDown:event];
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

- (void)selectRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in indexPaths) {
        NSInteger index         = [self rowForIndexPath:indexPath];
        [indexSet addIndex:index];
    }
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (void)selectAll
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSInteger numberOfRows = self.tableView.numberOfRows;
    for (NSInteger row = 0; row < numberOfRows; row++) {
        NSIndexPath *indexPath = [self indexPathForRow:row];
        if (indexPath.row >= 0) {
            [indexSet addIndex:row];
        }
    }
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
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

- (void)deselectAll
{
    [self.tableView deselectAll:nil];
}

#pragma mark 选择相关设置
- (void)setAllowsSelection:(BOOL)allowsSelection
{
    _allowsSelection = allowsSelection;
    if (allowsSelection == NO && self.tableView.numberOfSelectedRows > 0) {
        [self.tableView deselectAll:nil];
    }
    NSRange range = [self.tableView rowsInRect:[self.tableView visibleRect]];
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        KKTableRowView *tableRowView    = (KKTableRowView *)rowView;
        if (row < range.location || row > (range.location + range.length)) {
            [tableRowView updateSelectionImageIfNeeded];
            [tableRowView layoutRowViewSubviews];
        } else {
            [tableRowView updateSelectionImageIfNeeded];
            [tableRowView.animator layoutRowViewSubviews];
        }
    }];
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
- (void)setSelectionBackgroundColor:(NSColor *)selectionBackgroundColor
{
    _selectionBackgroundColor = selectionBackgroundColor;
    [self redrawTableRowViews:YES];
}

- (void)setSelectionBackgroundColors:(NSArray<NSColor *> *)selectionBackgroundColors
{
    _selectionBackgroundColors  = selectionBackgroundColors;
    NSMutableArray *cgcolors    = [NSMutableArray array];
    for (NSColor *color in self.selectionBackgroundColors) {
        id value = (__bridge id)color.CGColor;
        if (value) {
            [cgcolors addObject:value];
        }
    }
    self.selectionBackgroundCGColors = cgcolors;
    [self redrawTableRowViews:YES];
}

- (void)setSelectionBackgroundImage:(NSImage *)selectionBackgroundImage
{
    _selectionBackgroundImage           = selectionBackgroundImage;
    self.selectionBackgroundImageRep    = selectionBackgroundImage.representations.firstObject;
    [self redrawTableRowViews:YES];
}

- (void)setAlwaysEmphasizedSelectionBackground:(BOOL)alwaysEmphasizedSelectionBackground
{
    _alwaysEmphasizedSelectionBackground = alwaysEmphasizedSelectionBackground;
    [self redrawTableRowViews:YES];
}

- (void)setInteriorBackgroundStyle:(KKTableViewInteriorBackgroundStyle)interiorBackgroundStyle
{
    BOOL needsDisplay = _interiorBackgroundStyle != interiorBackgroundStyle;
    _interiorBackgroundStyle = interiorBackgroundStyle;
    if (needsDisplay) {
        [self redrawTableRowViews:YES];
    }
}

- (void)setSelectionStyle:(KKTableViewSelectionStyle)selectionStyle
{
    _selectionStyle = selectionStyle;
    NSRange range = [self.tableView rowsInRect:[self.tableView visibleRect]];
    if (selectionStyle == KKTableViewSelectionStyleCheckmark) {
        if (self.allowsSelection == NO) {
            return;
        }
        [self.tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
            KKTableRowView *tableRowView    = (KKTableRowView *)rowView;
            if (row < range.location || row > (range.location + range.length)) {
                [tableRowView updateSelectionImageIfNeeded];
                [tableRowView layoutRowViewSubviews];
            } else {
                [tableRowView updateSelectionImageIfNeeded];
                [tableRowView.animator layoutRowViewSubviews];
            }
        }];
    } else {
        [self.tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
            KKTableRowView *tableRowView    = (KKTableRowView *)rowView;
            [tableRowView updateSelectionImageIfNeeded];
        }];
    }
}

- (void)setSelectedImage:(NSImage *)selectedImage
{
    _selectedImage = selectedImage;
    [self updateTableRowViewsSelectionImageIfNeeded];
}

- (NSImage *)selectedImage
{
    if (_selectedImage == nil) {
        return self.preferredSelectedImage;
    }
    return _selectedImage;
}

- (void)setUnselectedImage:(NSImage *)unselectedImage
{
    _unselectedImage = unselectedImage;
    [self updateTableRowViewsSelectionImageIfNeeded];
}

- (NSImage *)unselectedImage
{
    if (_unselectedImage == nil) {
        return self.preferredUnselectedImage;
    }
    return _unselectedImage;
}

- (NSImage *)preferredSelectedImage
{
    if (_preferredSelectedImage == nil) {
        NSColor *backgroundColor = nil;
        if (@available(macOS 10.14, *)) {
            backgroundColor     = NSColor.selectedContentBackgroundColor;
        } else {
            backgroundColor     = NSColor.alternateSelectedControlColor;
        }
        _preferredSelectedImage =
        [NSImage kktableViewSelectedImageWithTintColor:NSColor.whiteColor
                                       backgroundColor:backgroundColor
                                                  size:CGSizeMake(20, 20)];
    }
    return _preferredSelectedImage;
}

- (NSImage *)preferredUnselectedImage
{
    if (_preferredUnselectedImage == nil) {
        NSColor *borderColor        = [NSColor colorWithWhite:0.5 alpha:1];
        _preferredUnselectedImage   =
        [NSImage kktableViewUnselectedImageWithBorderColor:borderColor
                                                 lineWidth:1
                                                      size:CGSizeMake(20, 20)];
    }
    return _preferredUnselectedImage;
}

- (void)systemColorsDidChangeNotification:(NSNotification *)noti
{
    if (self.selectionStyle != KKTableViewSelectionStyleCheckmark) {
        return;
    }
    if (_selectedImage == nil) {
        _preferredSelectedImage = nil;
        [self preferredSelectedImage];
    }
    if (_unselectedImage == nil) {
        _preferredUnselectedImage = nil;
        [self preferredUnselectedImage];
    }
    if (_selectedImage == nil || _unselectedImage == nil) {
        [self updateTableRowViewsSelectionImageIfNeeded];
    }
}

- (void)layoutTableRowViewSubviews
{
    NSRange range = [self.tableView rowsInRect:[self.tableView visibleRect]];
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        KKTableRowView *tableRowView = (KKTableRowView *)rowView;
        if (row < range.location || row > (range.location + range.length)) {
            [tableRowView layoutRowViewSubviews];
        } else {
            [tableRowView.animator layoutRowViewSubviews];
        }
    }];
}

- (void)updateTableRowViewsSelectionImageIfNeeded
{
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        KKTableRowView *tableRowView = (KKTableRowView *)rowView;
        [tableRowView updateSelectionImageIfNeeded];
    }];
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
    } else if ([self isRowForIndexPath:indexPath]){
        if ([self.delegate respondsToSelector:@selector(tableView:didDoubleClickRowAtIndexPath:)]) {
            [self.delegate tableView:self didDoubleClickRowAtIndexPath:indexPath];
        }
    }
}

#pragma mark 排序
- (void)setSortStyle:(KKTableViewSortStyle)sortStyle
{
    _sortStyle = sortStyle;
    if (sortStyle != KKTableViewSortStyleNone) {
        self.tableView.tableColumns.firstObject.width = self.frame.size.width;
    }
    [self layoutTableRowViewSubviews];
}

- (NSImage *)sortingImage
{
    if (_sortingImage == nil) {
        _sortingImage = [NSImage imageNamed:NSImageNameListViewTemplate];
    }
    return _sortingImage;
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    if (self.sortStyle == KKTableViewSortStyleNone) {
        return NO;
    }
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray array];
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[self indexPathForRow:idx]];
    }];
    if (rowIndexes.count == 1 && indexPaths.firstObject.row < 0) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)] &&
        [self.delegate tableView:self canMoveRowAtIndexPath:indexPaths.firstObject] == NO) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(tableView:canMoveRowsAtIndexPaths:)] &&
        [self.delegate tableView:self canMoveRowsAtIndexPaths:indexPaths] == NO) {
        return NO;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:@[KKTableViewDragAndDropDataType] owner:self];
    [pboard setData:data forType:KKTableViewDragAndDropDataType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    if (dropOperation != NSTableViewDropAbove) {
        // 不允许移到Cell上面（叠加态）,只能移到Cell之间
        return NSDragOperationNone;
    }
    NSIndexPath *indexPath = [self indexPathForRow:row];
    if (indexPath == nil) {
        // 最后一个不是cell的情况下就不允许
        NSIndexPath *lastIndexPath = [self indexPathForRow:(self.tableView.numberOfRows - 1)];
        if (lastIndexPath.row < 0) {
            return NSDragOperationNone;
        }
    } else if (row == 0) {
        // 不能放在tableHeaderView/header之上
        if ([self isTableHeaderViewForRow:row] || [self isHeaderForIndexPath:indexPath]) {
            return NSDragOperationNone;
        }
    } else {
        NSInteger previousRow = row - 1;
        // 不能放在tableFooterView之后
        if ([self isTableFooterViewForRow:previousRow]) {
            return NSDragOperationNone;
        }
        NSIndexPath *previousIndexPath = [self indexPathForRow:previousRow];
        // header和footer之间，允许
        if ([self isHeaderForIndexPath:previousIndexPath] && [self isFooterForIndexPath:indexPath]) {
            return NSDragOperationMove;
        }
        // 不能放在footer和header之间，不能放在footer和tableFooterView之间
        if (previousIndexPath.row < 0 && indexPath.row < 0) {
            return NSDragOperationNone;
        }
    }
    NSPasteboard *pasteboard    = [info draggingPasteboard];
    NSData *rowIndexesData      = [pasteboard dataForType:KKTableViewDragAndDropDataType];
    NSIndexSet *rowIndexes      = [NSKeyedUnarchiver unarchiveObjectWithData:rowIndexesData];
    if (rowIndexes.count <= 1) {
        // 不能放在自身的前面或自身的后面
        if (rowIndexes.firstIndex == row || (rowIndexes.firstIndex + 1) == row) {
            return NSDragOperationNone;
        }
        return NSDragOperationMove;
    }
    // 不能放在选中的多个Cell之间
    if (rowIndexes.firstIndex <= row && (rowIndexes.lastIndex + 1) >= row) {
        return NSDragOperationNone;
    }
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pasteboard    = [info draggingPasteboard];
    NSData *rowIndexesData      = [pasteboard dataForType:KKTableViewDragAndDropDataType];
    NSIndexSet *rowIndexes      = [NSKeyedUnarchiver unarchiveObjectWithData:rowIndexesData];
    BOOL isMoveFromTopToBottom  = rowIndexes.firstIndex < row;
    
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray array];
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[self indexPathForRow:idx]];
    }];
    
    NSInteger toSection             = 0;
    NSInteger toRow                 = 0;
    if (row > 0) {
        NSIndexPath *previous       = [self indexPathForRow:row - 1];
        if (previous.row >= 0) {
            toSection               = previous.section;
            toRow                   = previous.row + 1;
        } else {
            toSection               = [self indexPathForRow:row].section;
            toRow                   = 0;
        }
    }
    NSIndexPath *toIndexPath        = [NSIndexPath indexPathForRow:toRow inSection:toSection];
    
    // 取出Row Model，并替换成[NSNull null]
    NSMutableArray <KKTableViewRowModel *>*srcRows = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        NSMutableArray *rows            = [self.sections objectAtIndex:indexPath.section];
        KKTableViewRowModel *firstRow   = rows.firstObject;
        NSInteger index                 = firstRow.isHeader ? indexPath.row + 1 : indexPath.row;
        [srcRows addObject:[rows objectAtIndex:index]];
        [rows replaceObjectAtIndex:index withObject:[NSNull null]];
    }
    
    // 插入Row Model，并移除[NSNull null]
    NSMutableArray <KKTableViewRowModel *>*destRows = [self.sections objectAtIndex:toIndexPath.section];
    NSInteger beginIndex            = destRows.firstObject.isHeader ? (toIndexPath.row + 1) : toIndexPath.row;
    NSIndexSet *indexes             = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(beginIndex, srcRows.count)];
    [destRows insertObjects:srcRows atIndexes:indexes];
    
    for (NSIndexPath *indexPath in indexPaths) {
        NSMutableArray *rowModels   = [self.sections objectAtIndex:indexPath.section];
        [rowModels removeObject:[NSNull null]];
    }
    
    [self beginUpdates];
    
    __block NSInteger srcOffset     = 0;
    __block NSInteger destOffset    = isMoveFromTopToBottom ? -1 : 0;
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger destinationRow    = row + destOffset;
        if (isMoveFromTopToBottom) {
            [self.tableView moveRowAtIndex:(idx - srcOffset) toIndex:destinationRow];
        } else {
            [self.tableView moveRowAtIndex:idx toIndex:destinationRow];
            destOffset++;
        }
        srcOffset++;
    }];
    
    [self endUpdates];
    
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        KKTableRowView *tableRowView = (KKTableRowView *)rowView;
        if (tableRowView.rowIndex != row) {
            tableRowView.rowIndex       = row;
            tableRowView.rowIndexPath   = [self indexPathForRow:row];
            [rowView setNeedsDisplay:YES];
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
        [self.delegate tableView:self moveRowAtIndexPath:indexPaths.firstObject toIndexPath:toIndexPath];
    }
    if ([self.delegate respondsToSelector:@selector(tableView:moveRowsAtIndexPaths:toIndexPath:)]) {
        [self.delegate tableView:self moveRowsAtIndexPaths:indexPaths toIndexPath:toIndexPath];
    }
    
    return YES;
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

- (void)dealloc
{
    [self.tableView unregisterDraggedTypes];
}

@end


@implementation NSImage (KKTableView)

+ (NSImage *)kktableViewSelectedImageWithTintColor:(NSColor *)tintColor backgroundColor:(NSColor *)backgroundColor size:(CGSize)size
{
    NSImage *image =
    [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        [NSColor.clearColor setFill];
        [[NSBezierPath bezierPathWithRect:dstRect] fill];
        
        [backgroundColor setFill];
        [[NSBezierPath bezierPathWithOvalInRect:dstRect] fill];
        
        NSImage *onStateImage = [NSImage imageNamed:NSImageNameMenuOnStateTemplate];
        CGImageRef cgimage = [onStateImage CGImageForProposedRect:NULL context:nil hints:nil];
        CGContextRef ctx = [NSGraphicsContext currentContext].CGContext;
        CGContextSaveGState(ctx);
        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
        CGRect rect = CGRectMake(size.width * 0.25, size.height * 0.25, size.width * 0.5, size.height * 0.5);
        CGContextClipToMask(ctx, rect, cgimage);
        [tintColor setFill];
        CGContextFillRect(ctx, rect);
        CGContextRestoreGState(ctx);
        return YES;
    }];
    return image;
}

+ (NSImage *)kktableViewUnselectedImageWithBorderColor:(NSColor *)borderColor lineWidth:(CGFloat)lineWidth size:(CGSize)size
{
    NSImage *image =
    [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        [NSColor.clearColor setFill];
        [[NSBezierPath bezierPathWithRect:dstRect] fill];
        
        [borderColor setStroke];
        NSRect ovalRect     =
        CGRectMake(lineWidth * 0.5, lineWidth * 0.5, dstRect.size.width - lineWidth, dstRect.size.height - lineWidth);
        NSBezierPath *path  = [NSBezierPath bezierPathWithOvalInRect:ovalRect];
        path.lineWidth      = lineWidth;
        [path stroke];
        
        return YES;
    }];
    return image;
}

@end
