//
//  TInvitedUserCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/2/8.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TInvitedUserCell.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@interface TInvitedUserCell ()
@property (weak,    nonatomic) UIImageView *imageView;
@property (weak,    nonatomic) UILabel *nickLabel;
@end

@implementation TInvitedUserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageview = [UIImageView.alloc init];
        [self.contentView addSubview:imageview];
        self.imageView = imageview;
        
        UILabel *nickLabel = [UILabel.alloc init];
        nickLabel.textColor = [UIColor colorWithHex:0x333333];
        nickLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:nickLabel];
        self.nickLabel = nickLabel;
        
        // layout
        self.imageView.viewSize = CGSizeMake(self.contentView.width, self.contentView.width);
        self.imageView.viewOrigin = CGPointZero;
        self.nickLabel.viewSize = CGSizeMake(self.width, 20);
        self.nickLabel.width = self.contentView.width;
        self.nickLabel.bottom = self.contentView.height;
    }
    return self;
}


- (void)setModel:(TIOUser *)model
{
    _model = model;
    
    [self.imageView tio_imageUrl:model.avatar placeHolderImageName:@"avatar_placeholder" radius:4];
    self.nickLabel.text = model.nick;
}

@end
