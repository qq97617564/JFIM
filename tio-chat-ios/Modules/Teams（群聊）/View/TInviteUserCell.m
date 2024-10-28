//
//  TInviteUserCell.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TInviteUserCell.h"
#import "UIImageView+Web.h"
#import "UIImage+TColor.h"
#import "FrameAccessor.h"

@interface TInviteUserCell ()
@property (nonatomic, weak) UIButton *selectButton;
@end

@implementation TInviteUserCell

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
    self.textLabel.textColor = [UIColor colorWithHex:0x333333];
    self.textLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightMedium];
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    
    self.detailTextLabel.font = [UIFont systemFontOfSize:12];
    self.detailTextLabel.textColor = [UIColor colorWithHex:0xFF754C];
    
    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.viewSize = CGSizeMake(40, 40);
    [selectButton setBackgroundImage:[UIImage imageNamed:@"chosen"] forState:UIControlStateSelected];
    [selectButton setBackgroundImage:[UIImage imageNamed:@"unchosen"] forState:UIControlStateNormal];
//    [selectButton addTarget:self action:@selector(selectButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:selectButton];
    self.selectButton = selectButton;
    
    UITapGestureRecognizer *ges = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(selectButtonDidClicked:)];
    [self addGestureRecognizer:ges];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.selectButton.left = 5;
    self.selectButton.centerY = self.contentView.middleY;
    self.imageView.frame = CGRectMake(self.selectButton.right+5, (self.contentView.height - 44) * 0.5, 44, 44);
    self.textLabel.left = self.imageView.right + 16;
    self.flag.centerY = self.contentView.middleY;
    self.flag.left = self.textLabel.right + 5;

    

//    self.textLabel.frame = CGRectMake(self.imageView.right + 16, (self.contentView.height - 22) * 0.5, 70, 22);
}
-(UIImageView *)flag{
    if (!_flag) {
        UIImageView *flag = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        flag.image = [UIImage imageNamed:@"Group 1321315481"];
        [self.contentView addSubview:flag];
        _flag = flag;
    }
    return _flag;
}

- (void)refreshData:(TTeamInviteModel *)model
{
    self.model = model;
    
    self.textLabel.text = model.user.remarkname.length? model.user.remarkname : model.user.nick;
    [self.textLabel sizeToFit];
    
    [self.imageView tio_imageUrl:model.user.avatar placeHolderImageName:@"avatar_placeholder" radius:4];
    
    if (model.status == TCellSelectedStatusDisabled)
    {
        self.selectButton.hidden = YES;
    }
    else
    {
        self.selectButton.hidden = NO;
        self.selectButton.selected = model.status == TCellSelectedStatusSelected;
    }
    self.flag.hidden = true;
    if (model.user.xx ==3 || model.user.officialflag == 1) {
        self.flag.hidden = false;
    }
}

- (void)selectButtonDidClicked:(id)button
{
    self.selectButton.selected = !self.selectButton.selected;
    
    if (self.selectButton.selected)
    {
        self.model.status = TCellSelectedStatusSelected;
    }
    else
    {
        self.model.status = TCellSelectedStatusNone;
    }
    
    if (self.selectedCallback) {
        self.selectedCallback(self.selectButton.selected);
    }
}

@end
