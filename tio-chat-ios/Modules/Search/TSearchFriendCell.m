//
//  TSearchFriendCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSearchFriendCell.h"
/// pods
#import "FrameAccessor.h"
/// common
#import "UIImageView+Web.h"
#import "NSString+T_HTTP.h"
#import "NSMutableAttributedString+T_Replace.h"

@interface TSearchFriendCell ()
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

@implementation TSearchFriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        UIImageView *avatarView = [UIImageView.alloc initWithFrame:CGRectMake(16, 0, 40, 40)];
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
        self.nickLabel.frame = CGRectMake(72, self.avatarView.y + 1, self.contentView.width - 36 - 72, 22);
        self.remarkLabel.frame = CGRectMake(72, self.nickLabel.bottom, self.nickLabel.width, 17);
    } else {
        self.nickLabel.frame = CGRectMake(72, self.avatarView.y + 1, self.contentView.width - 36 - 72, 22);
        self.nickLabel.centerY = self.contentView.middleY;
    }
    [self.nickLabel sizeToFit];
    self.flag.centerY = self.nickLabel.centerY;
    self.flag.left = self.nickLabel.right+5;
}
-(UIImageView *)flag{
    if (!_flag) {
        _flag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        _flag.image = [UIImage imageNamed:@"Group 1321315481"];
        _flag.hidden = true;
        [self.contentView addSubview:_flag];
    }
    return _flag;
}
- (void)refreshAvatar:(NSString *)avatar nick:(NSString *)nick remark:(NSString *)remark key:(NSString *)key
{
    self.remark = remark;
    self.remarkLabel.hidden = !remark.length;
    /// 加载网络头像
    [self.avatarView tio_imageUrl:avatar.resourceURLString placeHolderImageName:@"avatar_placeholder" radius:4];
    
    /// 处理关键字富文本
    TAttributedString *node = [TAttributedString.alloc init];
    node.text = key;
    node.attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHex:0x4C94FF]};
    
    NSMutableAttributedString *nickAttributedString = [NSMutableAttributedString.alloc initWithString:nick attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.nickLabel.attributedText = [nickAttributedString replaceAttributesWithStrings:@[node]];
    
    if (remark.length) {
        // 备注中的关键字
        TAttributedString *remarknode = [TAttributedString.alloc init];
        remarknode.text = key;
        remarknode.attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor colorWithHex:0x4C94FF]};
        
        NSMutableAttributedString *reamrkAttributedString = [NSMutableAttributedString.alloc initWithString:remark attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor colorWithHex:0x999999]}];
        
        self.remarkLabel.attributedText = [reamrkAttributedString replaceAttributesWithStrings:@[remarknode]];
    }
}

@end
