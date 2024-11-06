//
//  TWalletAuthorizationVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/10/29.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TWalletAuthorizationVC.h"

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
#import "EHKWeboxManager.h"
#import "utils.h"

@interface TWalletAuthorizationVC () <M80AttributedLabelDelegate>
@property (nonatomic,   weak) UIButton *authorButton;
@property (nonatomic,   weak) UITextField *phoneTF;
@property (nonatomic,   weak) UITextField *nameTF;
@property (nonatomic,   weak) UITextField *cardTF;
@end

@implementation TWalletAuthorizationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectZero];
    titleLabel.text = @"季风钱包账户开通说明";
    titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    [titleLabel sizeToFit];
    titleLabel.viewOrigin = CGPointMake(16, Height_NavBar + 10);
    [self.view addSubview:titleLabel];
    
    
    UILabel *conLabel = [UILabel.alloc init];
    conLabel.numberOfLines = 0;
    conLabel.attributedText = ({
        
        NSDictionary *attr1 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont systemFontOfSize:16  weight:UIFontWeightMedium]};
        NSDictionary *attr2 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightBold]};
        
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
        
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"季风钱包由" attributes:attr1]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"首信易支付" attributes:attr2]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"提供，季风将向首信易支付提供您的个人身份信息，用于开通首信易支付账号。\n如您同意开通，请点击" attributes:attr1]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"【同意授权】" attributes:attr2]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"按钮，如您不同意，请不要进行同意授权操作。" attributes:attr1]];
        
        aString;
    });
    
    CGSize size = [conLabel.attributedText boundingRectWithSize:CGSizeMake(ScreenWidth()-32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    conLabel.frame = CGRectMake(16, titleLabel.bottom+20, size.width, size.height);
    
    [self.view addSubview:conLabel];
    
    // 姓名
    UILabel *nameLabel = [UILabel.alloc initWithFrame:CGRectZero];
    nameLabel.text = @"姓名";
    nameLabel.textColor = [UIColor colorWithHex:0x666666];
    nameLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    [nameLabel sizeToFit];
    nameLabel.right = 88;
    nameLabel.top = conLabel.bottom + 28;
    [self.view addSubview:nameLabel];
    
    UITextField *nameTF = [UITextField.alloc initWithFrame:CGRectMake(nameLabel.right+4, 0, self.view.width - nameLabel.right - 4 - 60, 36)];
    nameTF.centerY = nameLabel.centerY;
    nameTF.layer.borderWidth = 1;
    nameTF.layer.borderColor = [UIColor colorWithHex:0xE8E8E8].CGColor;
    nameTF.layer.cornerRadius = 4;
    nameTF.layer.masksToBounds = YES;
    nameTF.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    nameTF.placeholder = @"请输入本人真实姓名";
    nameTF.leftViewMode = UITextFieldViewModeAlways;
    nameTF.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 7, 36)];
    [self.view addSubview:nameTF];
    self.nameTF = nameTF;
    
    // 身份证号
    UILabel *idcardLabel = [UILabel.alloc initWithFrame:CGRectZero];
    idcardLabel.text = @"身份证号";
    idcardLabel.textColor = [UIColor colorWithHex:0x666666];
    idcardLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    [idcardLabel sizeToFit];
    idcardLabel.right = 88;
    idcardLabel.top = nameLabel.bottom + 26;
    [self.view addSubview:idcardLabel];
    
    UITextField *idcardTF = [UITextField.alloc initWithFrame:CGRectMake(idcardLabel.right+4, 0, self.view.width - idcardLabel.right - 4 - 60, 36)];
    idcardTF.centerY = idcardLabel.centerY;
    idcardTF.layer.borderWidth = 1;
    idcardTF.layer.borderColor = [UIColor colorWithHex:0xE8E8E8].CGColor;
    idcardTF.layer.cornerRadius = 4;
    idcardTF.layer.masksToBounds = YES;
    idcardTF.placeholder = @"请输入本人身份证号";
    idcardTF.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    idcardTF.leftViewMode = UITextFieldViewModeAlways;
    idcardTF.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 7, 36)];
    [self.view addSubview:idcardTF];
    self.cardTF = idcardTF;
    
    // 本人手机号
    UILabel *phoneLabel = [UILabel.alloc initWithFrame:CGRectZero];
    phoneLabel.text = @"本人手机号";
    phoneLabel.textColor = [UIColor colorWithHex:0x666666];
    phoneLabel.font = [UIFont systemFontOfSize:15.f  weight:UIFontWeightMedium];
    [phoneLabel sizeToFit];
    phoneLabel.right = 88;
    phoneLabel.top = idcardLabel.bottom + 26;
    [self.view addSubview:phoneLabel];
    
    UITextField *phoneTF = [UITextField.alloc initWithFrame:CGRectMake(phoneLabel.right+4, 0, self.view.width - phoneLabel.right - 4 - 60, 36)];
    phoneTF.centerY = phoneLabel.centerY;
    phoneTF.layer.borderWidth = 1;
    phoneTF.layer.borderColor = [UIColor colorWithHex:0xE8E8E8].CGColor;
    phoneTF.layer.cornerRadius = 4;
    phoneTF.layer.masksToBounds = YES;
//    phoneTF.placeholder = @"请填写本人实名手机号";
    phoneTF.text = TIOChat.shareSDK.loginManager.userInfo.phone;
    phoneTF.enabled  = NO;
    phoneTF.keyboardType = UIKeyboardTypePhonePad;
    phoneTF.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    phoneTF.leftViewMode = UITextFieldViewModeAlways;
    phoneTF.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 7, 36)];
    [self.view addSubview:phoneTF];
    self.phoneTF = phoneTF;
    
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
    protocolLabel.font = [UIFont systemFontOfSize:13];
    protocolLabel.textColor = [UIColor colorWithHex:0x999999];
    protocolLabel.delegate = self;
    [protocolLabel addCustomLink:@(2) forRange:NSMakeRange(7, 10) linkColor:[UIColor colorWithHex:0x0087FC]];
    [protocolLabel addCustomLink:@(3) forRange:NSMakeRange(18, 8) linkColor:[UIColor colorWithHex:0x0087FC]];
    [protocolLabel sizeToFit];
    protocolLabel.viewOrigin = CGPointMake(16, phoneTF.bottom + 36);
    [self.view addSubview:protocolLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, ScreenWidth()-30, 48);
    button.centerX = self.view.middleX;
    button.top = protocolLabel.bottom + 50;
    button.layer.cornerRadius = 6;
    button.layer.masksToBounds = YES;
    button.enabled = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:18  weight:UIFontWeightBold];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] forState:UIControlStateNormal];
    [button setTitle:@"同意授权" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickedAuthor:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.authorButton = button;
}

#pragma mark - Actions

- (void)agreementClicked:(UIButton *)button
{
    button.selected = !button.selected;
    self.authorButton.enabled = button.selected;
}

- (void)didClickedAuthor:(UIButton *)button
{
    
#pragma mark - test -
    
//    CBWeakSelf
//    [TIOChat.shareSDK.walletManager fetchSafeTokenWithUid:@"" walletid:walletId completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
//        CBStrongSelfElseReturn
//        NSString *token = responseObject[@"token"];
//        [self evoke_safe:token walletid:walletId];
//    }];
//
//
//    return;;
    
    
    
    NSError *error = nil;
    if (![CBMobileValidator validateText:self.phoneTF.text error:&error]) {
        [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
        return;
    }
    
    NSString *uid = [TIOChat.shareSDK.loginManager.userInfo userId];
    NSString *nick = [TIOChat.shareSDK.loginManager.userInfo nick];
    
    CBWeakSelf
    /// 开户：开户成功就会收到生成一个钱包ID，开户状态也会变成已开户
    [TIOChat.shareSDK.walletManager openAccount:uid name:self.nameTF.text phone:self.phoneTF.text idcard:self.cardTF.text nick:nick mac:@"" completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        NSLog(@"开户");
        
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
        else
        {
            // 更新用户信息
            [TIOChat.shareSDK.loginManager updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            }];
            
//            [MBProgressHUD showInfo:@"已经同意授权" toView:self.view];
//
//            CBWeakSelf
//
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//                CBStrongSelfElseReturn
//
//                TMineWalletViewController *nextVC = [TMineWalletViewController.alloc init];
//                [self.navigationController pushViewController:nextVC animated:YES];
//
//                NSArray *tempVCs = [self.navigationController.viewControllers subarrayWithRange:NSMakeRange(0, self.navigationController.viewControllers.count-2)];
//                [self.navigationController setViewControllers:[tempVCs arrayByAddingObject:nextVC]];
//
//            });
            NSString *uid = [TIOChat.shareSDK.loginManager.userInfo userId];
            NSString *walletId = responseObject[@"walletId"];

            if (walletId) {
                
                CBWeakSelf
                [TIOChat.shareSDK.walletManager fetchSafeTokenWithUid:uid walletid:walletId completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
                    CBStrongSelfElseReturn
                    NSString *token = responseObject[@"token"];
                    [self evoke_safe:token walletid:walletId];
                }];
            }
        }
        
    }];
}

#pragma mark - 唤醒微包

-(void)evoke_safe:(NSString *)token walletid:(NSString *)walletid {
    CBWeakSelf
    EHKWeboxManager * wallet = [EHKWeboxManager instanceManager];
    [utils configuration:wallet walletid:walletid token:token businessCode:EHKWEBOX_BUSINESSCODE_SETTING vc:self];
    
    [wallet evoke:^(EHKWeboxManager * _Nonnull wallet, EHKWeboxStatus status) {
        self.navigationController.navigationBarHidden = YES;
        CBStrongSelfElseReturn
        /// 重新获取钱包信息，查看是否完成密码设置，是的话，进入钱包主页
        [self handler:wallet.walletId];
    }];
}

- (void)handler:(NSString *)walletid
{
    NSString *uid = TIOChat.shareSDK.loginManager.userInfo.userId;
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchWalletDetailWithUid:uid walletid:walletid completion:^(TIOWallet * _Nullable wallet, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (!error) {
            if (wallet.setUpPasswrod) {
                /// 已经设置初始密码
                /// 进入下一页：钱包主页
                TMineWalletViewController *nextVC = [TMineWalletViewController.alloc init];
                nextVC.uid = uid;
                nextVC.walletid = walletid;
                [self.navigationController pushViewController:nextVC animated:YES];
                
                NSArray *tempVCs = [self.navigationController.viewControllers subarrayWithRange:NSMakeRange(0, self.navigationController.viewControllers.count-2)];
                [self.navigationController setViewControllers:[tempVCs arrayByAddingObject:nextVC]];
            }
        }
    }];
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
