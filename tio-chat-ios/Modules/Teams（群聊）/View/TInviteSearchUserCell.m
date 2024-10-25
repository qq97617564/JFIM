//
//  TInviteSearchUserCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TInviteSearchUserCell.h"
#import "UIImage+TColor.h"
#import "NSMutableAttributedString+T_Replace.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@interface TInviteSearchUserCell ()
@property (weak, nonatomic) UIImageView *avatarView;
@property (weak, nonatomic) UILabel *nickLabel;
@property (weak, nonatomic) UIImageView *sexImageView;
@property (weak, nonatomic) UIButton *selectButton;
@end

@implementation TInviteSearchUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        UIImageView *avatarView = [UIImageView.alloc initWithFrame:CGRectMake(16, 0, 44, 44)];
        [self.contentView addSubview:avatarView];
        self.avatarView = avatarView;
        
        UILabel *nickLabel = [UILabel.alloc init];
        nickLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:nickLabel];
        self.nickLabel = nickLabel;
        
        UIImageView *sexImageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 16, 16)];
        [self.contentView addSubview:sexImageView];
        
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.viewSize = CGSizeMake(40, 40);
        [selectButton setBackgroundImage:[UIImage imageNamed:@"chosen"] forState:UIControlStateSelected];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"unchosen"] forState:UIControlStateNormal];
        [selectButton addTarget:self action:@selector(selectButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectButton];
        self.selectButton = selectButton;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.centerY = self.contentView.middleY;
    
    self.sexImageView.bottom = self.avatarView.bottom;
    self.sexImageView.right = self.avatarView.right + 4;
    
    [self.nickLabel sizeToFit];
    if (self.nickLabel.width > (self.contentView.width - 72 - 80))
    {
        self.nickLabel.width = self.contentView.width - 72 - 80;
    }
    self.nickLabel.centerY = self.contentView.middleY;
    self.nickLabel.left = 72;
    
    self.selectButton.centerY = self.contentView.middleY;
    self.selectButton.right = self.contentView.width - 16;
}

- (void)selectButtonDidClicked:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (self.selectedCallback) {
        self.selectedCallback(button.selected);
    }
}

- (void)refreshAvatar:(NSString *)avatar sex:(NSInteger)sex nick:(NSString *)nick relation:(NSInteger)relation key:(nonnull NSString *)key status:(TCellSelectedStatus)status
{
    [self.avatarView tio_imageUrl:avatar placeHolderImageName:@"avatar_placeholder" radius:4];
    
    /// 处理关键字富文本
    TAttributedString *node = [TAttributedString.alloc init];
    node.text = key;
    node.attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHex:0x4C94E8]};
    
    NSMutableAttributedString *nickAttributedString = [NSMutableAttributedString.alloc initWithString:nick attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.nickLabel.attributedText = [nickAttributedString replaceAttributesWithStrings:@[node]];
    
    if (status == TCellSelectedStatusDisabled) {
        self.selectButton.hidden = YES;
    } else {
        self.selectButton.hidden = NO;
        self.selectButton.selected = status == TCellSelectedStatusSelected;
    }
}


@end
