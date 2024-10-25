//
//  WalletDetailsContainer.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWaterListContainer.h"
#import "WalletWaterListPage.h"
#import "WalletWaterRechargeViewController.h"

@interface WalletWaterListContainer ()
@property (nonatomic, strong) JXCategoryTitleView *myCategoryView;
@end

@implementation WalletWaterListContainer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.leftBarButtonText = @"钱包明细";
    }
    return self;
}

- (void)viewDidLoad {
    if (self.titles == nil) {
        self.titles = @[@"全部",@"充值",@"提现",@"红包"];
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI
{
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorWidth = 17;
    lineView.indicatorHeight = 1;
    lineView.indicatorColor = [UIColor colorWithHex:0x4C94FF];
    self.myCategoryView.indicators = @[lineView];
    self.myCategoryView.titleColorGradientEnabled = YES;
    self.myCategoryView.cellWidthZoomEnabled = YES;
    self.myCategoryView.cellWidthZoomScale = 1;
    self.myCategoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleBottom;
    self.myCategoryView.selectedAnimationEnabled = YES;
    self.myCategoryView.titleLabelZoomSelectedVerticalOffset = 0;
    self.myCategoryView.titleSelectedFont = [UIFont systemFontOfSize:16];
    self.myCategoryView.titleSelectedColor = [UIColor colorWithHex:0x4C94FF];
    self.myCategoryView.titleFont = [UIFont systemFontOfSize:16];
    self.myCategoryView.titleColor = [UIColor colorWithHex:0x888888];
        
    self.myCategoryView.titles = self.titles;
}

#pragma mark - overwrite

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index
{
    WalletWaterListPage *vc = [WalletWaterListPage.alloc init];
    if (index == 0) {
        vc.waterRequestType = TIOWalletWaterRequestTypeAll;
    } else if (index == 1) {
        vc.waterRequestType = TIOWalletWaterRequestTypeRecharge;
    } else if (index == 2) {
        vc.waterRequestType = TIOWalletWaterRequestTypeWithdraw;
    } else {
        vc.waterRequestType = TIOWalletWaterRequestTypeRed;
    }
    return vc;
}

- (JXCategoryTitleView *)myCategoryView {
    return (JXCategoryTitleView *)self.categoryView;
}

- (JXCategoryBaseView *)preferredCategoryView {
    return [[JXCategoryTitleView alloc] init];
}

- (CGFloat)preferredCategoryViewHeight
{
    return 34;
}

@end
