//
//  TSearchUserCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSearchUserCell.h"
#import "UIImage+TColor.h"
#import "NSMutableAttributedString+T_Replace.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@interface TSearchUserCell ()
@property (weak, nonatomic) UIImageView *avatarView;
@property (weak, nonatomic) UILabel *nickLabel;
@property (weak, nonatomic) UIImageView *sexImageView;
@property (weak, nonatomic) UIButton *addButton;
@end

@implementation TSearchUserCell

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
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.viewSize = CGSizeMake(64, 30);
        addButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        addButton.layer.cornerRadius = 4;
        addButton.layer.masksToBounds = YES;
        addButton.layer.borderColor = UIColor.TDTheme_TabBarSelectedColor.CGColor;
        addButton.layer.borderWidth = 1;
        [addButton setTitle:@"添加" forState:UIControlStateNormal];
        [addButton setTitleColor:UIColor.TDTheme_TabBarSelectedColor forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:addButton];
        self.addButton = addButton;
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
    
    self.addButton.centerY = self.contentView.middleY;
    self.addButton.right = self.contentView.width - 16;
}

- (void)addButtonDidClicked:(id)sender
{
    if (self.addCallback) {
        self.addCallback();
    }
}

- (void)refreshAvatar:(NSString *)avatar sex:(NSInteger)sex nick:(NSString *)nick relation:(NSInteger)relation key:(nonnull NSString *)key
{
    [self.avatarView tio_imageUrl:avatar placeHolderImageName:@"avatar_placeholder" radius:7];
    
    /// 处理关键字富文本
    TAttributedString *node = [TAttributedString.alloc init];
    node.text = key;
    node.attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHex:0x4C94E8]};
    
    NSMutableAttributedString *nickAttributedString = [NSMutableAttributedString.alloc initWithString:nick attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.nickLabel.attributedText = [nickAttributedString replaceAttributesWithStrings:@[node]];
}

@end
