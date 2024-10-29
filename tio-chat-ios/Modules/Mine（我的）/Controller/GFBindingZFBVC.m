//
//  GFBindingZFBVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFBindingZFBVC.h"

#import "WKWebViewController.h"
#import "TAlertController.h"

@interface GFBindingZFBVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSString *imageUrl;
}
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIView *zfbView;
@property (weak, nonatomic) IBOutlet UITextField *zfbTF;

@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImgV;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@end

@implementation GFBindingZFBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加支付宝";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseImage)];
    self.QRCodeImgV.userInteractionEnabled = true;
    [self.QRCodeImgV addGestureRecognizer:tap];
    [self borderWithView:self.nameView];
    [self borderWithView:self.zfbView];
    self.backView.layer.cornerRadius = 6;
    self.backView.layer.masksToBounds = true;
    [self loadData];
}
-(void)loadData{
    [TIOChat.shareSDK.gfHttpManager  accountGetBnakDetailWithType:@"alipay" completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            
        }else{
            self.nameTF.text = responseObject[@"username"];
            self.zfbTF.text = responseObject[@"cardno"];
        }
    }];
}
-(void)chooseImage{
    // 头像
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:TAlertControllerStyleActionSheet];
    [alert addAction:[TAlertAction actionWithTitle:@"拍照" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置通过相册来选取照片
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        else
        {
            [MBProgressHUD showInfo:@"无法使用设备的摄像头" toView:self.view];
        }
        
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"相册" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;//设置通过相册来选取照片
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
        [TIOChat.shareSDK.gfHttpManager accountBindingWithType:@"alipay" cardno:self.zfbTF.text username:self.nameTF.text image:imageUrl completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
            
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
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [MBProgressHUD showLoading:@"" toView:self.view];
    [TIOChat.shareSDK.loginManager updateAvatar:image completion:^(NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
