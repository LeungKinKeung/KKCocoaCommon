//
//  KKTableViewCell.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKTableViewCell.h"
#import "KKTableView.h"

NSNotificationName const KKTableViewCellHeightDidChangeNotification = @"KKTableViewCellHeightDidChangeNotification";

@interface KKTableViewCell ()

@property (nonatomic, strong) NSImageView *accessoryImageView;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) BOOL usesCustomSeparatorInset;
@property (nonatomic, readonly) KKTableView *kktableView;
@property (nonatomic, readonly) NSTableRowView *tableRowView;
@end

@implementation KKTableViewCell
{
    NSImageView *_imageView;
    NSTextField *_textLabel;
    NSTextField *_detailTextLabel;
    NSImageView *_accessoryImageView;
}
@dynamic imageView;

- (instancetype)initWithStyle:(KKTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self init];
    if (self) {
        self.style      = style;
        self.identifier = reuseIdentifier;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.wantsLayer     = YES;
    _separatorInset     = NSEdgeInsetsMake(0, 0, 0, 0);
    _interitemSpacing   = 10;
    _lineSpacing        = 5;
    _contentInsets      = NSEdgeInsetsMake(10, 15, 10, 15);
}

- (void)enableObserveRowView:(BOOL)enable
{
    for (NSString *keypath in @[@"superview.selected"]) {
        [self addObserver:self forKeyPath:keypath options:0 context:nil];
    }
}

- (void)enableObserveImageView:(BOOL)enable
{
    for (NSString *keypath in @[@"imageView.image"]) {
        if (enable) {
            [self addObserver:self forKeyPath:keypath options:0 context:nil];
        } else {
            [self removeObserver:self forKeyPath:keypath];
        }
    }
}

- (void)enableObserveAccessoryImageView:(BOOL)enable
{
    for (NSString *keypath in @[@"accessoryImageView.image"]) {
        if (enable) {
            [self addObserver:self forKeyPath:keypath options:0 context:nil];
        } else {
            [self removeObserver:self forKeyPath:keypath];
        }
    }
}

- (void)enableObserveTextLabel:(BOOL)enable
{
    for (NSString *keypath in @[@"textLabel.stringValue", @"textLabel.attributedStringValue", @"textLabel.font"]) {
        if (enable) {
            [self addObserver:self forKeyPath:keypath options:0 context:nil];
        } else {
            [self removeObserver:self forKeyPath:keypath];
        }
    }
}

- (void)enableObserveDetailTextLabel:(BOOL)enable
{
    for (NSString *keypath in @[@"detailTextLabel.stringValue", @"detailTextLabel.attributedStringValue", @"detailTextLabel.font"]) {
        if (enable) {
            [self addObserver:self forKeyPath:keypath options:0 context:nil];
        } else {
            [self removeObserver:self forKeyPath:keypath];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"superview.selected"]) {
        [self selectionDidChange];
    } else {
        CGFloat rowHeight = self.rowHeight;
        [self layoutCellSubviews];
        if (rowHeight != self.rowHeight) {
            [self noteHeightChanged];
        }
    }
}

- (void)viewWillDraw
{
    [super viewWillDraw];
    if (self.inLiveResize) {
        return;
    }
    if (self.rowHeight > 0 && self.frame.size.height != self.rowHeight) {
        [self noteHeightChanged];
    }
}

- (void)viewDidEndLiveResize
{
    [super viewDidEndLiveResize];
    
    if (self.rowHeight > 0 && self.frame.size.height != self.rowHeight) {
        [self noteHeightChanged];
    }
}

- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    if ([self.superview isKindOfClass:[NSTableRowView class]]) {
        [self enableObserveRowView:YES];
    }
}

- (void)removeFromSuperview
{
    if ([self.superview isKindOfClass:[NSTableRowView class]]) {
        [self enableObserveRowView:NO];
    }
    [super removeFromSuperview];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    if (_textLabel == nil) {
        _textLabel = [super textField];
    }
    [self setNeedsLayout:YES];
}

- (void)setImageView:(NSImageView *)imageView
{
    if (self.style == KKTableViewCellStyleValue2){
        return;
    }
    if (_imageView) {
        [self enableObserveImageView:NO];
        [_imageView removeFromSuperview];
    }
    _imageView = imageView;
    if (_imageView) {
        [self addSubview:_imageView];
        [self enableObserveImageView:YES];
    }
}

- (NSImageView *)imageView
{
    if (self.style == KKTableViewCellStyleValue2){
        return nil;
    }
    if (_imageView == nil) {
        _imageView  = [self standardImageView];
        [self addSubview:_imageView];
        [self enableObserveImageView:YES];
    }
    return _imageView;
}

- (void)setTextLabel:(NSTextField *)textLabel
{
    if (_textLabel) {
        [self enableObserveTextLabel:NO];
        [_textLabel removeFromSuperview];
    }
    _textLabel = textLabel;
    if (_textLabel) {
        [self addSubview:_textLabel];
        [self enableObserveTextLabel:YES];
    }
}

- (NSTextField *)textLabel
{
    if (_textLabel == nil) {
        _textLabel  = [self standardLabel];
        [self addSubview:_textLabel];
        [self enableObserveTextLabel:YES];
    }
    return _textLabel;
}

- (void)setDetailTextLabel:(NSTextField *)detailTextLabel
{
    if (self.style != KKTableViewCellStyleValue1 &&
        self.style != KKTableViewCellStyleValue2 &&
        self.style != KKTableViewCellStyleSubtitle){
        return;
    }
    if (_detailTextLabel) {
        [self enableObserveDetailTextLabel:NO];
        [_detailTextLabel removeFromSuperview];
    }
    _detailTextLabel = detailTextLabel;
    if (_textLabel) {
        [self addSubview:_detailTextLabel];
        [self enableObserveDetailTextLabel:YES];
    }
}

- (NSTextField *)detailTextLabel
{
    if (self.style != KKTableViewCellStyleValue1 &&
        self.style != KKTableViewCellStyleValue2 &&
        self.style != KKTableViewCellStyleSubtitle){
        return nil;
    }
    if (_detailTextLabel == nil) {
        _detailTextLabel            = [self standardLabel];
        [self addSubview:_detailTextLabel];
        [self enableObserveDetailTextLabel:YES];
    }
    return _detailTextLabel;
}

- (NSImageView *)accessoryImageView
{
    if (_accessoryImageView == nil) {
        _accessoryImageView = [self standardImageView];
        [self addSubview:_accessoryImageView];
        [self enableObserveAccessoryImageView:YES];
    }
    return _accessoryImageView;
}

- (void)setAccessoryView:(NSView *)accessoryView
{
    if (_accessoryView) {
        [_accessoryView removeFromSuperview];
    }
    _accessoryView = accessoryView;
    [self addSubview:accessoryView];
}

- (NSTextField *)standardLabel
{
    NSTextField *label      = [NSTextField new];
    label.font              = [NSFont systemFontOfSize:16];
    label.editable          = NO;
    label.selectable        = NO;
    label.bordered          = NO;
    label.drawsBackground   = NO;
    label.backgroundColor   = [NSColor clearColor];
    label.focusRingType     = NSFocusRingTypeNone;
    label.bezelStyle        = NSTextFieldSquareBezel;
    label.lineBreakMode     = NSLineBreakByWordWrapping;
    label.cell.scrollable   = NO;
    label.wantsLayer        = YES;
    label.layer.backgroundColor = [NSColor clearColor].CGColor;
    return label;
}

- (NSImageView *)standardImageView
{
    NSImageView *view       = [NSImageView new];
    view.imageScaling       = NSImageScaleNone;
    view.imageFrameStyle    = NSImageFrameNone;
    view.editable           = NO;
    view.animates           = NO;
    view.allowsCutCopyPaste = NO;
    return view;
}

- (void)setStyle:(KKTableViewCellStyle)style
{
    _style = style;
    
    if (style == KKTableViewCellStyleValue1 ||
        style == KKTableViewCellStyleValue2 ||
        style == KKTableViewCellStyleSubtitle) {
        if (self.detailTextLabel.superview == nil) {
            [self addSubview:self.detailTextLabel];
        }
    } else if (_detailTextLabel && _detailTextLabel.superview) {
        [_detailTextLabel removeFromSuperview];
    }
    self.textLabel.alignment =
    style == KKTableViewCellStyleValue2 ?
    NSTextAlignmentRight :
    NSTextAlignmentLeft;
    
    self.detailTextLabel.alignment =
    style == KKTableViewCellStyleValue1 ?
    NSTextAlignmentRight :
    NSTextAlignmentLeft;
    
    _interitemSpacing =
    style == KKTableViewCellStyleValue2 ? 5 : 10;
    
    switch (style) {
        case KKTableViewCellStyleValue1: {
            self.detailTextLabel.alphaValue = 0.8;
            self.detailTextLabel.font       = [NSFont systemFontOfSize:16];
            break;
        }
        case KKTableViewCellStyleValue2: {
            self.detailTextLabel.alphaValue = 1;
            self.detailTextLabel.font       = [NSFont systemFontOfSize:16];
            break;
        }
        case KKTableViewCellStyleSubtitle: {
            self.detailTextLabel.alphaValue = 1;
            self.detailTextLabel.font       = [NSFont systemFontOfSize:14];
            break;
        }
        case KKTableViewCellStylePlain: {
            self.textLabel.font             = [NSFont boldSystemFontOfSize:16];
            break;
        }
        case KKTableViewCellStyleGrouped: {
            self.textLabel.alphaValue       = 0.8;
            break;
        }
        default: {
            
            break;
        }
    }
}

- (void)layout
{
    [super layout];
    [self layoutCellSubviews];
}

- (void)layoutCellSubviews
{
    CGSize selfSize             = self.frame.size;
    CGFloat interitemSpacing    = self.interitemSpacing;
    CGFloat lineSpacing         = self.lineSpacing;
    NSEdgeInsets insets         = self.contentInsets;
    
    CGRect imageViewFrame       = CGRectZero;
    CGRect textLabelFrame       = CGRectZero;
    CGRect detailLabelFrame     = CGRectZero;
    CGRect accessoryViewFrame   = CGRectZero;
    
    if (self.style != KKTableViewCellStyleValue2 && _imageView) {
        imageViewFrame.size     = [self.imageView intrinsicContentSize];
        imageViewFrame.origin.x = insets.left;
        insets.left             = insets.left + imageViewFrame.size.width + interitemSpacing;
    }
    if (self.accessoryView) {
        accessoryViewFrame.size = [self.accessoryView intrinsicContentSize];
        accessoryViewFrame.origin.x = selfSize.width - accessoryViewFrame.size.width - insets.right;
        insets.right            = insets.right + accessoryViewFrame.size.width + interitemSpacing;
    }
    
    BOOL hasTextLabel           = _textLabel && self.textLabel.stringValue.length > 0;
    BOOL hasDetailLabel         = _detailTextLabel && self.detailTextLabel.stringValue.length > 0;
    CGFloat availableWidth      = selfSize.width - insets.left - insets.right;
    CGFloat maxViewHeight       = MAX(imageViewFrame.size.height, accessoryViewFrame.size.height);
    CGSize fits                 = CGSizeMake(availableWidth, FLT_MAX);
    
    // 计算宽度高度X轴坐标
    if (self.style == KKTableViewCellStyleValue1 && hasTextLabel && hasDetailLabel) {
        // 左右
        textLabelFrame.size     = [self.textLabel sizeThatFits:fits];
        detailLabelFrame.size   = [self.detailTextLabel sizeThatFits:fits];
        if ((textLabelFrame.size.width + detailLabelFrame.size.width) > availableWidth) {
            // 两个Label宽度的和超过可用宽度，变为各占50%
            availableWidth          = (selfSize.width - insets.left - insets.right) * 0.5;
            fits                    = CGSizeMake(availableWidth, FLT_MAX);
            textLabelFrame.size     = [self.textLabel sizeThatFits:fits];
            detailLabelFrame.size   = [self.detailTextLabel sizeThatFits:fits];
        }
        textLabelFrame.origin.x     = insets.left;
        detailLabelFrame.origin.x   = selfSize.width - detailLabelFrame.size.width - insets.right;
        maxViewHeight               = MAX(maxViewHeight, textLabelFrame.size.height);
        maxViewHeight               = MAX(maxViewHeight, detailLabelFrame.size.height);
        
    } else if (self.style == KKTableViewCellStyleValue2) {
        // 左0.3，右0.7，强制有detailTextLabel
        availableWidth          = availableWidth - interitemSpacing;
        CGFloat textLabelWidth  = availableWidth * 0.3;
        textLabelFrame.size     = [self.textLabel sizeThatFits:CGSizeMake(textLabelWidth, FLT_MAX)];
        detailLabelFrame.size   = [self.detailTextLabel sizeThatFits:CGSizeMake(availableWidth * 0.7, FLT_MAX)];
        maxViewHeight               = MAX(maxViewHeight, textLabelFrame.size.height);
        maxViewHeight               = MAX(maxViewHeight, detailLabelFrame.size.height);
        textLabelFrame.origin.x     = insets.left;
        detailLabelFrame.origin.x   = insets.left + textLabelWidth + interitemSpacing;
        
    } else if (hasTextLabel && hasDetailLabel) {
        // 上下
        textLabelFrame.size     = [self.textLabel sizeThatFits:fits];
        detailLabelFrame.size   = [self.detailTextLabel sizeThatFits:fits];
        CGFloat totalHeight     = textLabelFrame.size.height + detailLabelFrame.size.height + lineSpacing;
        maxViewHeight           = MAX(maxViewHeight, totalHeight);
        textLabelFrame.origin.x     = insets.left;
        detailLabelFrame.origin.x   = insets.left;
        
    } else if (hasTextLabel) {
        textLabelFrame.size         = [self.textLabel sizeThatFits:fits];
        maxViewHeight               = MAX(maxViewHeight, textLabelFrame.size.height);
        textLabelFrame.origin.x     = insets.left;
        
    } else if (hasDetailLabel && self.style == KKTableViewCellStyleValue1) {
        detailLabelFrame.size       = [self.detailTextLabel sizeThatFits:fits];
        maxViewHeight               = MAX(maxViewHeight, detailLabelFrame.size.height);
        detailLabelFrame.origin.x   = selfSize.width - detailLabelFrame.size.width - insets.right;
    } else if (hasDetailLabel) {
        detailLabelFrame.size       = [self.detailTextLabel sizeThatFits:fits];
        maxViewHeight               = MAX(maxViewHeight, detailLabelFrame.size.height);
        detailLabelFrame.origin.x   = insets.left;
    }
    
    CGFloat rowHeight   = 0;
    if (self.usesAutomaticRowHeights) {
        rowHeight       = maxViewHeight + insets.top + insets.bottom;
    } else {
        rowHeight       = selfSize.height;
    }
    
    // 计算Y轴坐标
    if (CGRectIsEmpty(imageViewFrame) == NO) {
        imageViewFrame.origin.y     = (rowHeight - imageViewFrame.size.height) * 0.5;
        self.imageView.frame        = imageViewFrame;
    }
    if (CGRectIsEmpty(accessoryViewFrame) == NO) {
        accessoryViewFrame.origin.y = (rowHeight - accessoryViewFrame.size.height) * 0.5;
        self.accessoryView.frame    = accessoryViewFrame;
    }
    if (self.style == KKTableViewCellStyleValue1 && hasTextLabel && hasDetailLabel) {
        textLabelFrame.origin.y     = (rowHeight - textLabelFrame.size.height) * 0.5;
        detailLabelFrame.origin.y   = (rowHeight - detailLabelFrame.size.height) * 0.5;
    } else if (self.style == KKTableViewCellStyleValue2) {
        textLabelFrame.origin.y     = (rowHeight - textLabelFrame.size.height) * 0.5;
        detailLabelFrame.origin.y   = (rowHeight - detailLabelFrame.size.height) * 0.5;
    } else if (hasTextLabel && hasDetailLabel) {
        CGFloat totalHeight         = textLabelFrame.size.height + detailLabelFrame.size.height + lineSpacing;
        if (self.usesAutomaticRowHeights) {
            if (self.isFlipped) {
                textLabelFrame.origin.y     = insets.top;
                detailLabelFrame.origin.y   = insets.top + textLabelFrame.size.height + lineSpacing;
            } else {
                detailLabelFrame.origin.y   = insets.bottom;
                textLabelFrame.origin.y     = insets.bottom + detailLabelFrame.size.height + lineSpacing;
            }
        } else {
            if (totalHeight > rowHeight) {
                lineSpacing         = MAX(0, rowHeight - (totalHeight - lineSpacing));
                totalHeight         = textLabelFrame.size.height + detailLabelFrame.size.height + lineSpacing;
            }
            CGFloat beginY                  = (rowHeight - totalHeight) * 0.5;
            if (self.isFlipped) {
                textLabelFrame.origin.y     = beginY;
                detailLabelFrame.origin.y   = beginY + textLabelFrame.size.height + lineSpacing;
            } else {
                detailLabelFrame.origin.y   = beginY;
                textLabelFrame.origin.y     = beginY + detailLabelFrame.size.height + lineSpacing;
            }
        }
    } else if (hasTextLabel) {
        textLabelFrame.origin.y     = (rowHeight - textLabelFrame.size.height) * 0.5;
    } else if (hasDetailLabel) {
        detailLabelFrame.origin.y   = (rowHeight - detailLabelFrame.size.height) * 0.5;
    }
    if (self.usesCustomSeparatorInset == NO) {
        _separatorInset             = NSEdgeInsetsMake(0, insets.left, 0, 0);
    }
    if (CGRectIsEmpty(textLabelFrame) == NO) {
        self.textLabel.frame        = textLabelFrame;
    }
    if (CGRectIsEmpty(detailLabelFrame) == NO) {
        self.detailTextLabel.frame  = detailLabelFrame;
    }
    self.rowHeight  = rowHeight;
}

- (NSSize)intrinsicContentSize
{
    NSSize size = [super intrinsicContentSize];
    if (size.height > 0) {
        return size;
    }
    return CGSizeMake(self.superview.frame.size.width, self.rowHeight);
}

- (void)setAccessoryType:(KKTableViewCellAccessoryType)accessoryType
{
    if (_accessoryType == accessoryType) {
        return;
    }
    _accessoryType = accessoryType;
    
    if (accessoryType == KKTableViewCellAccessoryNone) {
        if (_accessoryImageView.superview){
            [_accessoryImageView removeFromSuperview];
        }
    } else {
        if (self.accessoryView != self.accessoryImageView) {
            self.accessoryView = self.accessoryImageView;
        }
    }
    
    switch (accessoryType) {
        case KKTableViewCellAccessoryDisclosureIndicator: {
            self.accessoryImageView.image = [NSImage imageNamed:NSImageNameGoRightTemplate];
            break;
        }
        case KKTableViewCellAccessoryCheckmark: {
            self.accessoryImageView.image = [NSImage imageNamed:NSImageNameMenuOnStateTemplate];
            break;
        }
        default: {
            if (_accessoryImageView) {
                _accessoryImageView.image = nil;
            }
            break;
        }
    }
}

- (void)setContentInsets:(NSEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self setNeedsLayout:YES];
}

- (void)setSeparatorInset:(NSEdgeInsets)separatorInset
{
    _separatorInset = separatorInset;
    [self setUsesCustomSeparatorInset:YES];
    [self setNeedsDisplay:YES];
}

- (void)setReuseIdentifier:(NSString *)reuseIdentifier
{
    self.identifier = reuseIdentifier;
}

- (NSString *)reuseIdentifier
{
    return self.identifier;
}

- (void)selectionDidChange
{
    
}

- (void)setSelected:(BOOL)selected
{
    [self.tableRowView setSelected:selected];
}

- (BOOL)isSelected
{
    return self.tableRowView.isSelected;
}

- (KKTableView *)kktableView
{
    NSView *view = self.superview;
    for (NSInteger i = 0; i < 50; i++) {
        view = view.superview;
        if ([view isKindOfClass:[KKTableView class]]) {
            return (KKTableView *)view;
        }
    }
    return nil;
}

- (NSTableRowView *)tableRowView
{
    NSTableRowView *rowView = (NSTableRowView *)self.superview;
    if ([rowView isKindOfClass:[NSTableRowView class]]) {
        return rowView;
    }
    return nil;
}

- (void)noteHeightChanged
{
    if (self.usesAutomaticRowHeights == NO) {
        return;
    }
    [self.kktableView beginUpdates];
    [self.kktableView noteHeightOfRowWithCellChanged:self height:self.rowHeight];
    [self.kktableView endUpdates];
}

- (BOOL)usesAutomaticRowHeights
{
    KKTableView *tableView  = self.kktableView;
    NSIndexPath *indexPath  = [tableView indexPathForCell:self];
    if (indexPath.row == KKTableViewHeaderTag) {
        return tableView.usesAutomaticHeaderHeights;
    } else if (indexPath.row == KKTableViewFooterTag) {
        return tableView.usesAutomaticFooterHeights;
    } else {
        return tableView.usesAutomaticRowHeights;
    }
}

- (void)dealloc
{
    if (_imageView) {
        [self enableObserveImageView:NO];
        _imageView = nil;
    }
    if (_textLabel) {
        [self enableObserveTextLabel:NO];
        _textLabel = nil;
    }
    if (_detailTextLabel) {
        [self enableObserveDetailTextLabel:NO];
        _detailTextLabel = nil;
    }
    if (_accessoryImageView) {
        [self enableObserveAccessoryImageView:NO];
        _accessoryImageView = nil;
    }
    if (self.superview && [self.superview isKindOfClass:[NSTableRowView class]]) {
        [self enableObserveRowView:NO];
    }
}

@end
