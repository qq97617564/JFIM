//
//  IMKitSessionTimeCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitSessionTimeCell.h"
#import "TIOChatKit.h"
#import "IMKitTimeModel.h"
#import "TIOKitDependency.h"
#import "TIOKitTool.h"

@interface IMKitSessionTimeCell()

@property (nonatomic,strong) IMKitTimeModel *model;

@end

@implementation IMKitSessionTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _timeBGView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_timeBGView];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1.0];
        [self addSubview:_timeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_timeLabel sizeToFit];
    _timeLabel.center = CGPointMake(self.middleX, self.middleY+5);
}


- (void)refreshData:(IMKitTimeModel *)data
{
    self.model = data;
    if([self checkData]){
        IMKitTimeModel *model = data;
        _timeLabel.text = [TIOKitTool showTime:model.messageTime showDetail:YES];
    }
}

- (BOOL)checkData{
    return [self.model isKindOfClass:[IMKitTimeModel class]];
}

@end
