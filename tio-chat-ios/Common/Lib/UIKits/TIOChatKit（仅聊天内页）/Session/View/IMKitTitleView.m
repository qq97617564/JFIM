//
//  CBIMTitleView.m
//  CawBar
//
//  Created by admin on 2019/11/6.
//

#import "IMKitTitleView.h"
#import "FrameAccessor.h"

@implementation IMKitTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;

        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:12.f];
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;

        [self addSubview:_titleLabel];
        [self addSubview:_subtitleLabel];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat margin = 80.f;
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - margin * 2;

    [self.titleLabel sizeToFit];
    CGSize titleSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(400, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;
    self.titleLabel.viewSize = titleSize;
    self.titleLabel.width = MIN(self.titleLabel.width, titleSize.width);
    
    [self.subtitleLabel sizeToFit];
    self.subtitleLabel.width = MIN(self.subtitleLabel.width, maxWidth);
    
    CGFloat width = MAX(self.titleLabel.width, self.subtitleLabel.width);
    return CGSizeMake(width, self.titleLabel.height + self.subtitleLabel.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.centerX = self.width * .5f;
    self.subtitleLabel.centerX = self.width * .5f;
    self.titleLabel.centerY = self.middleY;
}

- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits:CGSizeZero];
}

@end
