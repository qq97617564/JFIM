//
//  TNewFriendCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/13.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TNewFriendCell.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@interface TNewFriendCell ()

@property (nonatomic, weak) UIImageView *avatarView;
/// 标记状态
@property (nonatomic, weak) UILabel *remarkLabel;

@property (nonatomic, weak) UIButton *ignoreButton;

@property (nonatomic, weak) UIButton *addButton;

@end

@implementation TNewFriendCell

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
    UIImageView *avatarView = ({
        UIImageView *imageView = [UIImageView.alloc init];
        imageView.bounds = CGRectMake(0, 0, 50, 50);
        
        imageView;
    });
    [self.contentView addSubview:avatarView];
    _avatarView = avatarView;
    
    UILabel *nickLabel = ({
        UILabel *label = [UILabel.alloc init];
        label.textColor = [UIColor colorWithHex:0x333333];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentLeft;
        
        label;
    });
    [self.contentView addSubview:nickLabel];
    _nickLabel = nickLabel;
    
    UILabel *msgLabel = ({
        UILabel *label = [UILabel.alloc init];
        label.textColor = [UIColor colorWithHex:0x888888];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        
        label;
    });
    [self.contentView addSubview:msgLabel];
    _msgLabel = msgLabel;
    
    UILabel *reamrkLabel = ({
        UILabel *label = [UILabel.alloc init];
        label.textColor = [UIColor colorWithHex:0x888888];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        
        label;
    });
    [self.contentView addSubview:reamrkLabel];
    _remarkLabel = reamrkLabel;
 
    UIButton *addButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake(0, 0, 66, 30);
        button.layer.cornerRadius = 4;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = [UIColor colorWithHex:0x4C94FF].CGColor;
        button.layer.borderWidth = 1.f;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
        [button setTitle:@"同意" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(addFriendClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        
        button;
    });
    [self.contentView addSubview:addButton];
    _addButton = addButton;
    
    UIButton *ignoreButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake(0, 0, 66, 30);
        button.bounds = CGRectMake(0, 0, 66, 30);
        button.layer.cornerRadius = 4;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = [UIColor colorWithHex:0xE2E2E2].CGColor;
        button.layer.borderWidth = 1.f;
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitle:@"忽略" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHex:0x666666] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(ignoreFriendClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        
        button;
    });
    [self.contentView addSubview:ignoreButton];
    _ignoreButton = ignoreButton;
}

- (void)setReqStatus:(TIOFriendReqStatus)reqStatus
{
    if (reqStatus == TIOFriendReqStatusWaitting) {
        self.remarkLabel.hidden = YES;
        self.addButton.hidden = NO;
        self.ignoreButton.hidden = NO;
    } else if (reqStatus == TIOFriendReqStatusAdded) {
        self.remarkLabel.hidden = NO;
        self.addButton.hidden = YES;
        self.ignoreButton.hidden = YES;
        
        self.remarkLabel.text = @"已添加";
    } else if (reqStatus == TIOFriendReqStatusRejected) {
        self.remarkLabel.hidden = NO;
        self.addButton.hidden = YES;
        self.ignoreButton.hidden = YES;
        
        self.remarkLabel.text = @"已拒绝";
    } else if (reqStatus == TIOFriendReqStatusIgnored) {
        self.remarkLabel.hidden = NO;
        self.addButton.hidden = YES;
        self.ignoreButton.hidden = YES;
        
        self.remarkLabel.text = @"已忽略";
    } else {
        self.remarkLabel.hidden = NO;
        self.addButton.hidden = YES;
        self.ignoreButton.hidden = YES;
        
        self.remarkLabel.text = @"已过期";
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.left = 16;
    self.avatarView.centerY = self.contentView.middleY;
    
    self.nickLabel.left = 78;
    self.nickLabel.top = 12;
    self.nickLabel.viewSize = CGSizeMake(self.contentView.width - 78 - 16 - 96, 25);
    
    self.msgLabel.left = 78;
    self.msgLabel.top = self.nickLabel.bottom + 1;
    self.msgLabel.viewSize = self.nickLabel.viewSize;
    
    self.addButton.centerY = self.middleY;
    self.addButton.right = self.contentView.width - 16;
    
    self.ignoreButton.centerY = self.addButton.centerY;
    self.ignoreButton.right = self.addButton.left - 6;
    
    self.remarkLabel.viewSize = CGSizeMake(45, 20);
    self.remarkLabel.center = self.addButton.center;
}

- (void)addFriendClicked:(id)sender
{
    if (@protocol(TNewFriendCellDelegate) && [_delegate respondsToSelector:@selector(onAddFriend:)]) {
        [_delegate onAddFriend:self];
    }
}

- (void)rejectFriendClicked:(id)sender
{
    if (@protocol(TNewFriendCellDelegate) && [_delegate respondsToSelector:@selector(onRejectFriend:)]) {
        [_delegate onRejectFriend:self];
    }
}

- (void)ignoreFriendClicked:(id)sender
{
    if (@protocol(TNewFriendCellDelegate) && [_delegate respondsToSelector:@selector(onIgnoreFriend:)]) {
        [_delegate onIgnoreFriend:self];
    }
}


- (void)setAvatarUrl:(NSString *)url
{
    // TODO: 需要添加占位图
    [self.avatarView tio_imageUrl:url placeHolderImageName:@"avatar_placeholder" radius:4];
}

@end
