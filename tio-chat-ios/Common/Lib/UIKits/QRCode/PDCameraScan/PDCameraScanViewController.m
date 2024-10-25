//
//  PDCameraScanViewController.m
//  DiErZhouKaoShi
//
//  Created by 裴铎 on 2018/7/16.
//  Copyright © 2018年 裴铎. All rights reserved.
//

#import "PDCameraScanViewController.h"
#import "QRCodeViewController.h"

#import "ImportSDK.h"
#import "UIButton+Enlarge.h"
#import "FrameAccessor.h"
#import "PDCameraScanView.h"//扫描界面头文件
#import <AVFoundation/AVFoundation.h>  //引用AVFoundation框架
#import "WKWebViewController.h"
#import "MBProgressHUD+NJ.h"
#import "TAlertController.h"
#import "TTeamViewController.h"
#import "CTMediator+ModuleActions.h"

#import "ServerConfig.h"

@interface PDCameraScanViewController ()<
AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> //遵守AVCaptureMetadataOutputObjectsDelegate协议
@property ( strong , nonatomic ) AVCaptureDevice * device; //捕获设备，默认后置摄像头
@property ( strong , nonatomic ) AVCaptureDeviceInput * input; //输入设备
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;//输出设备，需要指定他的输出类型及扫描范围
@property ( strong , nonatomic ) AVCaptureSession * session; //AVFoundation框架捕获类的中心枢纽，协调输入输出设备以获得数据
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;//展示捕获图像的图层，是CALayer的子类
@property (nonatomic,strong)UIView *scanView;//定位扫描框在哪个位置
@property (weak,    nonatomic) PDCameraScanView *maskScanView;

@end

@implementation PDCameraScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //屏幕的宽度
    CGFloat kScreen_Width = [UIScreen mainScreen].bounds.size.width;
    
    //定位扫描框在屏幕正中央，并且宽高为200的正方形
    self.scanView = [[UIView alloc]initWithFrame:CGRectMake((kScreen_Width-300)/2, Height_NavBar+40, 300, 300)];
    [self.view addSubview:self.scanView];
    
    //设置扫描界面（包括扫描界面之外的部分置灰，扫描边框等的设置）,后面设置
    PDCameraScanView *clearView = [[PDCameraScanView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:clearView];
    self.maskScanView = clearView;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(choicePhoto)];
    self.navigationBar.backgroundColor = UIColor.clearColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setImage:[UIImage imageNamed:@"back2"] forState:UIControlStateNormal];
        [button setTitle:@"扫一扫" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button verticalLayoutWithInsetsStyle:ButtonStyleLeft Spacing:-40];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
    
    UILabel *label = [UILabel.alloc initWithFrame:CGRectZero];
    label.text = @"将二维码对准框内，即可自动扫描";
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:16];
    [label sizeToFit];
    label.centerX = self.view.middleX;
    label.top = self.scanView.bottom+37;
    [self.view addSubview:label];
    
    // 我的二维码
    
    UIButton *mineQR = [UIButton buttonWithType:UIButtonTypeCustom];
    [mineQR setImage:[UIImage imageNamed:@"qr_small_code"] forState:UIControlStateNormal];
    [mineQR setTitle:@"我的二维码" forState:UIControlStateNormal];
    [mineQR setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
    [mineQR.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [mineQR sizeToFit];
    mineQR.centerX = self.view.middleX;
    mineQR.top = label.bottom + 18;
    [mineQR addTarget:self action:@selector(seeMyQRCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mineQR];
    
    //初始化并启动扫描
    [self startScan];
    
    [self.view bringSubviewToFront:self.navigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 开始扫描
 */
- (void)startScan
{
    // 1.判断输入能否添加到会话中
    if (![self.session canAddInput:self.input]) return;
    [self.session addInput:self.input];
    
    
    // 2.判断输出能够添加到会话中
    if (![self.session canAddOutput:self.output]) return;
    [self.session addOutput:self.output];
    
    // 4.设置输出能够解析的数据类型
    // 注意点: 设置数据类型一定要在输出对象添加到会话之后才能设置
    //设置availableMetadataObjectTypes为二维码、条形码等均可扫描，如果想只扫描二维码可设置为
    // [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    // 5.设置监听监听输出解析到的数据
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 6.添加预览图层
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    self.previewLayer.frame = self.view.bounds;
    
    // 8.开始扫描
    [self.session startRunning];
}


/**
 扫描结束回调
 下面是接收扫描结果的代理AVCaptureMetadataOutputObjectsDelegate:
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self.session stopRunning];   //停止扫描
    //我们捕获的对象可能不是AVMetadataMachineReadableCodeObject类，所以要先判断，不然会崩溃
    if (![[metadataObjects lastObject] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        [self.session startRunning];
        return;
    }
    // id 类型不能点语法,所以要先去取出数组中对象
    AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
    if ( object.stringValue == nil ){
        [self.session startRunning];
    }
    
    // wxp://f2f0Qz9qxst1qazKE_53XToPLIzMELvT8Ccd
    // https://qr.alipay.com/fkx13673gkz2fi4kwuvzjb9?t=1608010938119
    [self parseResult:object.stringValue];
    
    if (object.stringValue.length) {
        if (@protocol(TScanQRCodeViewControllerDelegate) && [self.delegate respondsToSelector:@selector(scanQRCodeViewController:stringValue:)]) {
            [self.delegate scanQRCodeViewController:self stringValue:object.stringValue];
        }
    }
    
    [self.maskScanView pause];
}

/**
 调用相册
 */
- (void)choicePhoto{
    //调用相册
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    //UIImagePickerControllerSourceTypePhotoLibrary为相册
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //设置代理UIImagePickerControllerDelegate和UINavigationControllerDelegate
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

//选中图片的回调
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    //创建探测器
    //CIDetectorTypeQRCode表示二维码，这里选择CIDetectorAccuracyLow识别速度快
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciImage];
    
    //取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        NSString *content = result.messageString;// 这个就是我们想要的值
        if (content.length) {
            [self parseResult:content];
            if (@protocol(TScanQRCodeViewControllerDelegate) && [self.delegate respondsToSelector:@selector(scanQRCodeViewController:stringValue:)]) {
                [self.delegate scanQRCodeViewController:self stringValue:content];
            }
            break;
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark 懒加载

//下面初始化AVCaptureSession和AVCaptureVideoPreviewLayer:
- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
        //负责图像渲染出来
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

/**
 这里设置输出设备要注意rectOfInterest属性的设置，一般默认是CGRect(x: 0, y: 0, width: 1, height: 1),
 全屏都能读取的，但是读取速度较慢。
 注意rectOfInterest属性的传人的是比例。
 比例是根据扫描容器的尺寸比上屏幕尺寸（注意要计算的时候要计算导航栏高度，有的话需减去）。
 参照的是横屏左上角的比例，而不是竖屏。
 所以我们再设置的时候要调整方向如下面所示。
 */
- (AVCaptureMetadataOutput *)output{
    if (_output == nil) {
        //初始化输出设备
        _output = [[AVCaptureMetadataOutput alloc] init];
        
        // 1.获取屏幕的frame
        CGRect viewRect = self.view.frame;
        // 2.获取扫描容器的frame
        CGRect containerRect = self.scanView.frame;
        
        CGFloat x = containerRect.origin.y / viewRect.size.height;
        CGFloat y = containerRect.origin.x / viewRect.size.width;
        CGFloat width = containerRect.size.height / viewRect.size.height;
        CGFloat height = containerRect.size.width / viewRect.size.width;
        //rectOfInterest属性设置设备的扫描范围
        _output.rectOfInterest = CGRectMake(x, y, width, height);
    }
    return _output;
    
    /**网上还有一种是根据AVCaptureInputPortFormatDescriptionDidChangeNotification通知设置的，也是可行的，自选一种即可
     __weak typeof(self) weakSelf = self;
     [[NSNotificationCenter defaultCenter]addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
     object:nil
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification * _Nonnull note) {
     if (weakSelf){
     //调整扫描区域
     AVCaptureMetadataOutput *output = weakSelf.session.outputs.firstObject;
     output.rectOfInterest = [weakSelf.previewLayer metadataOutputRectOfInterestForRect:weakSelf.scanView.frame];
     }
     }];*/
}


- (AVCaptureDevice *)device{
    if (_device == nil) {
        // 设置AVCaptureDevice的类型为Video类型
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input{
    if (_input == nil) {
        //输入设备初始化
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.maskScanView resume];
    [self.session startRunning];
}

- (void)dealloc
{
    [self.maskScanView removeFromSuperview];
}

#pragma mark - actions

- (void)seeMyQRCode
{
    id preVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    // 检测是不是从个人二维码页面进来的，如果是，返回个人二维码，如果不是，创建并进入个人二维码页
    if ([preVC isKindOfClass:QRCodeViewController.class]) {
        QRCodeViewController *vc = preVC;
        if (vc.isP2P) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    QRCodeViewController *vc = [QRCodeViewController.alloc init];
    vc.leftBarButtonText = @"我的二维码";
    vc.isP2P = YES;
    vc.iconUrl = TIOChat.shareSDK.loginManager.userInfo.avatar;
    vc.name = TIOChat.shareSDK.loginManager.userInfo.nick;
    vc.qr_data = [QR_SERVER stringByAppendingFormat:@"&uid=%@",TIOChat.shareSDK.loginManager.userInfo.userId];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 截取URL参数

- (void)parseResult:(NSString *)stringValue
{
    if (![stringValue compare:@"http" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)] || ![stringValue compare:@"www." options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)]) {
        if ([stringValue hasPrefix:QR_SERVER]) {
            // 内部二维码
            NSDictionary *params = [self getURLParameters:stringValue];
            if (params[@"uid"]) {
                // 个人二维码
//                [MBProgressHUD showInfo:[NSString stringWithFormat:@"用户ID：%@",params[@"uid"]] toView:self.view];
                [self jumoToUserVC:params[@"uid"]];
            } else if (params[@"g"]) {
                // 群二维码
//                [MBProgressHUD showInfo:[NSString stringWithFormat:@"群ID：%@\n分享人ID：%@",params[@"g"],params[@"applyuid"]] toView:self.view];
                [self joinToTeam:params[@"g"] applyId:params[@"applyuid"]];
            } else {
                // 无效二维码
                [MBProgressHUD showError:@"无效的二维码" toView:self.view];
                WKWebViewController *vc = [WKWebViewController.alloc init];
                vc.urlString = stringValue;
                vc.autoUrl = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:stringValue]];
        }
    } else  {
        [MBProgressHUD showInfo:stringValue toView:self.view];
    }
}

- (NSMutableDictionary *)getURLParameters:(NSString *)URLString {

    // 查找参数
    NSRange range = [URLString rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    // 截取参数
    NSString *parametersString = [URLString substringFromIndex:range.location + 1];

    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {

        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];

        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];

            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }

            id existValue = [params valueForKey:key];

            if (existValue != nil) {

                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];

                    [params setValue:items forKey:key];
                } else {

                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }

            } else {

                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数

        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];

        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }

        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];

        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }

        // 设置值
        [params setValue:value forKey:key];
    }

    return params;
}

- (void)joinToTeam:(NSString *)teamId applyId:(NSString *)applyId
{
    // 检查二维码是否可用
    CBWeakSelf
    [TIOChat.shareSDK.teamManager checkTeamShareCard:teamId fromUser:applyId completion:^(NSError * _Nullable error, TIOTeamCardStatus status) {
        CBStrongSelfElseReturn
        if (!error)
        {
            if (status == TIOTeamCardStatusAvailable)
            {
                // 已加入此群
                // 直接进群
                [self jumpToTeamSessionVC:teamId];
            }
            else
            {
                // 未加入群
                TAlertController *alert = [TAlertController alertControllerWithTitle:nil message:@"是否接受邀请加入群聊？" preferredStyle:TAlertControllerStyleAlert];
                [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                    
                }]];
                [alert addAction:[TAlertAction actionWithTitle:@"加入群聊" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                    // 加入群聊
                    TIOLoginUser *userInfo = [TIOChat.shareSDK.loginManager userInfo]; // 找到自己的信息
                    [TIOChat.shareSDK.teamManager addUser:@[userInfo.userId] toTeam:teamId sharerUid:applyId completion:^(NSError * _Nullable error) {
                        if (!error) {
                            // 加群成功 进群
                            [self jumpToTeamSessionVC:teamId];
                        } else {
                            [MBProgressHUD showError:error.localizedDescription toView:self.view];
                        }
                    }];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        else
        {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
    }];
}

/// 进群
/// @param teamId 群ID
- (void)jumpToTeamSessionVC:(NSString *)teamId
{
    [MBProgressHUD showLoading:@"正在识别二维码" toView:self.view];
    // 获取会话ID，进群
    [TIOChat.shareSDK.conversationManager fetchSessionId:TIOSessionTypeTeam
                                              friendId:teamId
                                            completion:^(NSError * _Nullable error, TIORecentSession * _Nullable session) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            if (session) {
                TTeamViewController *vc = [TTeamViewController.alloc initWithSession:session.session];
                [self.navigationController pushViewController:vc animated:YES];
                // 从群聊页返回一级页面
                UIViewController *firstVC = self.navigationController.viewControllers.firstObject;
                [vc.navigationController setViewControllers:@[firstVC,vc]];
            } else {
                [MBProgressHUD showInfo:@"系统不存在此群" toView:self.view];
            }
        }
    }];
}

- (void)jumoToUserVC:(NSString *)uid
{
    // 预处理Block
    void (^jumpToUserInfoVCBlock)(TIOUser *userInfo, NSInteger type, BOOL isFriend) = ^(TIOUser *userInfo, NSInteger type, BOOL isFriend) {
        
          NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
            
            if (isFriend)
            {
                params[@"user"] = userInfo;
                params[@"type"] = @(type); // 好友
                
                UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
                [self.navigationController pushViewController:homePageVC animated:YES];
            }
            else
            {
                params[@"user"] = userInfo;
                params[@"type"] = @(type); // 需要审核
                
                UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
                [self.navigationController pushViewController:homePageVC animated:YES];
            }
    };
    
    
    [MBProgressHUD showLoading:@"正在识别二维码" toView:self.view];
    
    CBWeakSelf
    [TIOChat.shareSDK.friendManager isMyFriend:uid
                                    completion:^(BOOL isFriend, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
        else
        {
            CBWeakSelf
            [TIOChat.shareSDK.friendManager fetchUserInfo:uid completion:^(TIOUser * _Nullable user, NSError * _Nullable error) {
                CBStrongSelfElseReturn
                
                if (user)
                {
                    // 有用户信息，直接执行block跳转
                    jumpToUserInfoVCBlock(user, isFriend?1:3, isFriend);
                }
                else
                {
                    // 获取用户信息，再执行block跳转
                    [TIOChat.shareSDK.friendManager fetchUserInfo:uid completion:^(TIOUser * _Nullable user, NSError * _Nullable error) {
                        if (error)
                        {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            DDLogError(@"%@",error);
                            [MBProgressHUD showError:error.localizedDescription toView:self.view];
                        }
                        else
                        {
                            if (user) {
                                jumpToUserInfoVCBlock(user, isFriend?1:3, isFriend);
                            } else {
                                if (user) {
                                    jumpToUserInfoVCBlock(user, isFriend?1:3, isFriend);
                                } else {
                                    [MBProgressHUD showInfo:@"系统不存在此用户" toView:self.view];
                                }
                            }
                        }
                    }];
                }
            }];
        }
    }];
}

@end
