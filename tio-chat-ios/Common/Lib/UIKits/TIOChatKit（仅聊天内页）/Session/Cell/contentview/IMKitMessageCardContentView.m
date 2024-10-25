//
//  IMKitMessageCardContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageCardContentView.h"
#import "TIOChatKit.h"

#import "FrameAccessor.h"

#import "TIOKitTool.h"
#import "UIImageView+Web.h"
#import "UIImage+TColor.h"


@interface IMKitMessageCardContentView ()

/// 文件图标
@property (weak, nonatomic) UIImageView *avatrView;
/// 文件大小label
@property (weak, nonatomic) UILabel *nickLabel;
/// 备注是个人名片还是群名片
@property (weak, nonatomic) UILabel *remarkLabel;
//@property (weak, nonatomic) UIImageView *icon;
@end

@implementation IMKitMessageCardContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        UIImageView *bgView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 210, 90)];
        bgView.image = [[UIImage imageWithColor:UIColor.whiteColor] imageWithCornerRadius:4 size:bgView.viewSize];
        bgView.layer.cornerRadius = 4;
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderColor = [UIColor colorWithHex:0xEBEBEB].CGColor;
        bgView.layer.borderWidth = 0.5;
        [self addSubview:bgView];
        
        UIImageView *avatrView = [UIImageView.alloc init];
        avatrView.viewSize = CGSizeMake(44, 44);
        avatrView.viewOrigin = CGPointMake(12, 12);
        avatrView.layer.cornerRadius = 4;
        avatrView.left = 15;
//        avatrView.centerY = bg2.centerY;
        
        [bgView addSubview:avatrView];
        self.avatrView = avatrView;
        
        UIView *line = [UIView.alloc initWithFrame:CGRectMake(13, 69, 210-26, 0.5)];
        line.backgroundColor = [UIColor colorWithHex:0xEBEBEB];
        [bgView addSubview:line];
        
        UILabel *nickLabel = [UILabel.alloc init];
        nickLabel.viewSize = CGSizeMake(bgView.width - 63 - 16, 22);
        nickLabel.textColor = [UIColor colorWithHex:0x333333];
        nickLabel.textAlignment = NSTextAlignmentLeft;
        nickLabel.font = [UIFont systemFontOfSize:16];
        nickLabel.left = 63;
        nickLabel.centerY = avatrView.centerY;
        [bgView addSubview:nickLabel];
        self.nickLabel = nickLabel;
        
        UILabel *remarkLabel = [UILabel.alloc init];
        remarkLabel.viewSize = CGSizeMake(60, 17);
        remarkLabel.font = [UIFont systemFontOfSize:10];
        remarkLabel.textColor = [UIColor colorWithHex:0xAAAAAA];
        [self addSubview:remarkLabel];
        self.remarkLabel = remarkLabel;
        
//        UIImageView *icon = [UIImageView.alloc init];
//        [self addSubview:icon];
//        self.icon = icon;
        
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    [self.icon sizeToFit];
//    self.icon.left = 12;
//    self.icon.centerY = 76.5 + (self.height - 76.5) * 0.5;
    
    self.remarkLabel.left = 12;
    self.remarkLabel.centerY = 70 + (self.height - 70) * 0.5;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    
    TIOMessageAttachmnet *attachment = messageModel.message.attachmentObjects.firstObject;
    [self.avatrView tio_imageUrl:attachment.bizavatar placeHolderImageName:@"avatar_placeholder" radius:4];
    
    self.nickLabel.text = attachment.bizname;
    self.remarkLabel.text = attachment.cardtype == 1 ? @"个人名片" : @"群名片";
    [self.remarkLabel sizeToFit];
    
//    self.icon.image = attachment.cardtype == 1 ? [UIImage imageNamed:@"card_user_icon"] : [UIImage imageNamed:@"card_team_icon"];
}

@end
