//
//  GFWallterPwdSettingVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/11/3.
//  Copyright © 2024 wgf. All rights reserved.
//



#import "GFWallterPwdSettingVC.h"
// 外部
#import "FrameAccessor.h"
#import <M80AttributedLabel.h>
#import "ImportSDK.h"
#import "WKWebViewController.h"
#import "UIImage+TColor.h"
#import "MBProgressHUD+NJ.h"
#import "CBMobileValidator.h"
// 内部
#import "TMineWalletViewController.h"
#import "NWHomeViewController.h"

#import "NWSettingPayPasswordVC.h"

@interface GFWallterPwdSettingVC ()<M80AttributedLabelDelegate>
@property (nonatomic,   weak) UIButton *authorButton;
@property (nonatomic,   weak) UITextField *phoneTF;
@property (nonatomic,   weak) UITextField *nameTF;
@property (nonatomic,   weak) UITextField *cardTF;
@end

@implementation GFWallterPwdSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = @"账户开通";
    self.navigationBar.titleL.text = @"账户开通";
    [self setupUI];
}

- (void)setupUI
{
//    self.view.backgroundColor = UIColor.whiteColor;
    
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectZero];
    titleLabel.text = @"季风钱包账户开通说明";
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    titleLabel.textColor = [UIColor colorWithHex:0x9199A4];
    [titleLabel sizeToFit];
    titleLabel.viewOrigin = CGPointMake(16, Height_NavBar + 35);
    [self.view addSubview:titleLabel];
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(16, titleLabel.bottom+7, ScreenWidth()-32, 469)];
    backView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:backView];
    backView.layer.cornerRadius = 6;
    backView.layer.masksToBounds = true;
    
    UILabel *conLabel = [UILabel.alloc init];
    conLabel.numberOfLines = 0;
    conLabel.attributedText = ({
        
        NSDictionary *attr1 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont systemFontOfSize:14 weight:UIFontWeightBold]};
        NSDictionary *attr2 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x0087FC], NSFontAttributeName:[UIFont systemFontOfSize:14 weight:UIFontWeightBold]};
        
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
        
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"钱包由" attributes:attr1]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"X支付" attributes:attr2]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"提供，季风将向X支付提供 您的个人身份信息，用于开通X支付账号。如您同意开通，请点击" attributes:attr1]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"【同意授权】" attributes:attr2]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"按钮，如您不同意，请不要进行同意授权操作。" attributes:attr1]];
        
        aString;
    });
    
    CGSize size = [conLabel.attributedText boundingRectWithSize:CGSizeMake(ScreenWidth()-70, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    conLabel.frame = CGRectMake(15, 22, size.width, size.height);
    
    [backView addSubview:conLabel];
    
    
    
    // 密码
    UILabel *nameLabel = [UILabel.alloc initWithFrame:CGRectZero];
    nameLabel.text = @"密码";
    nameLabel.textColor = [UIColor colorWithHex:0x666666];
    nameLabel.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightMedium];
    [nameLabel sizeToFit];
    nameLabel.left = 20;
    nameLabel.top = 144;
    [backView addSubview:nameLabel];
    
    UITextField *nameTF = [UITextField.alloc initWithFrame:CGRectMake(20, nameLabel.bottom+6, self.view.width - 70, 48)];
    nameTF.layer.borderWidth = 1;
    nameTF.layer.borderColor = [UIColor colorWithHex:0xE8E8E8].CGColor;
    nameTF.layer.cornerRadius = 4;
    nameTF.layer.masksToBounds = YES;
    nameTF.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightBold];
    nameTF.placeholder = @"请输入支付密码";
    nameTF.keyboardType = UIKeyboardTypeNumberPad;
    nameTF.leftViewMode = UITextFieldViewModeAlways;
    nameTF.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 7, 36)];
    [backView addSubview:nameTF];
    self.nameTF = nameTF;
    
    // 确认密码
    UILabel *idcardLabel = [UILabel.alloc initWithFrame:CGRectZero];
    idcardLabel.text = @"确认密码";
    idcardLabel.textColor = [UIColor colorWithHex:0x666666];
    idcardLabel.font = [UIFont systemFontOfSize:14.f];
    [idcardLabel sizeToFit];
    idcardLabel.left = 20;
    idcardLabel.top = nameTF.bottom + 18;
    [backView addSubview:idcardLabel];
    
    UITextField *idcardTF = [UITextField.alloc initWithFrame:CGRectMake(20, idcardLabel.bottom+6, self.view.width - 70, 48)];
    idcardTF.layer.borderWidth = 1;
    idcardTF.layer.borderColor = [UIColor colorWithHex:0xE8E8E8].CGColor;
    idcardTF.layer.cornerRadius = 4;
    idcardTF.layer.masksToBounds = YES;
    idcardTF.keyboardType = UIKeyboardTypeNumberPad;
    idcardTF.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightBold];
    idcardTF.placeholder = @"请请再次确认支付密码";
    idcardTF.leftViewMode = UITextFieldViewModeAlways;
    idcardTF.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 7, 36)];
    [backView addSubview:idcardTF];
    self.cardTF = idcardTF;
    
//    // 本人手机号
//    UILabel *phoneLabel = [UILabel.alloc initWithFrame:CGRectZero];
//    phoneLabel.text = @"本人手机号";
//    phoneLabel.textColor = [UIColor colorWithHex:0x666666];
//    phoneLabel.font = [UIFont systemFontOfSize:14.f];
//    [phoneLabel sizeToFit];
//    phoneLabel.right = 88;
//    phoneLabel.top = idcardLabel.bottom + 26;
//    [self.view addSubview:phoneLabel];
//
//    UITextField *phoneTF = [UITextField.alloc initWithFrame:CGRectMake(phoneLabel.right+4, 0, self.view.width - phoneLabel.right - 4 - 60, 36)];
//    phoneTF.centerY = phoneLabel.centerY;
//    phoneTF.layer.borderWidth = 1;
//    phoneTF.layer.borderColor = [UIColor colorWithHex:0xE8E8E8].CGColor;
//    phoneTF.layer.cornerRadius = 4;
//    phoneTF.layer.masksToBounds = YES;
////    phoneTF.placeholder = @"请填写本人实名手机号";
//    phoneTF.text = TIOChat.shareSDK.loginManager.userInfo.phone;
//    phoneTF.enabled  = NO;
//    phoneTF.keyboardType = UIKeyboardTypePhonePad;
//    phoneTF.font = [UIFont systemFontOfSize:14.f];
//    phoneTF.leftViewMode = UITextFieldViewModeAlways;
//    phoneTF.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 7, 36)];
//    [self.view addSubview:phoneTF];
//    self.phoneTF = phoneTF;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 0, ScreenWidth()-72, 48);
//    button.centerX = backView.middleX;
    button.top = self.cardTF.bottom + 50;
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    button.enabled = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] forState:UIControlStateNormal];
    [button setTitle:@"同意授权" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickedAuthor:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:button];
    self.authorButton = button;
    
    // 同意协议
    M80AttributedLabel *protocolLabel = [M80AttributedLabel.alloc init];
    [protocolLabel appendView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 17, 17);
        [button setImage:[UIImage imageNamed:@"reg_selected"] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"un_select"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(agreementClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
    [protocolLabel appendText:@" 已阅读同意《支付用户服务协议》和《支付隐私政策》"];
    protocolLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    protocolLabel.textColor = [UIColor colorWithHex:0x999999];
    protocolLabel.delegate = self;
    [protocolLabel addCustomLink:@(2) forRange:NSMakeRange(7, 10) linkColor:[UIColor colorWithHex:0x54A7F8]];
    [protocolLabel addCustomLink:@(3) forRange:NSMakeRange(18, 8) linkColor:[UIColor colorWithHex:0x54A7F8]];
    [protocolLabel sizeToFit];
    protocolLabel.viewOrigin = CGPointMake(16, self.authorButton.bottom + 13);
    [backView addSubview:protocolLabel];
    

}

#pragma mark - Actions

- (void)agreementClicked:(UIButton *)button
{
    button.selected = !button.selected;
    self.authorButton.enabled = button.selected;
}

- (void)didClickedAuthor:(UIButton *)button
{
    if (![self.nameTF.text isEqualToString:self.cardTF.text]) {
        [MBProgressHUD showError:@"密码不一致" toView:self.view];
        return;
    }
    CBWeakSelf
    [MBProgressHUD showLoading:@"" toView:self.view];
    [TIOChat.shareSDK.gfHttpManager accountSetPayPassword:self.nameTF.text completion :^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
            return;
        }else{
            // 更新用户信息
            [MBProgressHUD showMessage:@"设置成功" toView:self.view];
            [TIOChat.shareSDK.loginManager updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
                [self.navigationController popViewControllerAnimated:true];
                if (self.changeBlock) {
                    self.changeBlock();
                }
            }];

        }
        
        
    }];
}

#pragma mark - 唤醒微包

-(void)evoke_safe:(NSString *)token walletid:(NSString *)walletid {
   
}


#pragma mark M80AttributedLabelDelegate

- (void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(id)linkData
{
    if ([linkData isEqualToNumber:@(1)]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([linkData isEqualToNumber:@(2)]) {
        WKWebViewController *web = [WKWebViewController.alloc init];
        web.urlString = @"https://merchant.5upay.com/webox/agreement/serviceAgreement.html";
        [self.navigationController pushViewController:web animated:YES];
    } else {
        WKWebViewController *web = [WKWebViewController.alloc init];
        web.urlString = @"https://merchant.5upay.com/webox/agreement/privacyPolicy.html";
        [self.navigationController pushViewController:web animated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end

