//
//  WalletOpenView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletOpenView.h"
#import "UIImageView+Web.h"
#import "FrameAccessor.h"
#import "UIButton+Enlarge.h"

@interface WalletOpenView ()
@property (assign,  nonatomic) WalletStatus walletStatus;
@property (assign,  nonatomic) BOOL isSelf;
@property (copy,    nonatomic) NSString *avatarUrl;
@property (copy,    nonatomic) NSString *nick;
@property (copy,    nonatomic) NSString *remark;
@end

@implementation WalletOpenView

- (void)dealloc
{
    NSLog(@"dealloc:%s",__FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame Type:(WalletStatus)walletStatus isSelf:(BOOL)isSelf avatar:(nonnull NSString *)avatar nick:(nonnull NSString *)nick remark:(nonnull NSString *)remark
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        
        self.walletStatus = walletStatus;
        self.avatarUrl = avatar;
        self.nick = nick;
        self.remark = remark;
        self.isSelf = isSelf;
        
        UIView *card = nil;
        
        if (walletStatus == WalletStatusCanGet) {
            card = [self loadCanGetView];
        } else if (walletStatus == WalletStatusWasGot) {
            card = [self loadGotView];
        } else if (walletStatus == WalletStatusWasExpired) {
            card = [self loadExpiredView];
        } else {
            
        }
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:[UIImage imageNamed:@"redcard_cancel"] forState:UIControlStateNormal];
        [cancelButton sizeToFit];
        cancelButton.top = card.bottom+12;
        cancelButton.centerX = card.centerX;
        [cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
    }
    return self;
}

- (UIView *)loadCanGetView
{
    UIImageView *bg = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 270, 437)];
    bg.center = self.middlePoint;
    bg.centerY -= 25;
    bg.image = [UIImage imageNamed:@"wallet_start"];
    bg.userInteractionEnabled = YES;
    [self addSubview:bg];
    
    UIImageView *avatar = [UIImageView.alloc initWithFrame:CGRectMake((CGRectGetWidth(bg.frame)-50)*0.5, 57, 50, 50)];
    avatar.layer.cornerRadius = 25;
    avatar.layer.masksToBounds = YES;
    avatar.layer.borderColor = [UIColor colorWithHex:0xF9AD55].CGColor;
    avatar.layer.borderWidth = 1;
    [avatar tio_imageUrl:self.avatarUrl placeHolderImageName:@"placeholder_avatar" radius:25];
    [bg addSubview:avatar];
    
    UILabel *nickLabel = [UILabel.alloc initWithFrame:CGRectZero];
    nickLabel.text = self.nick;
    nickLabel.font = [UIFont systemFontOfSize:14];
    nickLabel.textColor = [UIColor colorWithHex:0xFED4A3];
    [nickLabel sizeToFit];
    nickLabel.centerX = bg.middleX;
    nickLabel.top = avatar.bottom+8;
    [bg addSubview:nickLabel];
    
    UILabel *wishLabel = [UILabel.alloc initWithFrame:CGRectMake(10, 10, bg.width-20, 70)];
    wishLabel.centerY = bg.middleY;
    wishLabel.font = [UIFont systemFontOfSize:20];
    wishLabel.textColor = [UIColor colorWithHex:0xFED4A3];
    wishLabel.textAlignment = NSTextAlignmentCenter;
    wishLabel.numberOfLines = 2;
    wishLabel.text = self.remark;
    [bg addSubview:wishLabel];
    
    UIButton *openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    openButton.viewSize = CGSizeMake(140, 44);
    openButton.centerX = bg.middleX;
    openButton.bottom = bg.height - 58;
    [openButton setBackgroundImage:[UIImage imageNamed:@"wallet_open_btn"] forState:UIControlStateNormal];
    [openButton setTitle:@"立即领取" forState:UIControlStateNormal];
    [openButton setTitleColor:[UIColor colorWithHex:0xF45846] forState:UIControlStateNormal];
    openButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [openButton addTarget:self action:@selector(openRed:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:openButton];
    
    if (self.isSelf) {
        // 查看大家人品
        UIButton *seeOthersButton = [UIButton buttonWithType:UIButtonTypeCustom];
        seeOthersButton.viewSize = CGSizeMake(120, 30);
        seeOthersButton.centerX = bg.middleX;
        seeOthersButton.bottom = bg.height - 15;
        [seeOthersButton setTitle:@"看看大家的人品" forState:UIControlStateNormal];
        [seeOthersButton setTitleColor:[UIColor colorWithHex:0xFED4A3] forState:UIControlStateNormal];
        seeOthersButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [seeOthersButton setImage:[UIImage imageNamed:@"wallet_seeother"] forState:UIControlStateNormal];
        [seeOthersButton verticalLayoutWithInsetsStyle:ButtonStyleRight Spacing:0];
        [seeOthersButton addTarget:self action:@selector(seeOthers:) forControlEvents:UIControlEventTouchUpInside];
        [bg addSubview:seeOthersButton];
    }
    
    return bg;
}

- (UIView *)loadGotView
{
    UIImageView *bg = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 267, 440)];
    bg.center = self.middlePoint;
    bg.centerY -= 25;
    bg.image = [UIImage imageNamed:@"wallet_redbg_end"];
    bg.userInteractionEnabled = YES;
    [self addSubview:bg];
    
    UIImageView *avatar = [UIImageView.alloc initWithFrame:CGRectMake((CGRectGetWidth(bg.frame)-50)*0.5, 138, 50, 50)];
    avatar.layer.cornerRadius = 25;
    avatar.layer.masksToBounds = YES;
    avatar.layer.borderColor = [UIColor colorWithHex:0xF9AD55].CGColor;
    avatar.layer.borderWidth = 1;
    [avatar tio_imageUrl:self.avatarUrl placeHolderImageName:@"placeholder_avatar" radius:25];
    [bg addSubview:avatar];
    
    UILabel *nickLabel = [UILabel.alloc initWithFrame:CGRectZero];
    nickLabel.text = self.nick;
    nickLabel.font = [UIFont systemFontOfSize:14];
    nickLabel.textColor = [UIColor colorWithHex:0xFED4A3];
    [nickLabel sizeToFit];
    nickLabel.centerX = bg.middleX;
    nickLabel.top = avatar.bottom+8;
    [bg addSubview:nickLabel];
    
    UILabel *wishLabel = [UILabel.alloc initWithFrame:CGRectMake(10, 10, bg.width-20, 28)];
    wishLabel.centerX = bg.middleX;
    wishLabel.top = 246;
    wishLabel.font = [UIFont systemFontOfSize:20];
    wishLabel.textColor = [UIColor colorWithHex:0xFED4A3];
    wishLabel.textAlignment = NSTextAlignmentCenter;
    wishLabel.text = @"哎呀，红包被一抢而光了";
    [bg addSubview:wishLabel];
    
    // 查看大家人品
    UIButton *seeOthersButton = [UIButton buttonWithType:UIButtonTypeCustom];
    seeOthersButton.viewSize = CGSizeMake(120, 30);
    seeOthersButton.centerX = bg.middleX;
    seeOthersButton.bottom = bg.height - 15;
    [seeOthersButton setTitle:@"看看大家的人品" forState:UIControlStateNormal];
    [seeOthersButton setTitleColor:[UIColor colorWithHex:0xFED4A3] forState:UIControlStateNormal];
    seeOthersButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [seeOthersButton setImage:[UIImage imageNamed:@"wallet_seeother"] forState:UIControlStateNormal];
    [seeOthersButton verticalLayoutWithInsetsStyle:ButtonStyleRight Spacing:0];
    [seeOthersButton addTarget:self action:@selector(seeOthers:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:seeOthersButton];
    
    return bg;
}

- (UIView *)loadExpiredView
{
    UIImageView *bg = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 267, 440)];
    bg.center = self.middlePoint;
    bg.centerY -= 25;
    bg.image = [UIImage imageNamed:@"wallet_redbg_end"];
    bg.userInteractionEnabled = YES;
    [self addSubview:bg];
    
    UIImageView *avatar = [UIImageView.alloc initWithFrame:CGRectMake((CGRectGetWidth(bg.frame)-50)*0.5, 138, 50, 50)];
    avatar.layer.cornerRadius = 25;
    avatar.layer.masksToBounds = YES;
    avatar.layer.borderColor = [UIColor colorWithHex:0xF9AD55].CGColor;
    avatar.layer.borderWidth = 1;
    [avatar tio_imageUrl:self.avatarUrl placeHolderImageName:@"placeholder_avatar" radius:25];
    [bg addSubview:avatar];
    
    UILabel *nickLabel = [UILabel.alloc initWithFrame:CGRectZero];
    nickLabel.text = self.nick;
    nickLabel.font = [UIFont systemFontOfSize:14];
    nickLabel.textColor = [UIColor colorWithHex:0xFED4A3];
    [nickLabel sizeToFit];
    nickLabel.centerX = bg.middleX;
    nickLabel.top = avatar.bottom+8;
    [bg addSubview:nickLabel];
    
    UILabel *wishLabel = [UILabel.alloc initWithFrame:CGRectMake(10, 10, bg.width-20, 28)];
    wishLabel.centerX = bg.middleX;
    wishLabel.top = 246;
    wishLabel.font = [UIFont systemFontOfSize:20];
    wishLabel.textColor = [UIColor colorWithHex:0xFED4A3];
    wishLabel.textAlignment = NSTextAlignmentCenter;
    wishLabel.text = @"可惜，当前红包过期了";
    [bg addSubview:wishLabel];
    
    UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(16, bg.height - 15-30, bg.width-32, 30)];
    label.text = @"超过24小时未领取将自动过期";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithHex:0xFED4A3];
    [bg addSubview:label];
//    // 查看大家人品
//    UIButton *seeOthersButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    seeOthersButton.viewSize = CGSizeMake(120, 30);
//    seeOthersButton.centerX = bg.middleX;
//    seeOthersButton.bottom = bg.height - 15;
//    [seeOthersButton setTitle:@"超过24小时未领取将自动过期" forState:UIControlStateNormal];
//    [seeOthersButton setTitleColor:[UIColor colorWithHex:0xFED4A3] forState:UIControlStateNormal];
//    seeOthersButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    [bg addSubview:seeOthersButton];
    
    return bg;
}

#pragma mark - actions

- (void)openRed:(id)sender
{
    if (self.openBlock) {
        self.openBlock(self);
    }
    
    [self removeFromSuperview];
}

- (void)cancelClicked:(id)sender
{
    [self removeFromSuperview];
}

- (void)seeOthers:(id)sender
{
    if (self.seeOthersBlock) {
        self.seeOthersBlock(self);
    }
    
    [self removeFromSuperview];
}

@end
