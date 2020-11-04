//
//  KKTextCollectionViewCell.m
//  KKCocoaCommon
//
//  Created by leungkinkeung on 2020/11/1.
//

#import "KKTextCollectionViewCell.h"
#import "NSTextField+KK.h"

@interface KKTextCollectionViewCell ()

@end

@implementation KKTextCollectionViewCell

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.wantsLayer            = YES;
    self.view.layer.backgroundColor = [self getBackgroundColor].CGColor;
    self.masksToCorners             = YES;
    {
        NSTextField *label  = [NSTextField label];
        label.text          = @"";
        label.font          = [NSFont systemFontOfSize:16.0];
        label.alignment     = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel     = label;
        [self.view addSubview:label];
    }
    {
        NSImageView *view       = [NSImageView new];
        self.accessoryImageView = view;
        [self.view addSubview:view];
    }
    for (NSString *keyPah in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPah options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (NSArray *)observableKeypaths
{
    return @[@"titleLabel.stringValue", @"titleLabel.attributedStringValue", @"titleLabel.font", @"accessoryImageView.image", @"view.effectiveAppearance"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"view.effectiveAppearance"]) {
        self.view.layer.backgroundColor = [self getBackgroundColor].CGColor;
    } else {
        [self.view setNeedsLayout:YES];
    }
}

- (NSColor *)getBackgroundColor
{
    if ([self.view.effectiveAppearance.name isEqualToString:NSAppearanceNameAqua]) {
        return NSColor.whiteColor;
    } else {
        return NSColor.blackColor;
    }
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    CGSize viewSize = self.view.frame.size;
    CGSize imageSize = [self.accessoryImageView intrinsicContentSize];
    self.accessoryImageView.frame =
    CGRectMake(viewSize.width - 16 - imageSize.width, (viewSize.height - imageSize.height) * 0.5, imageSize.width, imageSize.height);
    
    CGSize labelSize = [self.titleLabel sizeThatFits:CGSizeMake(CGRectGetMinX(self.accessoryImageView.frame) - 16, viewSize.height)];
    self.titleLabel.frame = CGRectMake(16, (viewSize.height - labelSize.height) * 0.5, labelSize.width, labelSize.height);
}

- (void)dealloc
{
    for (NSString *keyPah in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPah];
    }
}

@end
