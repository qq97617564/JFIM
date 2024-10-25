//
//  TCardToSessionCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCardToSessionCell.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@implementation TCardToSessionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor colorWithHex:0xF9F9F9];
    UIImageView *avatarView = ({
        UIImageView *imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        imageView;
    });
    [self.contentView addSubview:avatarView];
    _avaterView = avatarView;
    
    UILabel *nickLabel = ({
        UILabel *label = [UILabel.alloc init];
        label.textColor = [UIColor colorWithHex:0x333333];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        label.textAlignment = NSTextAlignmentLeft;
        
        label;
    });
    [self.contentView addSubview:nickLabel];
    _nickLabel = nickLabel;
    
    UILabel *countLabel = ({
        UILabel *label = [UILabel.alloc init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHex:0x999999];
        
        label;
    });
    [self.contentView addSubview:countLabel];
    _countLabel = countLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avaterView.left = 15;
    self.avaterView.centerY = self.contentView.middleY;
    
    [self.nickLabel sizeToFit];
    [self.countLabel sizeToFit];
    
    if (_nickLabel.width > self.contentView.width - 71 - 16) {
        _nickLabel.width = self.contentView.width - 71 - 16;
    }
    
    if (self.countLabel.text) {
        self.nickLabel.left = 71;
        self.countLabel.left = 71;
        
        self.countLabel.hidden = NO;
        self.nickLabel.top = (self.contentView.height - 40)*0.5;
        self.countLabel.bottom = self.contentView.height - (self.contentView.height - 40)*0.5;
    }
    else {
        self.nickLabel.left = 71;
        self.nickLabel.centerY = self.contentView.middleY;
        self.countLabel.hidden = YES;
    }
}

- (void)setAvatarUrl:(NSString *)url
{
    // TODO: 需要添加占位图
//    [self.avaterView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
    [self.avaterView tio_imageUrl:url placeHolderImageName:@"avatar_placeholder" radius:4];
}


@end
