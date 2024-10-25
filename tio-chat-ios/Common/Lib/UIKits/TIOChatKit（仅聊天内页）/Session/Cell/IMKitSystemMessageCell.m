//
//  IMKitSessionTipCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitSystemMessageCell.h"
#import "IMKitSystemMessageModel.h"
#import "FrameAccessor.h"
#import "TIOKitTool.h"

@interface IMKitSystemMessageCell ()
@property (strong,  nonatomic) IMKitSystemMessageModel *model;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation IMKitSystemMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor colorWithRed:205/255.0 green:208/255.0 blue:211/255.0 alpha:1.0];
        [self addSubview:_timeLabel];
        
        UILabel *msgLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 104, 20)];
        msgLabel.layer.cornerRadius = 10;
        msgLabel.layer.masksToBounds = YES;
        msgLabel.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        msgLabel.textColor = [UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1.0];
        msgLabel.font = [UIFont systemFontOfSize:12];
        msgLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:msgLabel];
        self.msgLabel = msgLabel;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_timeLabel sizeToFit];
    _timeLabel.centerX = self.middleX;
    _timeLabel.top = (self.height - self.model.contentSize.height - 4) * 0.5;
    
    self.msgLabel.viewSize = self.model.contentSize;
    self.msgLabel.centerX = self.middleX;
    self.msgLabel.top = _timeLabel.bottom + 4;
}

- (void)refreshData:(IMKitSystemMessageModel *)data
{
    self.model = data;
    
    if ([self checkData]) {
        self.msgLabel.text = data.msg;
        self.timeLabel.text = [TIOKitTool showTime:data.timestamp showDetail:YES];
    }
}

- (BOOL)checkData{
    return [self.model isKindOfClass:[IMKitSystemMessageModel class]];
}

@end
