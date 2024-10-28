//
//  GFQRCodeVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/26.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFQRCodeVC.h"
#import "FrameAccessor.h"
#import "ImportSDK.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import "UIImage+TColor.h"
#import "UIImageView+Web.h"
#import "MBProgressHUD+NJ.h"

#import "QRCodeImage.h"
#import "QRScanViewController.h"
#import "PDCameraScanViewController.h"
#import "UIButton+Enlarge.h"

#import <Social/Social.h>

#define QR_RADIUS 4.f
#define QR_SCALE

@interface GFQRCodeVC ()
@property (weak, nonatomic) IBOutlet UIImageView *headV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *numL;
@property (weak, nonatomic) IBOutlet UIImageView *flag;
@property (weak, nonatomic) IBOutlet UIView *qrView;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipL;

@property (weak, nonatomic) IBOutlet UIView *cordView;

@property (weak,    nonatomic) UIImageView *codeView;
@property (weak,    nonatomic) UIImageView *logoView;

@property (weak, nonatomic) IBOutlet UIView *qunQRView;
@property (weak, nonatomic) IBOutlet UIImageView *qunIconL;
@property (weak, nonatomic) IBOutlet UILabel *qunNameL;
@property (weak, nonatomic) IBOutlet UIView *qunCardView;


@end

@implementation GFQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self.view addGestureRecognizer:[UILongPressGestureRecognizer.alloc initWithTarget:self action:@selector(gestureLongPress:)]];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)downAction:(UIButton *)sender {
    [self buttonDidClicked:sender];
}


- (void)setupUI
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithImage:[[UIImage imageNamed:@"qr_scan"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(toScanQR:)];
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    self.title = self.isP2P?@"我的二维码":@"群二维码";
    
    self.cordView.layer.cornerRadius = 6;
    
    self.cordView.layer.masksToBounds = true;
  
    self.qunCardView.layer.cornerRadius = 6;
    
    self.qunCardView.layer.masksToBounds = true;
    if (self.isP2P) {
        UIImageView *codeView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 86, 86)];
        
        self.codeView = codeView;
        [self.qrView addSubview:codeView];
    }else{
        UIImageView *codeView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 210, 210)];
        
        self.codeView = codeView;
        [self.qunQRView addSubview:codeView];
    }
    self.tipL.text = self.isP2P?@"使用季风APP扫一扫，加我为好友":@"扫码加入群聊";

    
    

    [self.headV tio_imageUrl:self.iconUrl placeHolderImageName:@"avatar_placeholder" radius:4.f];
    [self.qunIconL tio_imageUrl:self.iconUrl placeHolderImageName:@"avatar_placeholder" radius:4.f];

    
    self.qunNameL.text = self.name;
    
    self.nameL.text = self.name;

    self.numL.text = self.account;
    

    self.flag.hidden = self.xx != 3;

    self.cordView.hidden = true;
    self.qunCardView.hidden = true;
    
    if (self.isP2P) {
        self.codeView.image = [self createLogoImage:[UIImage imageNamed:@"Group 1321315510"]];
        self.cordView.hidden = false;
    } else {
        self.codeView.image = [self createLogoImage:[UIImage imageNamed:@"Group 1321315510"]];
        self.qunCardView.hidden = false;
    }
}

#pragma mark - actions

- (void)buttonDidClicked:(UIButton *)button
{
    if (self.isP2P) {
        // 保存二维码
        [self loadImageFinished:[self createSavePhoto]];
    } else {
        if (button.tag == 1000) {
            // 分享
            // 注意⚠️：当前没有分享，所以当前点击是保存二维码，如果有分享，此处处理分析事件
            [self loadImageFinished:[self createSavePhoto]];
        } else {
            // 保存二维码
            [self loadImageFinished:[self createSavePhoto]];
        }
    }
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [MBProgressHUD showSuccess:@"已保存到相册" toView:self.view];
    } else {
        [MBProgressHUD showError:error.localizedDescription toView:self.view];
    }
    
}

- (UIImage *)createSavePhoto
{
    if (self.isP2P){
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.cordView.bounds.size];
        // 绘制整个大背景图
        //    UIGraphicsBeginImageContextWithOptions(self.cordView.size, NO, 0);
        
        UIImage *finalImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [self.cordView.layer renderInContext:rendererContext.CGContext];
        }];
        
        return finalImage;
    }else{
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.qunCardView.bounds.size];
        // 绘制整个大背景图
        //    UIGraphicsBeginImageContextWithOptions(self.cordView.size, NO, 0);
        
        UIImage *finalImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [self.qunCardView.layer renderInContext:rendererContext.CGContext];
        }];
        
        return finalImage;
    }
//    return [UIImage new];
}

- (UIImage *)createLogoImage:(UIImage *)smallImage {
    if (!_qr_data) {
        NSLog(@"error => 二维码数据为空");
        return nil;
    }
    return [QRCodeImage QRImageWithString:self.qr_data size:FlexWidth(236) logo:smallImage];;
}

- (void)loadLogoImage:(void(^)(UIImage *image))complation
{
    NSString *cacheurlStr = [self avatarCache];
    
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheurlStr];
    if (cacheImage) {
        complation(cacheImage);
    }
    else {
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:TIOChat.shareSDK.loginManager.userInfo.avatar] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (!error) {
                UIImage *radiusImage = [image imageWithCornerRadius:QR_RADIUS size:CGSizeMake(57, 57)];
                
                [[SDImageCache sharedImageCache] storeImage:radiusImage forKey:cacheurlStr completion:^{
                    NSLog(@"已经缓存logo");
                }];
                
                complation(radiusImage);
            }
        }];
    }
}

- (NSString *)avatarCache
{
    CGFloat radius = QR_RADIUS;
    NSString *urlStr = TIOChat.shareSDK.loginManager.userInfo.avatar;
    NSString *cacheurlStr = [urlStr stringByAppendingFormat:@"radius=%.1f",radius];
    return cacheurlStr;
}

#pragma mark - test

- (void)gestureLongPress:(id)sender
{
//    NSString *cacheurlStr = [self avatarCache];
//    [[SDImageCache sharedImageCache] removeImageForKey:cacheurlStr withCompletion:^{
//        [MBProgressHUD showInfo:@"已清空头像缓存" toView:self.view];
//    }];
}

- (void)toScanQR:(UIBarButtonItem *)buttonItem
{
    id preVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    // 检测是不是从个人二维码页面进来的，如果是，返回个人二维码，如果不是，创建并进入个人二维码页
    if ([preVC isKindOfClass:PDCameraScanViewController.class]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    PDCameraScanViewController *vc = [PDCameraScanViewController.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
