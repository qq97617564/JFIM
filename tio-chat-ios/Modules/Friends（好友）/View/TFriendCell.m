//
//  TFriendCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TFriendCell.h"
#import "UIImageView+Web.h"
#import "FrameAccessor.h"
#import "IMKitBadgeView.h"

@interface TFriendCell ()

/// 未读消息
@property (nonatomic, weak, readonly) IMKitBadgeView *badgeView;

@end

@implementation TFriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{   
    self.textLabel.textColor = [UIColor colorWithHex:0x333333];
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    
    IMKitBadgeView *badgeView = ({
        IMKitBadgeView *view = [IMKitBadgeView viewWithBadgeTip:@""];
        view.badgeLeftPadding = 9.f;
        view.badgeTopPadding = -0.5f;
        view.badgeBackgroundColor = [UIColor colorWithHex:0xFB7B7A];
        view.badgeTextFont = [UIFont systemFontOfSize:12];
        view.whiteCircleWidth = 0;
        view.badgeHeight = 16;
        
        view;
    });
    [self.contentView addSubview:badgeView];
    _badgeView = badgeView;
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
    
    self.imageView.frame = CGRectMake(16, (self.contentView.height - 40) * 0.5, 40, 40);
    
    self.textLabel.centerY = self.contentView.middleY;
    self.textLabel.left = 72;
    
    self.badgeView.centerY = self.contentView.middleY;
    self.badgeView.right = self.contentView.width - 16;
    
    self.flag.left = self.textLabel.right+5;
    self.flag.centerY = self.contentView.middleY;
}

- (void)setNick:(NSString *)nick
{
    self.textLabel.text = nick;
    [self.textLabel sizeToFit];
}

- (void)setAvatarUrl:(NSString *)url
{
    // TODO: 需要添加占位图
    [self.imageView tio_imageUrl:url placeHolderImageName:@"avatar_placeholder" radius:4];
}

- (void)setDetail:(NSString *)detail
{
    self.badgeView.badgeValue = detail;
}

@end
