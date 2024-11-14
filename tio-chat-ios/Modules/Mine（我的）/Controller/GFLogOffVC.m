//
//  GFLogOffVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/27.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFLogOffVC.h"
#import "MBProgressHUD+NJ.h"
#import "TAlertController.h"

/// SDK
#import "ImportSDK.h"

@interface GFLogOffVC ()
@property (weak, nonatomic) IBOutlet UIButton *logoffBtn;

@end

@implementation GFLogOffVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注销账号";
    self.logoffBtn.layer.cornerRadius = 6;
}
- (IBAction)logOffAction:(UIButton *)sender {
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"确定注销当前帐号？" preferredStyle:TAlertControllerStyleAlert];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"退出" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        [MBProgressHUD showLoading:@"正在注销" toView:self.view];
        [TIOChat.shareSDK.loginManager logoff:^(NSError * _Nullable error) {
            
            [MBProgressHUD hideHUDForView:self.view];
            if (error) {
                [MBProgressHUD showError:error.localizedDescription];
            }
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
