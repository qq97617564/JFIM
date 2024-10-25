//
//  NWMyBankPicker.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/4.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWPayChannelPicker.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

#import "NWBindNewCardVC.h"
#import "NWSettingPayPasswordVC.h"

@interface NWPayChannelCell : UITableViewCell
@property (weak,    nonatomic) UIImageView *logo;
@end

@implementation NWPayChannelCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImageView *logo = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 27, 27)];
        [self.contentView addSubview:logo];
        self.logo = logo;
        
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = [UIColor colorWithHex:0x333333];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.logo.left = 15;
    self.logo.centerY = self.contentView.middleY;
    self.textLabel.left = 48;
}

@end


@interface NWPayChannelPicker()<UITableViewDelegate, UITableViewDataSource>
@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) UIView *maskView;
@property (strong,  nonatomic) NSArray<id<NWPaymentChannel>> *items;
@property (copy,    nonatomic) void(^callback)(NSDictionary * _Nullable, NSError * _Nullable);
@end

@implementation NWPayChannelPicker

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 395 + safeBottomHeight)];
    if (self) {
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        /// 头部标题 选择支付
        UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, self.width, 35)];
        titleLabel.backgroundColor = UIColor.whiteColor;
        titleLabel.textColor = [UIColor colorWithHex:0x666666];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, 35, self.width, 300) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 60;
        tableView.separatorInset = UIEdgeInsetsMake(0, 17, 0, 0);
        tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
        [tableView registerClass:NWPayChannelCell.class forCellReuseIdentifier:NSStringFromClass(NWPayChannelCell.class)];
        [self addSubview:tableView];
        self.tableView = tableView;
        
        UIView *line2 = [UIView.alloc initWithFrame:CGRectMake(0, tableView.bottom-0.5, self.width, 0.5)];
        line2.backgroundColor = [UIColor colorWithHex:0xF5F5F5];
        [self addSubview:line2];
        
        UIButton *addNewCard = [UIButton buttonWithType:UIButtonTypeCustom];
        addNewCard.backgroundColor = UIColor.whiteColor;
        addNewCard.frame = CGRectMake(0, line2.bottom, self.width, self.height - line2.bottom - safeBottomHeight);
        [addNewCard setImage:[UIImage imageNamed:@"add_bank"] forState:UIControlStateNormal];
        [addNewCard setTitle:@"添加新的银行卡" forState:UIControlStateNormal];
        [addNewCard setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
        [addNewCard.titleLabel setFont:[UIFont systemFontOfSize:14]];
        addNewCard.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        addNewCard.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
        [addNewCard addTarget:self action:@selector(bindCard:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addNewCard];
        
        if (safeBottomHeight > 0) {
            UIView *safeView = [UIView.alloc initWithFrame:CGRectMake(0, self.height - safeBottomHeight, self.width, safeBottomHeight)];
            safeView.backgroundColor = UIColor.whiteColor;
            [self addSubview:safeView];
        }
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NWPaymentChannel> model = self.items[indexPath.row];
    
    NWPayChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(NWPayChannelCell.class)];
    
    /// 优先显示本地银行logo
    if (model.iconImage) {
        cell.logo.image = model.iconImage;
    } else {
        [cell.logo tio_imageUrl:model.iconUrl placeHolderImageName:@"" radius:0];
    }
    
    NSString *text = @"";
    if (model.type == NWPaymentTypeDepositCard) {
        text = [NSString stringWithFormat:@"%@（%@）",model.name, model.backFourCardNo];
    } else if (model.type == NWPaymentTypeCreditCard) {
        text = [NSString stringWithFormat:@"%@（%@）",model.name, model.backFourCardNo];
    } else {
        text = [NSString stringWithFormat:@"钱包（¥%.2f）", model.amount/100.f];
    }
    cell.textLabel.text = text;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<NWPaymentChannel> model = self.items[indexPath.row];
    [self dismiss:^{
        if (self.callback) {
            self.callback(@{@"result" : model}, nil);
        }
    }];
}

- (void)bindCard:(id)sender
{
    CBWeakSelf
    /// 先去验证身份
    NWSettingPayPasswordVC *pwdVC = [NWSettingPayPasswordVC.alloc initWithTitle:@"添加银行卡" code:NWPayPasswordCodeAuthorization];
    pwdVC.handler = ^(UIViewController * _Nonnull vController, BOOL re, NSString *pwd) {
        CBStrongSelfElseReturn
        if (!re) {
            [vController.navigationController popViewControllerAnimated:YES];
        } else {
            CBWeakSelf
            /// 验证通过，去绑定页
            NWBindNewCardVC *vc = [NWBindNewCardVC.alloc init];
            vc.completion = ^(NSDictionary * _Nonnull result) {
                CBStrongSelfElseReturn
                if ([result[@"result"] boolValue]) {
                    if (self.bindNewCard) {
                        self.bindNewCard(self, ^(NSArray<id<NWPaymentChannel>> * _Nonnull data) {
                            self.items = data;
                            [self.tableView reloadData];
                        });
                    }
                }
            };
            [vController.navigationController pushViewController:vc animated:YES];
            
            NSArray *vcs = vController.navigationController.viewControllers;
            NSArray *tempVcs = [vcs subarrayWithRange:NSMakeRange(0, vcs.count - 2)];
            NSArray *nVcs = [tempVcs arrayByAddingObject:vc];
            [vc.navigationController setViewControllers:nVcs];
        }
    };
    [[self topViewController].navigationController pushViewController:pwdVC animated:YES];
}

#pragma mark - Public

- (void)showOnView:(UIView *)onView items:(NSArray<id<NWPaymentChannel>> *)items callBack:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))callback
{
    self.items = items;
    self.callback = callback;
    [self showOnView:onView];
}

- (void)showOnView:(UIView *)onView
{
    self.maskView = [UIView.alloc initWithFrame:onView.bounds];
    self.maskView.backgroundColor = UIColor.clearColor;
    [onView addSubview:self.maskView];
    
    self.top = onView.height;
    self.centerX = onView.middleX;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        self.bottom = onView.height;
    }];
    [onView addSubview:self];
}

- (void)dismiss:(void(^)(void))completion
{
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.backgroundColor = UIColor.clearColor;
        self.top = CGRectGetMaxY(self.frame);
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self removeFromSuperview];
        completion();
    }];
}

// 获取最上面的VC

- (UIViewController*)topVC:(UIViewController*)VC {

    if([VC isKindOfClass:[UINavigationController class]]) {

        return[self topVC:[(UINavigationController*)VC topViewController]];

    }

    if([VC isKindOfClass:[UITabBarController class]]) {

        return[self topVC:[(UITabBarController*)VC selectedViewController]];

    }

    return VC;

}

 

- (UIViewController*)topViewController {

    UIViewController*vc = [self topVC:[UIApplication sharedApplication].keyWindow.rootViewController];

    while(vc.presentedViewController) {

        vc = [self topVC:vc];

    }

    return vc;

}

@end
