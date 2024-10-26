//
//  IMKitMessageRedContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageRedContentView.h"
#import "TIOChatKit.h"

#import "FrameAccessor.h"

#import "TIOKitTool.h"
#import "UIImage+TColor.h"

@interface IMKitMessageRedContentView()
@property (weak,    nonatomic) UIImageView *bgImageView;
@property (weak,    nonatomic) UILabel *contentLabel;
@end

@implementation IMKitMessageRedContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        UIImageView *bgView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 210, 90)];
        bgView.image = [UIImage imageNamed:@"red_msg_bg"];
        bgView.layer.cornerRadius = 4;
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderColor = [UIColor colorWithHex:0xEBEBEB].CGColor;
        bgView.layer.borderWidth = 0.5;
        [self addSubview:bgView];
        self.bgImageView = bgView;
        
        UIImageView *icon = [UIImageView.alloc initWithFrame:CGRectMake(5, 12, 48, 48)];
        icon.image = [UIImage imageNamed:@"red_icon"];
        [self addSubview:icon];
        
        UILabel *contentLabel = [UILabel.alloc initWithFrame:CGRectMake(59, 0, 140, 68)];
        contentLabel.centerY = icon.centerY;
        contentLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        contentLabel.textColor = [UIColor colorWithHex:0xFED4A3];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.numberOfLines = 2;
        [self addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        UIView *line = [UIView.alloc initWithFrame:CGRectMake(13, 67, 186, 1)];
        line.backgroundColor = [UIColor colorWithHex:0xFB8476];
        [self addSubview:line];
        
        UILabel *remarkLabel = [UILabel.alloc initWithFrame:CGRectZero];
        remarkLabel.text = @"季风红包";
        remarkLabel.font = [UIFont systemFontOfSize:10];
        remarkLabel.textColor = [UIColor colorWithHex:0xFED4A3];
        [remarkLabel sizeToFit];
        remarkLabel.left = 16;
        remarkLabel.top = line.bottom+4;
        [self addSubview:remarkLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bgImageView.frame = self.bounds;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    
    /// 订单状态：SUCCESS-已抢完;TIMEOUT-24小时超时;SEND-抢红包中
    NSString *status = messageModel.message.attachmentObjects.firstObject.status;
    NSString *content = messageModel.message.attachmentObjects.firstObject.text?:@"恭喜发财，吉祥如意";
    
    if ([status isEqualToString:@"SUCCESS"]) {
        self.bgImageView.image = [[UIImage imageWithColor:[UIColor colorWithHex:0xFF908F]] imageWithCornerRadius:4 size:self.bgImageView.viewSize];
        [self updateContent:content remark:@"已被领完"];
    } else if ([status isEqualToString:@"SEND"]) {
        self.bgImageView.image = [UIImage imageNamed:@"red_msg_bg"];
        [self updateContent:content remark:nil];
    } else if ([status isEqualToString:@"TIMEOUT"]) {
        self.bgImageView.image = [[UIImage imageWithColor:[UIColor colorWithHex:0xFF908F]] imageWithCornerRadius:4 size:self.bgImageView.viewSize];
        [self updateContent:content remark:@"已过期"];
    } else if ([status isEqualToString:@"GRAB"]) {
        self.bgImageView.image = [[UIImage imageWithColor:[UIColor colorWithHex:0xFF908F]] imageWithCornerRadius:4 size:self.bgImageView.viewSize];
        [self updateContent:content remark:@"已领取"];
    } else {
        self.bgImageView.image = [UIImage imageNamed:@"red_msg_bg"];
        [self updateContent:content remark:nil];
    }
    
}

/// 更新气泡文案显示
/// @param content 祝福语
/// @param remark 标记过期、已抢
- (void)updateContent:(NSString *)content remark:(NSString  * _Nullable)remark
{
    
    content = content.length>10?[content substringToIndex:9]:content;
    
    NSDictionary *dic1 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0xFFE1B4], NSFontAttributeName:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]};
    NSDictionary *dic2 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0xFFE1B4], NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]};


    self.contentLabel.attributedText = ({
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
        [aString appendAttributedString:[NSMutableAttributedString.alloc initWithString:content attributes:dic1]];
        if (remark) {
            [aString appendAttributedString:[NSMutableAttributedString.alloc initWithString:@"\n"]];
            [aString appendAttributedString:[NSMutableAttributedString.alloc initWithString:remark attributes:dic2]];
        }
        
        aString;
    });
    
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    
}

@end
