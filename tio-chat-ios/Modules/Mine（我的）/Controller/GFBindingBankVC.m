//
//  GFBindingBankVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFBindingBankVC.h"

#import "WKWebViewController.h"
#import "TAlertController.h"

@interface GFBindingBankVC ()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@property (weak, nonatomic) IBOutlet UIView *IDView;
@property (weak, nonatomic) IBOutlet UITextField *IDTF;

@property (weak, nonatomic) IBOutlet UIView *bankNumView;
@property (weak, nonatomic) IBOutlet UITextField *bankNumTF;

@property (weak, nonatomic) IBOutlet UIView *bankView;
@property (weak, nonatomic) IBOutlet UITextField *bankTF;

@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;


@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@end

@implementation GFBindingBankVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加银行卡";

    [self borderWithView:self.nameView];
    [self borderWithView:self.IDView];
    [self borderWithView:self.bankNumView];
    [self borderWithView:self.bankView];
    [self borderWithView:self.phoneView];
    self.backView.layer.cornerRadius = 6;
    self.backView.layer.masksToBounds = true;
    [self loadData];
}
-(void)loadData{
    [TIOChat.shareSDK.gfHttpManager  accountGetBnakDetailWithType:@"bank" completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            
        }else{
            self.nameTF.text = responseObject[@"username"];
//            self.IDTF.text = responseObject[@"uid"];
            self.bankNumTF.text = responseObject[@"cardno"];
            self.bankTF.text = responseObject[@"bankname"];
            self.phoneTF.text = responseObject[@"phone"];
        }
    }];
}

-(void)borderWithView:(UIView *)view{
    view.layer.cornerRadius = 6;
    view.layer.masksToBounds = true;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor colorWithHex:0xE6EBF1].CGColor;
}
- (IBAction)submitAction:(id)sender {
    if (self.chooseBtn.isSelected) {
        CBWeakSelf
        [MBProgressHUD showLoading:@"" toView:self.view];
        [TIOChat.shareSDK.gfHttpManager accountBindingWithType:@"bank" cardno:self.bankNumTF.text username:self.nameTF.text image:@"" completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
            
            CBStrongSelfElseReturn
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
                return;
            }else{

            }
            
            
        }];
    }else{
        [MBProgressHUD showError:@"请阅读并同意《支付用户服务协议》《支付隐私政策》" toView:self.view];
    }
}
- (IBAction)chooseAction:(id)sender {
    self.chooseBtn.selected = !self.chooseBtn.isSelected;
}

- (IBAction)xyAction:(id)sender {
    WKWebViewController *web = [WKWebViewController.alloc init];
    web.urlString = @"https://merchant.5upay.com/webox/agreement/serviceAgreement.html";
    [self.navigationController pushViewController:web animated:YES];
}
- (IBAction)ysAction:(id)sender {
    WKWebViewController *web = [WKWebViewController.alloc init];
    web.urlString = @"https://merchant.5upay.com/webox/agreement/privacyPolicy.html";
    [self.navigationController pushViewController:web animated:YES];
}
@end
