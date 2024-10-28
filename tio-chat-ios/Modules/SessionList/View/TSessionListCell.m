//
//  TSessionListCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSessionListCell.h"
#import "UIImage+TColor.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@interface TSessionListCell ()
@property (nonatomic, weak, readonly) UIImageView *topIcon;
/// 红点
@property (nonatomic, weak) UIView *redDot;
/// 免打扰图标
@property (nonatomic, weak) UIImageView *DNDIcon;
@end

@implementation TSessionListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor colorWithHex:0xF9F9F9];
    UIImageView *avatarView = ({
        UIImageView *imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 50, 50)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 25;
//        imageView.layer.masksToBounds = YES;
        
        imageView;
    });
    [self.contentView addSubview:avatarView];
    _avaterView = avatarView;
    
    UILabel *nickLabel = ({
        UILabel *label = [UILabel.alloc init];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        label.textAlignment = NSTextAlignmentLeft;
        
        label;
    });
    [self.contentView addSubview:nickLabel];
    _nickLabel = nickLabel;
    
    UIImageView *flag = [[UIImageView alloc]init];
    flag.image = [UIImage imageNamed:@"Group 1321315481"];
    [self.contentView addSubview:flag];
    _flag = flag;
    
    
    UILabel *messageLabel = ({
        UILabel *label = [UILabel.alloc init];
        label.textColor = [UIColor colorWithHex:0x909090];
        label.font = [UIFont systemFontOfSize:13.f];
        label.textAlignment = NSTextAlignmentLeft;
        
        label;
    });
    [self.contentView addSubview:messageLabel];
    _messageLabel = messageLabel;
    
    UILabel *timeLabel = ({
        UILabel *label = [UILabel.alloc init];
        label.textColor = [UIColor colorWithHex:0xB5B5B5];
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentRight;
        
        label;
    });
    [self.contentView addSubview:timeLabel];
    _timeLabel = timeLabel;
    
    IMKitBadgeView *badgeView = ({
        IMKitBadgeView *view = [IMKitBadgeView viewWithBadgeTip:@""];
        view.badgeLeftPadding = 9.f;
        view.badgeTopPadding = -0.5f;
        view.badgeBackgroundColor = [UIColor colorWithHex:0xFE3724];
        view.badgeTextFont = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
        view.whiteCircleWidth = 0;
        view.badgeHeight = 14;

        view;
    });
    [self.contentView addSubview:badgeView];
    _badgeView = badgeView;
    
    
    UIImageView *topIcon = ({
        UIImageView *img = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"session_top"]];
        [img sizeToFit];
        img.hidden = YES;
        img;
    });
    [self.contentView addSubview:topIcon];
    _topIcon = topIcon;
    
    UIImageView *dndIcon = ({
        UIImageView *imageView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"dnd"]];
        [imageView sizeToFit];
        imageView.hidden = YES;
        imageView;
    });
    [self.contentView addSubview:dndIcon];
    self.DNDIcon = dndIcon;
    
    UIView *reddot = ({
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 8, 8)];
        view.backgroundColor = [UIColor colorWithHex:0xFB7B7A];
        view.layer.cornerRadius = 4;
        view.layer.masksToBounds = YES;
        view.hidden = YES;
        view;
    });
    [self.contentView addSubview:reddot];
    self.redDot = reddot;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avaterView.frame = CGRectMake(16, (self.contentView.height - 50)*0.5, 50, 50);
    
    self.nickLabel.frame = CGRectMake(78, self.avaterView.top + 2, self.contentView.width - 78 - 60, 22);

    
    self.messageLabel.frame = CGRectMake(78, self.nickLabel.bottom + 4, self.nickLabel.width, 20);
    
    self.timeLabel.frame = CGRectMake(self.contentView.width - 16 - 60, 16, 60, 17);
    self.timeLabel.centerY = self.nickLabel.centerY;
    
    self.topIcon.right = self.contentView.width;
    self.topIcon.top = 0;
    
    if (!self.DNDIcon.hidden) {
        self.DNDIcon.right = self.contentView.width - 17;
        self.DNDIcon.centerY = self.messageLabel.centerY;
        
        self.redDot.top = self.DNDIcon.top;
        self.redDot.right = self.DNDIcon.right;
    } else {
        self.badgeView.centerY = self.messageLabel.centerY;
        self.badgeView.right = self.contentView.width - 16;
    }
}

- (void)setAvatarUrl:(NSString *)url
{
    // TODO: 需要添加占位图
//    [self.avaterView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
    if (url) {
        [self.avaterView tio_imageUrl:url placeHolderImageName:@"avatar_placeholder" radius:4];
    }
}

- (void)setIsTop:(BOOL)isTop
{
    _topIcon.hidden = !isTop;
    
    self.backgroundColor = isTop ? [UIColor colorWithHex:0xF2F2F2] : [UIColor colorWithHex:0xF9F9F9];
}

- (void)setShowRedDot:(BOOL)showRedDot
{
    self.redDot.hidden = !showRedDot;
}

- (void)setShowDoNotDisturbIcon:(BOOL)showDoNotDisturbIcon
{
    self.DNDIcon.hidden = !showDoNotDisturbIcon;
}

- (void)setShowDoNotDisturbIcon:(BOOL)showDoNotDisturbIcon unreadCount:(NSInteger)unreadCount
{
    self.DNDIcon.hidden = !showDoNotDisturbIcon;
    if (!showDoNotDisturbIcon) {
        self.redDot.hidden = YES;
        self.badgeView.hidden = NO;
        self.badgeView.badgeValue = [NSString stringWithFormat:@"%zd",unreadCount];
    } else {
        self.badgeView.hidden = YES;
        self.redDot.hidden = NO;
        self.redDot.hidden = !(unreadCount>0);
    }
}

@end
