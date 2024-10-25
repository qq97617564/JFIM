//
//  TTeamTransferMemberCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamTransferCell.h"
#import "UIImageView+Web.h"
#import "FrameAccessor.h"

@implementation TTeamTransferCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    self.textLabel.textColor = UIColor.blackColor;
    self.textLabel.font = [UIFont boldSystemFontOfSize:16.f];
    self.textLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(16, (self.contentView.height - 44) * 0.5, 44, 44);
    
    self.textLabel.frame = CGRectMake(72, (self.contentView.height - 22) * 0.5, self.contentView.width - 72 - 40, 22);
}

- (void)setNick:(NSString *)nick
{
    self.textLabel.text = nick;
}

- (void)setAvatarUrl:(NSString *)url
{
    // TODO: 需要添加占位图
    [self.imageView tio_imageUrl:url placeHolderImageName:@"avatar_placeholder" radius:4];
}


@end
