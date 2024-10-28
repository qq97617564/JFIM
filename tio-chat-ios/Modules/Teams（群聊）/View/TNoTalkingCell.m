//
//  TNoTalkingCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/6.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TNoTalkingCell.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"
#import "NSString+T_Time.h"

@interface TNoTalkingCell ()
@property (copy,    nonatomic) NSString *nick;
@property (copy,    nonatomic) NSString *remark;
@end

@implementation TNoTalkingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *avatarImageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self.contentView addSubview:avatarImageView];
        self.avatarView = avatarImageView;
        
        UILabel *nameLabel = [UILabel.alloc init];
        nameLabel.textColor = [UIColor colorWithHex:0x333333];
        nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UILabel *remarkLabel = [UILabel.alloc init];
        remarkLabel.textColor = [UIColor colorWithHex:0x999999];
        remarkLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:remarkLabel];
        self.remarkLabel = remarkLabel;
        
        UILabel *timeLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 63, 26)];
        timeLabel.textColor = [UIColor colorWithHex:0x4C94FF];
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.backgroundColor = [UIColor colorWithHex:0xEBF3FF];
        timeLabel.layer.cornerRadius = 2;
        timeLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
    }
    return self;
}
-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(0, 0, 78, 31);
        [_cancelBtn setTitle:@"取消禁言" forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        _cancelBtn.backgroundColor = [UIColor colorWithHex:0xF3F2F7];
        [_cancelBtn setTitleColor:[UIColor colorWithHex:0x0087FC] forState:UIControlStateNormal];
        _cancelBtn.layer.cornerRadius = 6;
    }
    return _cancelBtn;
}
-(UIImageView *)flagImg{
    if (!_flagImg) {
        UIImageView *flag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        flag.image = [UIImage imageNamed:@"Group 1321315481"];
        [self.contentView addSubview:flag];
        flag.hidden = true;
        _flagImg = flag;
    }
    return _flagImg;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.centerY = self.contentView.middleY;
    self.avatarView.left = 16;
    
    // 群昵称和原始名称是否一致
    if (![self.remark isEqualToString:self.nick]) {
        // 优先显示备注名
        self.nameLabel.text = self.remark;
        [self.nameLabel sizeToFit];
        self.nameLabel.left = 70;
        if (self.nameLabel.width > self.contentView.width*0.6) self.nameLabel.width = self.contentView.width*0.6;
        self.nameLabel.top = self.avatarView.top;
        
        // 备注地方显示昵称
        self.remarkLabel.text = [NSString stringWithFormat:@"昵称：%@",self.nick];
        [self.remarkLabel sizeToFit];
        self.remarkLabel.left = 70;
        if (self.remarkLabel.width > self.contentView.width*0.6) self.remarkLabel.width = self.contentView.width*0.6;
        self.remarkLabel.bottom = self.avatarView.bottom;
    } else {
        self.nameLabel.text = self.nick;
        [self.nameLabel sizeToFit];
        self.nameLabel.left = 70;
        if (self.nameLabel.width > self.contentView.width*0.6) self.nameLabel.width = self.contentView.width*0.6;
        self.nameLabel.centerY = self.contentView.middleY;
    }
    self.flagImg.left = self.nameLabel.centerY;
    self.flagImg.centerY = self.nameLabel.right+5;
    self.timeLabel.centerY = self.contentView.middleY;
    self.timeLabel.right = self.contentView.width - 16;
    self.cancelBtn.right = self.contentView.width-15;
    self.cancelBtn.centerY = self.contentView.middleY;

}

- (void)updateAvatar:(NSString *)avatar nick:(NSString *)nick remark:(NSString *)remark flag:(BOOL)flag time:(NSTimeInterval)seconds forever:(BOOL)forever
{
    [self.avatarView tio_imageUrl:avatar placeHolderImageName:@"placeholder_head" radius:4];
    self.nick = nick;
    self.remark = remark;
    self.flagImg.hidden = !flag;
    if (!forever) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@",[NSString transferToLengthFromSeconds:seconds]];
    } else {
        self.timeLabel.text = @"长期禁言";
    }
}

@end
