//
//  WalletYearPicker.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/6.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletYearPicker.h"
#import "FrameAccessor.h"
#import "UIView+Popup.h"

@interface WalletYearPickerCell : UITableViewCell
@property (strong,  nonatomic) UIImageView *radioImageView;
@property (assign,  nonatomic) BOOL hasSelected;
@end

@implementation WalletYearPickerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.textLabel.textColor = [UIColor colorWithHex:0x333333];
        
        self.radioImageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 24, 24)];
        [self.contentView addSubview:self.radioImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.textLabel sizeToFit];
    self.textLabel.left = 16;
    self.textLabel.centerY = self.contentView.middleY;
    
    self.radioImageView.right = self.contentView.width - 20;
    self.radioImageView.centerY = self.contentView.middleY;
}

- (void)setHasSelected:(BOOL)hasSelected
{
    _hasSelected = hasSelected;
    
    if (hasSelected) {
        self.radioImageView.image = [UIImage imageNamed:@"wallet_selected"];
    } else {
        self.radioImageView.image = [UIImage imageNamed:@"wallet_unselected"];
    }
}

@end

@interface WalletYearPicker () <UITableViewDelegate, UITableViewDataSource>
@property (strong,  nonatomic) UILabel *titleLabel;
@property (strong,  nonatomic) UITableView *tableView;
@property (strong,  nonatomic) NSArray *items;
@property (strong,  nonatomic) UIView *maskView;
- (void)showOnView:(UIView *)onView;
@end

@implementation WalletYearPicker

- (void)dealloc
{
    NSLog(@"dealloc:%s",__FUNCTION__);
}

+ (instancetype)showItems:(NSArray *)items currentIndex:(NSInteger)currentIndex block:(void (^)(NSInteger))block onView:(UIView *)onView
{
    CGFloat h = items.count>5?(6*50 + 48):(items.count*50 + 48);
    WalletYearPicker *object = [WalletYearPicker.alloc initWithFrame:CGRectMake(0, 0, 280, h) onView:onView items:items];
    object.currentIndex = currentIndex;
    object.ClickBlock = block;
    [object showOnView:onView];
    
    return object;
}

- (instancetype)initWithFrame:(CGRect)frame onView:(UIView *)onView items:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        self.items = items;
        
        self.titleLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame) * 0.7, 48)];
        self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        self.titleLabel.textColor = [UIColor colorWithHex:0x333333];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"选择年份";
        [self addSubview:self.titleLabel];
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame = CGRectMake(12, 8, 33, 33);
        [dismissButton setImage:[UIImage imageNamed:@"w_cancel"] forState:UIControlStateNormal];
        [dismissButton addTarget:self action:@selector(dismissClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismissButton];
        
        self.tableView = [UITableView.alloc initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 50;
        self.tableView.scrollEnabled = items.count > 5;
        self.tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
        [self.tableView registerClass:WalletYearPickerCell.class forCellReuseIdentifier:NSStringFromClass(WalletYearPickerCell.class)];
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.centerX = self.middleX;
    
    self.tableView.frame = CGRectMake(0, 48, self.width, self.height - 48);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WalletYearPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WalletYearPickerCell.class)];
    cell.textLabel.text = self.items[indexPath.row];
    cell.hasSelected = self.currentIndex == indexPath.row;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.currentIndex = indexPath.row;
    [tableView reloadData];
    
    self.ClickBlock(indexPath.row);
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)showOnView:(UIView *)onView
{
    self.maskView = [UIView.alloc initWithFrame:onView.bounds];
    self.maskView.backgroundColor = UIColor.clearColor;
    [onView addSubview:self.maskView];
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    }];
    self.center = onView.middlePoint;
    [onView addSubview:self];
    [self gp_showPopup];
}

- (void)dismissClicked:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.backgroundColor = UIColor.clearColor;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
    
    [self gp_dismissPopup:^{
        [self removeFromSuperview];
    }];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    [self.tableView reloadData];
}

@end
