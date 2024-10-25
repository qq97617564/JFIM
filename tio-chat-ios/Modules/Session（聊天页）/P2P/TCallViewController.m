//
//  TCallViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/5/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCallViewController.h"
#import "MBProgressHUD+NJ.h"
#import "FrameAccessor.h"
#import "TChatSound.h"
#import "TIOKitTool.h"
#import <UIImageView+WebCache.h>
#import <ReplayKit/ReplayKit.h>

@interface TCallViewController () <TIOVideoChatDelegate, TIOSystemDelegate>
@property (assign,  nonatomic) BOOL isInitiator;
@property (strong,  nonatomic) TIOUser *caller;  // 呼叫者的用户
@property (strong,  nonatomic) TIOUser *callee;  // 被呼叫者的用户
@property (copy,    nonatomic) NSString *callId;

@property (strong,  nonatomic) UIView *callerContainerView; // 呼叫者正在呼叫的页面
@property (strong,  nonatomic) UIView *calleeContainerView; // 被呼叫者等待接听的页面
@property (strong,  nonatomic) UIView *videoView;   // 视频通话中的页面
@property (weak,    nonatomic) UIButton *acceptBtn;// 接听按钮
@property (weak,    nonatomic) UIButton *cancelBtn;// 接听者的取消按钮

@property (weak,    nonatomic) UILabel *msgLabel;
@property (strong,  nonatomic) UIView *gradientView; // 渐变层覆盖萌版
@property (weak,    nonatomic) UILabel *timeLabel;

@property (strong,  nonatomic) UIView *localView;
@property (weak,  nonatomic) UIView *remoteView;

@property (weak,    nonatomic) UIImageView *friendAvatar;
@property (weak,    nonatomic) UILabel *friendNickLabel;

@property (assign,  nonatomic) CGSize remoteViewSize;
@property (assign,  nonatomic) BOOL remoteViewIsFill;

@property (strong,  nonatomic) NSTimer *timer;
@property (assign,  nonatomic) NSInteger seconds;

/// 处理对方挂断 同时触发 拒接响应和挂断通知都要回退一次页面 造成连续返回两次
@property (assign,  nonatomic) BOOL isExiting;

/// 通话状态：1：呼叫中 、2：被呼叫、 3：通话中
@property (assign,  nonatomic) NSInteger callStatus;

@end

@implementation TCallViewController

- (instancetype)initWithCaller:(TIOUser *)caller callId:(nonnull NSString *)callId
{
    self = [super init];
    
    if (self) {
        self.isInitiator = NO;
        self.caller = caller;
        self.callId = callId;
        self.remoteViewIsFill = YES; // 远端视频铺满画面
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(appDidEnterBack:)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
    }
    
    return self;
}

- (instancetype)initWithCallee:(TIOUser *)callee
{
    self = [super init];
    
    if (self) {
        self.isInitiator = YES;
        self.callee = callee;
        self.remoteViewIsFill = YES; // 远端视频铺满画面
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(appDidEnterBack:)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [TIOChat.shareSDK.videoChatManager removeDelegate:self];
    [TIOChat.shareSDK.systemManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.blackColor;
    self.navigationBar.hidden = YES;
    
    [TIOChat.shareSDK.videoChatManager addDelegate:self];
    [TIOChat.shareSDK.systemManager addDelegate:self];
    
    [self setupGradientLayer];
    [self.view addSubview:self.gradientView];
    
    if (self.isInitiator) {
        CBWeakSelf
        [TIOChat.shareSDK.videoChatManager call:self.callee.userId type:TIORTCTypeVideo completion:^(NSError * _Nullable error, NSString * _Nonnull callId) {
            CBStrongSelfElseReturn
//            if (error) {
//                [MBProgressHUD showInfo:error.localizedDescription toView:self.view];
//            }

        }];
        [self.view addSubview:self.callerContainerView];
        // 声音
        [TChatSound.shareInstance startCalling];
    } else {
        [self.view addSubview:self.calleeContainerView];
    }
    
    self.view.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    [self cancelSideBack];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    if (_remoteViewSize.width > 0 && _remoteViewSize.height > 0)
    {
      // Aspect fill remote video into bounds.
      CGRect remoteVideoFrame =
        AVMakeRectWithAspectRatioInsideRect(_remoteViewSize, bounds);
        
        if (self.remoteViewIsFill) {
            CGFloat scale = 1;
            if (remoteVideoFrame.size.width > remoteVideoFrame.size.height) {
              // Scale by height.
              scale = bounds.size.height / remoteVideoFrame.size.height;
            } else {
              // Scale by width.
              scale = bounds.size.width / remoteVideoFrame.size.width;
            }
            
            remoteVideoFrame.size.height *= scale;
            remoteVideoFrame.size.width *= scale;
        }
      
        if (_remoteView) {
            _remoteView.frame = remoteVideoFrame;
            _remoteView.center =
                CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        }
    } else {
        if (!_remoteView) {
            _remoteView.frame = bounds;
        }
    }
}

- (void)setupGradientLayer
{
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = self.view.bounds;
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:16/255.0 green:36/255.0 blue:62/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:0/255.0 green:32/255.0 blue:74/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0),@(1.0f),@(1.0f)];
    [self.view.layer addSublayer:gl];
}

- (UIView *)gradientView
{
    if (!_gradientView) {
        _gradientView = [UIView.alloc initWithFrame:self.view.bounds];
        [self.view addSubview:_gradientView];
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = _gradientView.bounds;
        gl.startPoint = CGPointMake(0, 0);
        gl.endPoint = CGPointMake(1, 1);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:151/255.0 blue:255/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:117/255.0 green:255/255.0 blue:227/255.0 alpha:1.0].CGColor];
        gl.locations = @[@(0),@(1.0f),@(1.0f)];
        _gradientView.alpha = 0.18;
        [_gradientView.layer addSublayer:gl];
    }
    return _gradientView;
}

- (UIView *)callerContainerView
{
    if (!_callerContainerView) {
        _callerContainerView = [UIView.alloc initWithFrame:CGRectMake(0, 0, CB_SCREEN_WIDTH, CB_SCREEN_HEIGHT)];
//        _callerContainerView.alpha = 0.18;
        
        UIImageView *otherAvatar = [UIImageView.alloc initWithFrame:CGRectMake(20, Height_NavBar+14, 70, 70)];
        otherAvatar.backgroundColor = UIColor.whiteColor;
        otherAvatar.centerX = _callerContainerView.middleX;
        otherAvatar.layer.cornerRadius = 4;
        otherAvatar.layer.masksToBounds = YES;
        [otherAvatar sd_setImageWithURL:[NSURL URLWithString:self.callee.avatar]];
        [_callerContainerView addSubview:otherAvatar];
        self.friendAvatar = otherAvatar;
        
        UILabel *nickLabel = [UILabel.alloc initWithFrame:CGRectZero];
        nickLabel.width = _callerContainerView.width - 10  - 10;
        nickLabel.height = 28;
        nickLabel.top = otherAvatar.bottom + 16;
        nickLabel.centerX = otherAvatar.centerX;
        nickLabel.textAlignment = NSTextAlignmentCenter;
        nickLabel.textColor = UIColor.whiteColor;
        nickLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        nickLabel.text = self.callee.nick;
        [_callerContainerView addSubview:nickLabel];
        self.friendNickLabel = nickLabel;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.viewSize = CGSizeMake(116, 42);
        cancelBtn.centerX = _callerContainerView.middleX;
        cancelBtn.bottom = _callerContainerView.height - 60 - safeBottomHeight;
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelCall) forControlEvents:UIControlEventTouchUpInside];
        [_callerContainerView addSubview:cancelBtn];
        
        UILabel *msgLabel = [UILabel.alloc init];
        msgLabel.viewSize = CGSizeMake(_callerContainerView.width, 22);
        msgLabel.bottom = cancelBtn.top - FlexHeight(169);
        msgLabel.centerX = _callerContainerView.middleX;
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.textColor = UIColor.whiteColor;
        msgLabel.font =  [UIFont systemFontOfSize:16];
        msgLabel.text = @"等待对方接听...";
        [_callerContainerView addSubview:msgLabel];
        self.msgLabel = msgLabel;
    }
    return _callerContainerView;
}

- (UIView *)calleeContainerView
{
    if (!_calleeContainerView) {
        _calleeContainerView = [UIView.alloc initWithFrame:CGRectMake(0, 0, CB_SCREEN_WIDTH, CB_SCREEN_HEIGHT)];
        
        UIImageView *otherAvatar = [UIImageView.alloc initWithFrame:CGRectMake(20, Height_NavBar+14, 70, 70)];
        otherAvatar.backgroundColor = UIColor.whiteColor;
        otherAvatar.centerX = _calleeContainerView.middleX;
        otherAvatar.layer.cornerRadius = 4;
        otherAvatar.layer.masksToBounds = YES;
        [otherAvatar sd_setImageWithURL:[NSURL URLWithString:self.caller.avatar]];
        [_calleeContainerView addSubview:otherAvatar];
        self.friendAvatar = otherAvatar;
        
        UILabel *nickLabel = [UILabel.alloc initWithFrame:CGRectZero];
        nickLabel.width = _calleeContainerView.width - 10 - 10;
        nickLabel.height = 28;
        nickLabel.top = otherAvatar.bottom + 16;
        nickLabel.centerX = otherAvatar.centerX;
        nickLabel.textAlignment = NSTextAlignmentCenter;
        nickLabel.textColor = UIColor.whiteColor;
        nickLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        nickLabel.text = self.caller.nick;
        [_calleeContainerView addSubview:nickLabel];
        self.friendNickLabel = nickLabel;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.viewSize = CGSizeMake(116, 42);
        cancelBtn.left = (_calleeContainerView.width - 116*2) / 3.f;
        cancelBtn.bottom = _calleeContainerView.height - 60 - safeBottomHeight;
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"挂断" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(refuseBtn) forControlEvents:UIControlEventTouchUpInside];
        [_calleeContainerView addSubview:cancelBtn];
        self.cancelBtn = cancelBtn;
        
        UIButton *acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        acceptBtn.viewSize = CGSizeMake(116, 42);
        acceptBtn.right = _calleeContainerView.width - cancelBtn.left;
        acceptBtn.bottom = cancelBtn.bottom;
        acceptBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [acceptBtn setBackgroundImage:[UIImage imageNamed:@"accept_video"] forState:UIControlStateNormal];
        [acceptBtn setTitle:@"接听" forState:UIControlStateNormal];
        [acceptBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [acceptBtn addTarget:self action:@selector(acceptBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_calleeContainerView addSubview:acceptBtn];
        self.acceptBtn = acceptBtn;
        
        UILabel *msgLabel = [UILabel.alloc init];
        msgLabel.viewSize = CGSizeMake(_calleeContainerView.width, 22);
        msgLabel.bottom = cancelBtn.top - FlexHeight(169);
        msgLabel.centerX = _calleeContainerView.middleX;
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.textColor = UIColor.whiteColor;
        msgLabel.font =  [UIFont systemFontOfSize:16];
        msgLabel.text = @"对方向您发起视频通话邀请...";
        [_calleeContainerView addSubview:msgLabel];
        self.msgLabel = msgLabel;
    }
    return _calleeContainerView;
}

- (UIView *)videoView
{
    if (!_videoView) {
        _videoView = [UIView.alloc initWithFrame:self.view.bounds];
        
        // 挂断
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.viewSize = CGSizeMake(116, 42);
        cancelBtn.centerX = _videoView.middleX;
        cancelBtn.bottom = _videoView.height - 60 - safeBottomHeight;
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"挂断" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(hangupBtn) forControlEvents:UIControlEventTouchUpInside];
        [_videoView addSubview:cancelBtn];
//        // 静音
//        UIButton *mutexBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        mutexBtn.bounds = CGRectMake(0, 0, 60, 42);
//        mutexBtn.centerX = cancelBtn.left * 0.5;
//        mutexBtn.centerY = cancelBtn.centerY;
//        [mutexBtn setBackgroundImage:[UIImage imageNamed:@"vc_open_audio"] forState:UIControlStateNormal];
//        [mutexBtn setBackgroundImage:[UIImage imageNamed:@"vc_close_audio"] forState:UIControlStateSelected];
//        [mutexBtn addTarget:self action:@selector(audioEnableBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [_videoView addSubview:mutexBtn];
//        UILabel *mutexLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 60, 17)];
//        mutexLabel.centerX = mutexBtn.centerX;
//        mutexLabel.top = mutexBtn.bottom + 10;
//        mutexLabel.text = @"静音";
//        mutexLabel.font = [UIFont systemFontOfSize:12];
//        mutexLabel.textColor = UIColor.whiteColor;
//        mutexLabel.textAlignment = NSTextAlignmentCenter;
//        [_videoView addSubview:mutexLabel];
        // 切换摄像头
        UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cameraBtn.bounds = CGRectMake(0, 0, 60, 42);
        cameraBtn.centerX = (cancelBtn.right + _videoView.width) * 0.5;
        cameraBtn.centerY = cancelBtn.centerY;
        [cameraBtn setBackgroundImage:[UIImage imageNamed:@"vc_switch_camera"] forState:UIControlStateNormal];
        [cameraBtn setBackgroundImage:[UIImage imageNamed:@"vc_switch_camera_highlight"] forState:UIControlStateHighlighted];
        [cameraBtn addTarget:self action:@selector(switchCameraBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_videoView addSubview:cameraBtn];
        UILabel *cameraLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 70, 17)];
        cameraLabel.centerX = cameraBtn.centerX;
        cameraLabel.top = cameraBtn.bottom + 10;
        cameraLabel.text = @"转换摄像头";
        cameraLabel.font = [UIFont systemFontOfSize:12];
        cameraLabel.textColor = UIColor.whiteColor;
        cameraLabel.textAlignment = NSTextAlignmentCenter;
        [_videoView addSubview:cameraLabel];
        
        UILabel *timeLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, _videoView.width * 0.5, 20)];
        timeLabel.centerX = _videoView.middleX;
        timeLabel.bottom = cancelBtn.top - 35;
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = UIColor.whiteColor;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [_videoView addSubview:timeLabel];
        self.timeLabel = timeLabel;
    }
    return _videoView;
}

#pragma mark - notification

/// APP 已经进入后台
- (void)appDidEnterBack:(id)sender
{
    if (_videoView) {
        // 正常通话中挂断
        [self hangupBtn];
    } else {
        if (self.isInitiator) {
            [self cancelCall];
        } else {
            [self refuseBtn];
        }
    }
}

#pragma mark - actions

- (void)cancelCall
{
    [TIOChat.shareSDK.videoChatManager cancelCall:self.callId];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refuseBtn
{
    [TIOChat.shareSDK.videoChatManager answer:self.callId type:TIORTCTypeVideo accept:NO ext:@""];
}

- (void)acceptBtnClicked:(UIButton *)button
{
    [TChatSound.shareInstance finishCalling];
    [TIOChat.shareSDK.videoChatManager answer:self.callId type:TIORTCTypeVideo accept:YES ext:@""];
}

- (void)hangupBtn
{
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
    
    [TChatSound.shareInstance finishCalling];
    [TIOChat.shareSDK.videoChatManager hangup:TIOCallHangupTypeNormal];
    
    // 正常流程：收到挂断通知=>结束返回上一页
    // 如果因为异常，超时4秒没有收到挂断通知，主动返回上一页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)switchCameraBtn:(UIButton *)btn
{
    if (btn.selected == NO) {
        [TIOChat.shareSDK.videoChatManager switchCamera:TIOCallCameraBack];
    } else {
        [TIOChat.shareSDK.videoChatManager switchCamera:TIOCallCameraFront];
    }
    
    btn.selected = !btn.selected;
}

- (void)remoteviewFillBtn:(UIButton *)btn
{
    self.remoteViewIsFill = !self.remoteViewIsFill;
    [self viewDidLayoutSubviews];
}

- (void)switchSpeaker:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [TIOChat.shareSDK.videoChatManager switchAudioDevice:btn.selected?TIOCallAudioDeviceEarphone:TIOCallAudioDeviceSpeaker];
}

- (void)audioEnableBtn:(UIButton *)btn
{
    [TIOChat.shareSDK.videoChatManager setMicMutex:btn.selected];
    btn.selected = !btn.selected;
}

- (void)timerRun
{
    NSString *timeString = [TIOKitTool timeStringWithSecond:_seconds];
    
    self.timeLabel.text = timeString;
    
    _seconds++;
}

#pragma mark - TIOVideoChatDelegate

- (void)tio_callConnected {
    NSLog(@"tio_callConnected");
    [TChatSound.shareInstance finishCalling];
    
    if (self.isInitiator) {
        [self.callerContainerView removeFromSuperview];
    } else {
        [self.calleeContainerView removeFromSuperview];
    }
    
    [self.view addSubview:self.videoView];
    
    // 本地视频预览的动画 原始预览->右上角
    if (self.localView) {
        [UIView transitionWithView:self.localView duration:0.3 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.localView.frame = CGRectMake(0, 0, 81, 144);
            self.localView.top = Height_StatusBar + 13;
            self.localView.right = self.view.width - 16;
        } completion:^(BOOL finished) {
            
        }];
        [self.view bringSubviewToFront:self.localView];
    }
    
    // 开始计时
    if (!_timer) {
        _seconds = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
    }
}

- (void)tio_callDisconnected:(nullable NSError *)error {
    NSLog(@"tio_callDisconnected");
}

- (void)tio_hangup:(TIOWxCallItem *)object {
    
    if (self.isExiting) {
        return;
    }
    self.isExiting = YES;
    
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
    
    [TChatSound.shareInstance playHangupSound];
    
    BOOL isSelf = [object.fromuid isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId];
    
    NSString *msg = nil;
    switch (object.hanguptype) {
        case TIOCallHangupTypeNormal:
        {
            msg = @"通话结束";
        }
            break;
        case TIOCallHangupTypeCallerHangup:
        {
            msg = isSelf?@"已挂断":@"对方已挂断";
        }
            break;
        case TIOCallHangupTypeTimeout:
        {
            msg = @"对方未接听";
        }
            break;
        case TIOCallHangupTypeNotOnline:
        {
            msg = @"对方不在线";
        }
            break;
        case TIOCallHangupTypeInCalling:
        {
            msg = @"对方忙线中...";
        }
            break;
        case TIOCallHangupTypeRefuse:
        {
            msg = !isSelf?@"已拒绝":@"对方已拒绝";
        }
            break;
            
        default:
            msg = @"网络中断";
            break;
    }
    [MBProgressHUD showInfo:msg toView:self.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

/// 收到呼叫
- (void)tio_receiveCall:(nonnull TIOWxCallItem *)object {
}

- (void)tio_remoteViewReady:(nonnull UIView *)remoteView {
    NSLog(@"tio_remoteViewReady");
    self.remoteView = remoteView;
    self.remoteView.frame = self.view.bounds;
    // 远端视频 要始终处在背景上面。
    [self.view insertSubview:self.remoteView aboveSubview:self.gradientView];
}

- (void)tio_responseAccept:(nonnull TIOWxCallItemReply *)accept {
    // 对方同意接听
    NSLog(@"tio_responseAccept");
    
    if (accept.result == TIORTCReplyResultCancel) {
        
        if (self.isExiting) {
            
        }
        
        if (self.isExiting) {
            self.isExiting = YES;
            
            if (_timer) {
                [_timer invalidate];
                self.timer = nil;
            }
            
            [TChatSound.shareInstance playHangupSound];
            
//            [MBProgressHUD showInfo:@"对方拒绝接听" toView:self.view];
//            // 自动返回上一页
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.navigationController popViewControllerAnimated:YES];
//            });
        }
        
    } else {
        self.msgLabel.text = @"接通中...";
    }
}

- (void)tio_localReviewReady:(nonnull UIView *)localView {
    NSLog(@"tio_localReviewReady");
    
    // 本地视频预览层要始终在最上层；但是呼叫等待接听时，应处在操控UI层的下面
    if (self.isInitiator) {
        if (!self.localView) {
            localView.frame = self.view.bounds;
        }
        
        [UIView transitionWithView:self.localView duration:0.3 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            localView.frame = CGRectMake(0, 0, 81, 144);
            localView.top = Height_StatusBar + 13;
            localView.right = self.view.width - 16;
        } completion:^(BOOL finished) {
            
        }];
        
        [self.view insertSubview:localView aboveSubview:self.gradientView];
    } else {
        [self.view addSubview:localView];
    }
    
    self.localView = localView;
}

/// 渲染远端视频
/// @param view 渲染远端视频的view
/// @param width 远端视频的宽
/// @param height 远端视频的高
- (void)tio_remoteview:(UIView *)view changeWidth:(CGFloat)width height:(CGFloat)height
{
    NSLog(@"tio_remoteview: thread = %d",NSThread.isMainThread);
    CGSize size = CGSizeMake(width, height);
    self.remoteViewSize = size;
    [self viewDidLayoutSubviews];
}

- (void)tio_SingnalConnected
{
    self.msgLabel.text = @"接通中...";
    [UIView animateWithDuration:0.1 animations:^{
        self.acceptBtn.hidden = YES;
        self.cancelBtn.centerX = self->_calleeContainerView.middleX;
    }];
}

#pragma mark - TIOSystemNotification

- (void)onServerConnectChanged:(BOOL)connected
{
    if (!connected) {
        [self hangupBtn];
    }
}

@end
