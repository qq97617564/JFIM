//
//  TSettingCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSettingCell.h"
#import "FrameAccessor.h"

@interface TSettingCell ()
@property (nonatomic,   strong) UISwitch *switchControll;
@property (nonatomic,   strong) UILabel *detailLabel;
@end

@implementation TSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.switchControll = [UISwitch.alloc initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.switchControll.onTintColor = [UIColor colorWithHex:0x0087FC];
        self.switchControll.tintColor = [UIColor colorWithHex:0xE8EBF0];
        self.switchControll.thumbTintColor = [UIColor whiteColor];
        [self.switchControll addTarget:self action:@selector(valueChanged:) forControlEvents:(UIControlEventValueChanged)];
        [self.contentView addSubview:self.switchControll];
        
        UILabel *detailLabel = [UILabel.alloc init];
        detailLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        detailLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
        [self.contentView addSubview:detailLabel];
        self.detailLabel = detailLabel;
        
        self.textLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        self.textLabel.textColor = [UIColor colorWithHex:0x333333];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.switchControll.right = self.contentView.width - 16;
    self.switchControll.centerY = self.contentView.middleY;
    
    self.textLabel.centerY = self.contentView.middleY;
    self.textLabel.left = 16;
    
    self.detailLabel.centerY = self.contentView.middleY;
    self.detailLabel.right = self.contentView.width - 16;
}

- (void)setOpen:(BOOL)open
{
    self.switchControll.on = open;
    
    self.switchControll.thumbTintColor = open ? [UIColor colorWithHex:0x4C94FF] : [UIColor colorWithHex:0xF2F2F2];
}

- (BOOL)open
{
    return self.switchControll.on;
}

///// 去除group时的cell分割线
//- (void)addSubview:(UIView *)view
//{
//    if ([view isKindOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) {
//        return;
//    }
//    
//    [super addSubview:view];
//}

- (void)valueChanged:(UISwitch *)switchControll
{
    switchControll.thumbTintColor = switchControll.on ? [UIColor colorWithHex:0x4C94FF] : [UIColor colorWithHex:0xF2F2F2];
    if (self.switchCallback) {
        self.switchCallback(self, switchControll.on);
    }
}

- (void)setDetailText:(NSString *)detailText
{
    [self.detailLabel setText:detailText];
    [self.detailLabel sizeToFit];
    
    self.switchControll.hidden = YES;
}

@end
