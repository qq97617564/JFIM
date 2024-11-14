//
//  TMemberCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TMemberCell.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@interface TMemberCell ()
@property (nonatomic, weak) UILabel *roleLabel;
//@property (nonatomic, weak) UILabel *markLabel;
@property (nonatomic, strong) UILabel *remarkLabel;// 备注
@property (weak, nonatomic) UIButton *selectButton;
@end

@implementation TMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithHex:0x333333];
        
        self.remarkLabel = [UILabel.alloc init];
        self.remarkLabel.font = [UIFont systemFontOfSize:14];
        self.remarkLabel.textColor = [UIColor colorWithHex:0x999999];
        [self.contentView addSubview:self.remarkLabel];
        
        UILabel *roleLabel = [UILabel.alloc init];
        roleLabel.font = [UIFont systemFontOfSize:12];
        roleLabel.textColor = [UIColor colorWithHex:0x999999];
        [self.contentView addSubview:roleLabel];
        self.roleLabel = roleLabel;
        
//        UILabel *markLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 20, 14)];
//        markLabel.font = [UIFont systemFontOfSize:12];
//        markLabel.textColor = [UIColor colorWithHex:0x999999];
//        markLabel.text = @"我";
//        [self.contentView addSubview:markLabel];
//        self.markLabel = markLabel;
        
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.viewSize = CGSizeMake(40, 40);
        [selectButton setBackgroundImage:[UIImage imageNamed:@"chosen"] forState:UIControlStateSelected];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"unchosen"] forState:UIControlStateNormal];
        [selectButton addTarget:self action:@selector(selectButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectButton];
        self.selectButton = selectButton;
    }
    
    return self;
}
-(UIImageView *)flag{
    if (!_flag) {
        UIImageView *flag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        flag.image = [UIImage imageNamed:@"Group 1321315481"];
        [self.contentView addSubview:flag];
        flag.hidden = true;
        _flag = flag;
    }
    return _flag;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(16, 0, 44, 44);
    self.imageView.centerY = self.contentView.middleY;
    
    [self.textLabel sizeToFit];
    if (self.textLabel.width > self.contentView.width - 76 - 96) {
        self.textLabel.width = self.contentView.width - 76 - 96;
    }
    self.textLabel.left = 76;
    
    if (self.remarkLabel.text.length) {
        [self.remarkLabel sizeToFit];
        if (self.remarkLabel.width > self.contentView.width - 76 - 96) {
            self.remarkLabel.width = self.contentView.width - 76 - 96;
        }
        self.remarkLabel.left = 76;
        self.textLabel.top = (self.contentView.height - self.remarkLabel.height - self.textLabel.height - 2) * 0.5;
        self.remarkLabel.top = self.textLabel.bottom + 2;
    } else {
        self.textLabel.centerY = self.contentView.middleY;
    }
    self.flag.left = self.textLabel.right + 5;
    self.flag.centerY = self.textLabel.centerY;
    self.selectButton.centerY = self.contentView.middleY;
    self.selectButton.right = self.contentView.width - 16;
    
    if (self.selectButton.hidden) {
        self.roleLabel.right = self.contentView.width - 32;
        self.roleLabel.centerY = self.contentView.middleY;
    } else {
        self.roleLabel.right = self.selectButton.left - 5;
        self.roleLabel.centerY = self.contentView.middleY;
    }
    
    
}

- (void)refreshData:(TIOTeamMember *)teamUser isSelf:(BOOL)isSelf status:(TCellSelectedStatus)status
{
    if (teamUser.avatar) {
        [self.imageView tio_imageUrl:teamUser.avatar placeHolderImageName:@"avatar_placeholder" radius:4];
    }
    
    if (teamUser.remarkname.length) {
        self.textLabel.text = teamUser.nick;
        self.remarkLabel.text = nil;
//        self.remarkLabel.text = [NSString stringWithFormat:@"昵称：%@",teamUser.srcnick];
    } else {
        self.textLabel.text = teamUser.srcnick;
        self.remarkLabel.text = nil;
    }
    
    if (teamUser.role == TIOTeamUserRoleOwner) {
        self.roleLabel.text = isSelf?@" 群主 我": @" 群主 ";
    } else if (teamUser.role == TIOTeamUserRoleManager) {
        self.roleLabel.text = isSelf?@" 管理员 我": @" 管理员 ";
    } else {
        self.roleLabel.text = isSelf?@"我":@"";
    }
    
    [self.roleLabel sizeToFit];
    
//    self.markLabel.hidden = !isSelf;
    
    if (isSelf) {
        self.selectButton.hidden = YES;
    } else {
        if (status == TCellSelectedStatusDisabled) {
            self.selectButton.hidden = YES;
        } else if (status == TCellSelectedStatusNone) {
            self.selectButton.selected = NO;
            self.selectButton.hidden = NO;
        } else {
            self.selectButton.selected = YES;
            self.selectButton.hidden = NO;
        }
    }
}

/// 去除group时的cell分割线
- (void)addSubview:(UIView *)view
{
    if ([view isKindOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) {
        return;
    }
    
    [super addSubview:view];
}

- (void)selectButtonDidClicked:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (self.selectedCallback) {
        self.selectedCallback(button.selected);
    }
}

@end
