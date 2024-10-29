//
//  GFWalletViewController.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFWalletViewController.h"
#import "ImportSDK.h"
#import "MBProgressHUD+NJ.h"
#import "GFWalletOrderListVC.h"

@interface GFWalletViewController ()
@property (weak, nonatomic) IBOutlet UILabel *moneyL;
@property (weak, nonatomic) IBOutlet UIButton *cashBtn;
@property (weak, nonatomic) IBOutlet UITextField *moneyTF;
@property (weak, nonatomic) IBOutlet UILabel *tipMoney;
@property (weak, nonatomic) IBOutlet UILabel *tipTitle;
@property (weak, nonatomic) IBOutlet UILabel *tipDetail;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;

@end

@implementation GFWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem *barbutton = [UIBarButtonItem.alloc initWithCustomView:({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"订单" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(orderClick:) forControlEvents:UIControlEventTouchUpInside];
            
            button;
        })];
        
        barbutton;
    });
    self.bottomBtn.layer.cornerRadius = 6;
    [self updateUI];
    [self loadData];
}
-(void)loadData{
    CBWeakSelf
    [MBProgressHUD showLoading:@"" toView:self.view];
    [TIOChat.shareSDK.gfHttpManager accountGetBalanceWithCompletion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
            return;
        }else{
            CGFloat money = [responseObject[@"data"] floatValue];
            self.moneyL.text = [NSString stringWithFormat:@"%0.2f",money];
        }
        
        
    }];
}
-(void)updateUI{
    if (self.type == 1) {
        self.title = @"充值";
        [self.cashBtn setTitle:@"去提现" forState:UIControlStateNormal];
        [self.bottomBtn setTitle:@"立即充值" forState:UIControlStateNormal];
        self.tipMoney.text = @"充值金额";
        self.tipTitle.text = @"充值说明";
        self.tipDetail.text = @"说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明";
    }else if (self.type == 2){
        self.title = @"提现";
        [self.cashBtn setTitle:@"去充值" forState:UIControlStateNormal];
        [self.bottomBtn setTitle:@"立即提现" forState:UIControlStateNormal];
        self.tipMoney.text = @"提现金额";
        self.tipTitle.text = @"提现说明";
        self.tipDetail.text = @"说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明说明";
    }
}
-(void)orderClick:(UIButton *)btn{
    GFWalletOrderListVC *vc = [GFWalletOrderListVC.alloc init];
    [self.navigationController pushViewController:vc animated:true];
}
-(void)changeClick{
    self.type = self.type == 1? 2: 1;
    [self updateUI];
}
- (IBAction)buttonClick:(UIButton *)sender {
    if (sender == self.cashBtn) {
        [self changeClick];
    }else {
        if (self.type == 1) {
            CBWeakSelf
            [MBProgressHUD showLoading:@"" toView:self.view];
            [TIOChat.shareSDK.gfHttpManager accountRechargeMoney:self.moneyTF.text completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
                
                CBStrongSelfElseReturn
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (error) {
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    return;
                }else{
                    [MBProgressHUD showSuccess:@"提交成功" toView:self.view];
                    [self loadData];
                }
                
                
            }];
        }else if (self.type == 2){
            CBWeakSelf
            [MBProgressHUD showLoading:@"" toView:self.view];
            [TIOChat.shareSDK.gfHttpManager accountCashMoney:self.moneyTF.text completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
                CBStrongSelfElseReturn
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (error) {
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    return;
                }else{
                    [MBProgressHUD showSuccess:@"提交成功" toView:self.view ] ;
                }
                
                
            }];
        }
    }
}


@end
