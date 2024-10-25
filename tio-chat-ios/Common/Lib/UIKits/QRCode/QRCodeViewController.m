//
//  QRCodeViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "QRCodeViewController.h"
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

@interface QRCodeViewController ()
@property (weak,    nonatomic) UIImageView *codeView;
@property (weak,    nonatomic) UIImageView *logoView;
@property (weak,    nonatomic) UIImageView *avatarView;
@property (weak,    nonatomic) UILabel *nickLabel;
@property (weak,    nonatomic) UILabel *bottomLabel;
@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [self.view addGestureRecognizer:[UILongPressGestureRecognizer.alloc initWithTarget:self action:@selector(gestureLongPress:)]];
}

- (void)setupUI
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithImage:[[UIImage imageNamed:@"qr_scan"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(toScanQR:)];
    self.navigationBar.backgroundColor = UIColor.clearColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
        
        NSString *title = self.isP2P?@"我的二维码":@"群二维码";
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setImage:[UIImage imageNamed:@"back2"] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button verticalLayoutWithInsetsStyle:ButtonStyleLeft Spacing:-40];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
    
    UIImageView *bg = [UIImageView.alloc initWithFrame:self.view.bounds];
    bg.image = [UIImage imageNamed:@"qr_bg"];
    [self.view addSubview:bg];
    [self.view sendSubviewToBack:bg];
    
    UIView *cardView = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width-56, FlexWidth(400))];
    cardView.backgroundColor = UIColor.whiteColor;
    cardView.layer.cornerRadius = 16;
    cardView.layer.masksToBounds = YES;
    cardView.center = self.view.middlePoint;
    [self.view addSubview:cardView];
    
    UIImageView *codeView = [UIImageView.alloc initWithFrame:CGRectMake(0, FlexWidth(100), FlexWidth(236), FlexWidth(236))];
    codeView.centerX = cardView.middleX;
    [cardView addSubview:codeView];
    self.codeView = codeView;
    
    UILabel *label = [UILabel.alloc init];
    label.textColor = [UIColor colorWithHex:0x9C9C9C];
    label.text = self.isP2P?@"使用谭聊APP扫一扫，加我为好友":@"扫码加入群聊";
    label.font = [UIFont systemFontOfSize:14];
    [label sizeToFit];
    label.centerX = cardView.middleX;
    label.bottom = cardView.height - 24;
    [cardView addSubview:label];
    self.bottomLabel = label;
    
    
    UIImageView *avatarView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 80, 80)];
    [avatarView tio_imageUrl:self.iconUrl placeHolderImageName:@"avatar_placeholder" radius:4.f];
    avatarView.layer.cornerRadius = 4;
    avatarView.layer.borderColor = UIColor.whiteColor.CGColor;
    avatarView.layer.borderWidth = 1.f;
    avatarView.centerX = self.view.middleX;
    avatarView.centerY = cardView.top;
    [self.view addSubview:avatarView];
    self.avatarView = avatarView;
    
    UILabel *nameLabel = [UILabel.alloc init];
    nameLabel.text = self.name;
    nameLabel.textColor = [UIColor colorWithHex:0x333333];
    nameLabel.font = [UIFont systemFontOfSize:20.f weight:UIFontWeightMedium];
    [nameLabel sizeToFit];
    if (nameLabel.width > cardView.width - 40) nameLabel.width = cardView.width - 40;
    nameLabel.top = avatarView.bottom + 13;
    nameLabel.centerX = self.view.middleX;
    [self.view addSubview:nameLabel];
    self.nickLabel = nameLabel;
    
    
    NSArray *images = nil;
    NSArray *texts = nil;
    
//    if (self.isP2P) {
        images = @[@"qr_save"];
        texts = @[@"下载"];
//    } else {
//        images = @[@"qr_share",@"qr_save"];
//        texts = @[@"分享",@"下载"];
//    }
    
    for (int i = 0; i < images.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.viewSize = CGSizeMake(58, 58);
        button.tag = 1000 + i;
        
//        if (self.isP2P) {
            button.centerX = self.view.middleX;
//        } else {
//            if (i == 0) {
//                button.left = FlexWidth(77);
//            } else {
//                button.right = self.view.width - FlexWidth(77);
//            }
//        }
        
        button.top = cardView.bottom + 34;
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageWithColor:UIColor.whiteColor] imageWithCornerRadius:29 size:button.viewSize] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(button.left, button.bottom+9, button.width, 22)];
        label.text = texts[i];
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    
    if (self.isP2P) {
        codeView.image = [self createLogoImage:[UIImage imageNamed:@"qr_logo"]];
    } else {
        codeView.image = [self createLogoImage:nil];
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
    UIImage *backgroundImage = [UIImage imageNamed:@"qr_save_bg2"];
    // 绘制整个大背景图
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, NO, 0);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    
    // 白色背景
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(28, 94, backgroundImage.size.width-56, 400) cornerRadius:16];
//    CGContextAddPath(context, bezierPath.CGPath);
//    CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
//    CGContextFillPath(context);
    
    // 头像
    [self.avatarView.image drawInRect:CGRectMake((backgroundImage.size.width-80)*0.5, 54, 80, 80)];
    // 昵称
    CGPoint point = CGPointMake((backgroundImage.size.width-self.nickLabel.width)*0.5, 148);
    [self.nickLabel drawTextInRect:CGRectMake(point.x, point.y, self.nickLabel.width, self.nickLabel.height)];
    // 二维码
    [self.codeView.image drawInRect:CGRectMake((backgroundImage.size.width-FlexWidth(236))*0.5, FlexWidth(195), FlexWidth(236), FlexWidth(236))];
    
    [self.bottomLabel.text drawAtPoint:CGPointMake((backgroundImage.size.width-self.bottomLabel.width)*0.5, 450) withAttributes:@{NSFontAttributeName:self.bottomLabel.font, NSForegroundColorAttributeName:self.bottomLabel.textColor}];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    return finalImage;
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
