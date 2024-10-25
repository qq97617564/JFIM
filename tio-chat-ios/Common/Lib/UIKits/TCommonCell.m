//
//  TCommonCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCommonCell.h"
#import "FrameAccessor.h"

@interface TCommonCell ()
@property (nonatomic, weak) UIImageView *indiractor;
@end

@implementation TCommonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textLabel.textColor = [UIColor colorWithHex:0x111111];
        self.textLabel.font = [UIFont systemFontOfSize:16];
        
        self.detailTextLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        
        UIImageView *indiractor = [UIImageView.alloc initWithFrame:CGRectZero];
        indiractor.image = [UIImage imageNamed:@"inner"];
        [self.contentView addSubview:indiractor];
        self.indiractor = indiractor;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.textLabel sizeToFit];
    [self.detailTextLabel sizeToFit];
    
    if (self.imageView.image) {
        self.textLabel.left = self.imageView.right + 10;
    } else {
        self.textLabel.left = 16;
    }
    
    self.textLabel.centerY = self.contentView.middleY;
    
    if (self.hasIndiractor) {
        self.indiractor.hidden = NO;
        [self.indiractor sizeToFit];
        self.indiractor.right = self.contentView.width - 16;
        self.indiractor.centerY = self.contentView.middleY;
        
        CGFloat maxDetailWidth = self.indiractor.left - 6 - self.textLabel.right - 6;
        
        if (self.detailTextLabel.width > maxDetailWidth) {
            self.detailTextLabel.width = maxDetailWidth;
        }
        self.detailTextLabel.right = self.indiractor.left - 6;
        self.detailTextLabel.centerY = self.contentView.middleY;
    } else {
        self.indiractor.hidden = YES;
        
        CGFloat maxDetailWidth = self.contentView.width - 16 - self.textLabel.right - 6;
        
        if (self.detailTextLabel.width > maxDetailWidth) {
            self.detailTextLabel.width = maxDetailWidth;
        }
        self.detailTextLabel.right = self.contentView.width - 16;
        self.detailTextLabel.centerY = self.contentView.middleY;
    }
    
    if (self.detailView) {
        if (!self.detailView.superview) {
            [self.contentView addSubview:self.detailView];
        }
        self.detailView.centerY = self.contentView.middleY;
        if (self.hasIndiractor) {
            self.detailView.right = self.indiractor.left;
        } else {
            self.detailView.right = self.contentView.width;
        }
    }
}

///// 去除group时的cell分割线
//- (void)addSubview:(UIView *)view
//{
//    if ([view isKindOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) {
//        return;
//    }
//    
//    [super addSubview:view];
//}
@end
