//
//  InvitationCodeVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/22.
//  Copyright © 2024 刘宇. All rights reserved.
//

#import "InvitationCodeVC.h"
#import "FrameAccessor.h"
#import "MineInfoViewController.h"
#import "TMineSettingViewController.h"
#import "TAccountViewController.h"
#import "UIImageView+Web.h"

#import "WalletKit.h"
#import "ImportSDK.h"
#import <UIImageView+WebCache.h>
#import "GFQRCodeVC.h"
#import "ServerConfig.h"
#import "TCommonCell.h"
#import "MBProgressHUD+NJ.h"
@interface InvitationCodeVC ()
@property (weak, nonatomic) IBOutlet UIImageView *headV;
@property (weak, nonatomic) IBOutlet UILabel *codeL;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *codeView;

@property (weak, nonatomic) IBOutlet UIButton *BtnCopy;

@end

@implementation InvitationCodeVC
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.hidden = true;
    [self.headV tio_imageUrl:[TIOChat.shareSDK.loginManager.userInfo avatar] placeHolderImageName:@"avatar_placeholder" radius:30];
    self.codeL.text = [TIOChat.shareSDK.loginManager userInfo].invitecode;
    self.headV.layer.cornerRadius = 30;
    self.headV.layer.borderWidth = 2;
    self.headV.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.backView.layer.cornerRadius = 8;
    self.codeView.layer.cornerRadius = 6;
    self.BtnCopy.layer.cornerRadius = 6;
    
    // 创建NSMutableAttributedString
    // 设置字间距为4.0

    NSString *labelText = self.codeL.text;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(20)}];
     
    // 应用属性字符串到UILabel
    self.codeL.attributedText = attributedString;
}
- (IBAction)copyAction:(id)sender {

    [MBProgressHUD showSuccess:@"已复制到剪切板" toView:self.view];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [TIOChat.shareSDK.loginManager userInfo].invitecode;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
