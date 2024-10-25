//
//  TSearchTeamCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSearchTeamCell.h"
/// pods
#import "FrameAccessor.h"
/// common
#import "UIImageView+Web.h"
#import "NSString+T_HTTP.h"
#import "NSMutableAttributedString+T_Replace.h"


@interface TSearchTeamCell ()
@property (weak, nonatomic) UIImageView *avatarView;
@property (weak, nonatomic) UILabel *nickLabel;
@property (weak, nonatomic) UILabel *remarkLabel;

/// 头像URL
@property (copy, nonatomic) NSString *avatar;

/// 昵称
@property (copy, nonatomic) NSString *nick;

/// 备注
@property (copy, nonatomic) NSString *remark;
@end

@implementation TSearchTeamCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        UIImageView *avatarView = [UIImageView.alloc initWithFrame:CGRectMake(16, 0, 44, 44)];
        [self.contentView addSubview:avatarView];
        self.avatarView = avatarView;
        
        UILabel *nickLabel = [UILabel.alloc init];
        nickLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:nickLabel];
        self.nickLabel = nickLabel;
        
        UILabel *remarkLabel = [UILabel.alloc init];
        remarkLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:remarkLabel];
        self.remarkLabel = remarkLabel;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.centerY = self.contentView.middleY;
    
    if (self.remark.length) {
        self.nickLabel.frame = CGRectMake(72, self.avatarView.y + 2, self.contentView.width - 36 - 72, 22);
        self.remarkLabel.frame = CGRectMake(72, self.nickLabel.bottom, self.nickLabel.width, 17);
    } else {
        self.nickLabel.frame = CGRectMake(72, self.avatarView.y + 2, self.contentView.width - 36 - 72, 22);
        self.nickLabel.centerY = self.contentView.middleY;
    }
}

- (void)refreshAvatar:(NSString *)avatar nick:(NSString *)nick remark:(NSString *)remark key:(NSString *)key
{
    self.remark = remark;
    self.remarkLabel.hidden = !remark.length;
    /// 加载网络头像
    [self.avatarView tio_imageUrl:avatar.resourceURLString placeHolderImageName:@"avatar_placeholder" radius:7];
    
    /// 处理关键字富文本
    TAttributedString *node = [TAttributedString.alloc init];
    node.text = key;
    node.attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHex:0x4C94E8]};
    
    NSMutableAttributedString *nickAttributedString = [NSMutableAttributedString.alloc initWithString:nick attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.nickLabel.attributedText = [nickAttributedString replaceAttributesWithStrings:@[node]];
    
    
    NSMutableAttributedString *reamrkAttributedString = [NSMutableAttributedString.alloc initWithString:nick attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333]}];
    self.remarkLabel.attributedText = [reamrkAttributedString replaceAttributesWithStrings:@[node]];
    
}

@end
