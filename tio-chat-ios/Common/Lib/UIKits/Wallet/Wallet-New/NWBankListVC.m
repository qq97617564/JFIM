//
//  NWBankListVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/3.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWBankListVC.h"
#import "FrameAccessor.h"
#import "NWBankCard.h"
#import "NWAddBankCard.h"
#import "UIImage+TColor.h"
#import "TAlertController.h"
#import "MBProgressHUD+NJ.h"
#import "ImportSDK.h"
#import "UIImageView+Web.h"
#import "NSObject+CBJSONSerialization.h"

#import "NWSettingPayPasswordVC.h"
#import "NWBindNewCardVC.h"
#import "NWPaymentObject.h"

@interface NWBankListVC () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak,    nonatomic) UICollectionView *collectionView;
@property (strong,  nonatomic) NSArray<NWPaymentObject *> *dataArray;
@end

@implementation NWBankListVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"我的银行卡";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self requestData];
}

- (void)setupUI
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
    layout.itemSize = CGSizeMake(CB_SCREEN_WIDTH-40, 120);
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    layout.sectionHeadersPinToVisibleBounds = NO;

    UICollectionView *collectionview = [[UICollectionView alloc]initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height-Height_NavBar) collectionViewLayout:layout];
    collectionview.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    collectionview.delegate = self;
    collectionview.dataSource = self;
//    [collectionview registerClass:[NWAddBankCard class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"NWAddBankCard"];
    [collectionview registerClass:[NWAddBankCard class] forCellWithReuseIdentifier:@"NWAddBankCard"];
    [collectionview registerClass:[NWBankCard class] forCellWithReuseIdentifier:@"NWBankCard"];
    [self.view addSubview:collectionview];
    self.collectionView = collectionview;
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchBankCardList:^(NSArray * _Nullable responObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:responObject.count];
        for (TIOBankCard *card in responObject) {
            [array addObject:[NWPaymentObject.alloc initWithModel:card]];
        }
        self.dataArray = array;
        [self.collectionView reloadData];
    }];
}

#pragma mark - UICollectionView

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NWAddBankCard *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NWAddBankCard" forIndexPath:indexPath];
        return cell;
    } else {
        
        NWPaymentObject *object = self.dataArray[indexPath.row];
        
        id<NWPaymentChannel> model = object;
        
        UIImage *bgImage = [UIImage imageWithColor:[UIColor colorWithHexString:model.back_color]];
        bgImage = [bgImage imageWithCornerRadius:4 size:CGSizeMake(CB_SCREEN_WIDTH-40, 120)];
        
        NWBankCard *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NWBankCard" forIndexPath:indexPath];
        cell.bg.image = bgImage;
        [cell.watermark tio_imageUrl:model.waterImageUrl placeHolderImageName:@"" radius:0];
        [cell.icon tio_imageUrl:model.iconUrl placeHolderImageName:@"" radius:0];
        cell.nameLabel.text = model.name;
        
        cell.cardNoLabel.text = model.backFourCardNo;
        
        return cell;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return section == 0 ? 1 : self.dataArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
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
                    /// 绑卡完成
                    /// 刷新当前页面的银行卡列表
                    [self requestData];
                };
                [vController.navigationController pushViewController:vc animated:YES];
                
                NSArray *vcs = vController.navigationController.viewControllers;
                NSArray *tempVcs = [vcs subarrayWithRange:NSMakeRange(0, vcs.count - 2)];
                NSArray *nVcs = [tempVcs arrayByAddingObject:vc];
                [vc.navigationController setViewControllers:nVcs];
            }
        };
        [self.navigationController pushViewController:pwdVC animated:YES];
    } else {
        
        id<NWPaymentChannel> model = self.dataArray[indexPath.row];
        
        TAlertController *alert = [TAlertController.alloc initWithHeaderView:({
            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
            view.backgroundColor = UIColor.whiteColor;

            UILabel *bankLabel = [UILabel.alloc init];
            bankLabel.text = [NSString stringWithFormat:@"%@（%@）",model.name, model.backFourCardNo];
            bankLabel.textColor = [UIColor colorWithHex:0x333333];
            bankLabel.font = [UIFont systemFontOfSize:16];
            [bankLabel sizeToFit];
            bankLabel.left = 16;
            bankLabel.centerY = view.middleY;
            [view addSubview:bankLabel];

            UILabel *typeLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 50, 17)];
            typeLabel.text = @"储蓄卡";
            typeLabel.font = [UIFont systemFontOfSize:12];
            typeLabel.textColor = [UIColor colorWithHex:0x666666];
            typeLabel.textAlignment = NSTextAlignmentLeft;
            typeLabel.left = bankLabel.right + 5;
            typeLabel.centerY = view.middleY;
            [view addSubview:typeLabel];

            view;
        })];
        CBWeakSelf
        [alert addAction:[TAlertAction actionWithTitle:@"解除绑定" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            CBStrongSelfElseReturn
            NWSettingPayPasswordVC *vc = [NWSettingPayPasswordVC.alloc initWithTitle:@"解绑银行卡" code:NWPayPasswordCodeAuthorization];
            CBWeakSelf
            vc.handler = ^(UIViewController * _Nonnull vController, BOOL re, NSString *pwd) {
                CBStrongSelfElseReturn
                if (re) {
                    
                    /// SDK API 解绑
                    [MBProgressHUD showLoading:@"" toView:vController.view];
                    [TIOChat.shareSDK.walletManager unbindBankCard:model.channelId agreementNo:model.agreementNo pwd:pwd completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
                        [MBProgressHUD hideHUDForView:vController.view animated:YES];
                        if (error) {
                            [MBProgressHUD showError:error.localizedDescription toView:self.view];
                        } else {
                            /// 刷新银行卡列表的数据
                            [self requestData];
                            
                            [MBProgressHUD showInfo:@"解绑成功" toView:vController.view];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                /// 从密码身份验证页返回本页（银行卡列表页）
                                [vController.navigationController popViewControllerAnimated:YES];
                            });
                        }
                    }];
                    
                }
            };
            
            [self.navigationController pushViewController:vc animated:YES];
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UICollectionViewLayout

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

/// item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CB_SCREEN_WIDTH-40, 120);
}
/// 最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0) {
        return UIEdgeInsetsMake(20, 20, 10, 20);
    }
    return UIEdgeInsetsMake(10, 20, 20, 20);
}

@end
