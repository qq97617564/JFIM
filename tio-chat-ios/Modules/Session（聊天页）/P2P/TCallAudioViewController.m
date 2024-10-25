//
//  TCallAudioViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCallAudioViewController.h"
#import "MBProgressHUD+NJ.h"
#import "FrameAccessor.h"
#import "TChatSound.h"
#import "TIOKitTool.h"
#import <UIImageView+WebCache.h>

@interface TCallAudioViewController ()<TIOVideoChatDelegate>
@property (assign,  nonatomic) BOOL isInitiator;
@property (strong,  nonatomic) TIOUser *caller;  // 呼叫者的用户
@property (strong,  nonatomic) TIOUser *callee;  // 被呼叫者的用户
@property (copy,    nonatomic) NSString *callId;

@property (strong,  nonatomic) UIView *callerContainerView; // 呼叫者正在呼叫的页面
@property (strong,  nonatomic) UIView *calleeContainerView; // 被呼叫者等待接听的页面
@property (strong,  nonatomic) UIView *videoView;   // 通话中的页面

@property (strong,  nonatomic) UIView *gradientView; // 渐变层覆盖萌版

@property (weak,    nonatomic) UILabel *msgLabel;
@property (weak,    nonatomic) UILabel *timeLabel;

@property (weak,  nonatomic) UIView *localView;
@property (weak,  nonatomic) UIView *remoteView;

@property (weak,    nonatomic) UIImageView *friendAvatar;
@property (weak,    nonatomic) UILabel *friendNickLabel;

@property (strong,  nonatomic) NSTimer *timer;
@property (assign,  nonatomic) NSInteger seconds;
@end

@implementation TCallAudioViewController

- (instancetype)initWithCaller:(TIOUser *)caller callId:(nonnull NSString *)callId
{
    self = [super init];
    
    if (self) {
        self.isInitiator = NO;
        self.caller = caller;
        self.callId = callId;
    }
    
    return self;
}

- (instancetype)initWithCallee:(TIOUser *)callee
{
    self = [super init];
    
    if (self) {
        self.isInitiator = YES;
        self.callee = callee;
    }
    
    return self;
}

- (void)dealloc
{
    [TIOChat.shareSDK.videoChatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.blackColor;
    self.navigationBar.hidden = YES;
    [TIOChat.shareSDK.videoChatManager addDelegate:self];
    
    [self setupGradientLayer];
    [self.view addSubview:self.gradientView];
    
    if (self.isInitiator) {
        [TIOChat.shareSDK.videoChatManager call:self.callee.userId type:TIORTCTypeAudio completion:^(NSError * _Nullable error, NSString * _Nonnull callId) {

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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    [self cancelSideBack];
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
        nickLabel.width = _callerContainerView.width - 10 - 10;
        nickLabel.height = 28;
        nickLabel.top = otherAvatar.bottom + 16;
        nickLabel.centerX = otherAvatar.centerX;
        nickLabel.textAlignment = NSTextAlignmentCenter;
        nickLabel.textColor = UIColor.whiteColor;
        nickLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
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
        nickLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
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
        
        UIButton *acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        acceptBtn.viewSize = CGSizeMake(116, 42);
        acceptBtn.right = _calleeContainerView.width - cancelBtn.left;
        acceptBtn.bottom = cancelBtn.bottom;
        acceptBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [acceptBtn setBackgroundImage:[UIImage imageNamed:@"accept_video"] forState:UIControlStateNormal];
        [acceptBtn setTitle:@"接听" forState:UIControlStateNormal];
        [acceptBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [acceptBtn addTarget:self action:@selector(acceptBtn) forControlEvents:UIControlEventTouchUpInside];
        [_calleeContainerView addSubview:acceptBtn];
        
        UILabel *msgLabel = [UILabel.alloc init];
        msgLabel.viewSize = CGSizeMake(_calleeContainerView.width, 22);
        msgLabel.bottom = cancelBtn.top - FlexHeight(169);
        msgLabel.centerX = _calleeContainerView.middleX;
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.textColor = UIColor.whiteColor;
        msgLabel.font =  [UIFont systemFontOfSize:16];
        msgLabel.text = @"对方向您发起语音通话邀请...";
        [_calleeContainerView addSubview:msgLabel];
        self.msgLabel = msgLabel;
    }
    return _calleeContainerView;
}

- (UIView *)videoView
{
    if (!_videoView) {
        _videoView = [UIView.alloc initWithFrame:self.view.bounds];
        
        UIImageView *otherAvatar = [UIImageView.alloc initWithFrame:CGRectMake(20, Height_NavBar+14, 70, 70)];
        otherAvatar.backgroundColor = UIColor.whiteColor;
        otherAvatar.centerX = _videoView.middleX;
        otherAvatar.layer.cornerRadius = 4;
        otherAvatar.layer.masksToBounds = YES;
        if (self.isInitiator) {
            [otherAvatar sd_setImageWithURL:[NSURL URLWithString:self.callee.avatar]];
        } else {
            [otherAvatar sd_setImageWithURL:[NSURL URLWithString:self.caller.avatar]];
        }
        
        [_videoView addSubview:otherAvatar];
        self.friendAvatar = otherAvatar;
        
        UILabel *nickLabel = [UILabel.alloc initWithFrame:CGRectZero];
        nickLabel.width = _videoView.width - 10 - 10;
        nickLabel.height = 28;
        nickLabel.top = otherAvatar.bottom + 16;
        nickLabel.centerX = otherAvatar.centerX;
        nickLabel.textAlignment = NSTextAlignmentCenter;
        nickLabel.textColor = UIColor.whiteColor;
        nickLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        nickLabel.text = self.isInitiator?self.callee.nick:self.caller.nick;
        [_videoView addSubview:nickLabel];
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
        // 静音
        UIButton *mutexBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        mutexBtn.bounds = CGRectMake(0, 0, 60, 42);
        mutexBtn.centerX = cancelBtn.left * 0.5;
        mutexBtn.centerY = cancelBtn.centerY;
        [mutexBtn setBackgroundImage:[UIImage imageNamed:@"vc_open_audio"] forState:UIControlStateNormal];
        [mutexBtn setBackgroundImage:[UIImage imageNamed:@"vc_close_audio"] forState:UIControlStateSelected];
        [mutexBtn addTarget:self action:@selector(audioEnableBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_videoView addSubview:mutexBtn];
        UILabel *mutexLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 60, 17)];
        mutexLabel.centerX = mutexBtn.centerX;
        mutexLabel.top = mutexBtn.bottom + 10;
        mutexLabel.text = @"静音";
        mutexLabel.font = [UIFont systemFontOfSize:12];
        mutexLabel.textColor = UIColor.whiteColor;
        mutexLabel.textAlignment = NSTextAlignmentCenter;
        [_videoView addSubview:mutexLabel];
        // 免提
        UIButton *speakerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        speakerBtn.bounds = CGRectMake(0, 0, 60, 42);
        speakerBtn.centerX = cancelBtn.right + mutexBtn.centerX;
        speakerBtn.centerY = cancelBtn.centerY;
        [speakerBtn setBackgroundImage:[UIImage imageNamed:@"vc_speaker"] forState:UIControlStateNormal];
        [speakerBtn setBackgroundImage:[UIImage imageNamed:@"vc_speaker_disable"] forState:UIControlStateSelected];
        [speakerBtn addTarget:self action:@selector(switchSpeaker:) forControlEvents:UIControlEventTouchUpInside];
        [_videoView addSubview:speakerBtn];
        UILabel *speakerLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 60, 17)];
        speakerLabel.centerX = speakerBtn.centerX;
        speakerLabel.top = speakerBtn.bottom + 10;
        speakerLabel.text = @"免提";
        speakerLabel.font = [UIFont systemFontOfSize:12];
        speakerLabel.textColor = UIColor.whiteColor;
        speakerLabel.textAlignment = NSTextAlignmentCenter;
        [_videoView addSubview:speakerLabel];
        
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

#pragma mark - actions

- (void)cancelCall
{
    [TIOChat.shareSDK.videoChatManager cancelCall:@""];
}

- (void)refuseBtn
{
    [TIOChat.shareSDK.videoChatManager answer:self.callId type:TIORTCTypeAudio accept:NO ext:@""];
}

- (void)acceptBtn
{
    [TChatSound.shareInstance finishCalling];
    [TIOChat.shareSDK.videoChatManager answer:self.callId type:TIORTCTypeAudio accept:YES ext:@""];
}

- (void)hangupBtn
{
    [TChatSound.shareInstance finishCalling];
    [TIOChat.shareSDK.videoChatManager hangup:TIOCallHangupTypeNormal];
    
    // 正常流程：收到挂断通知=>结束返回上一页
    // 如果因为异常，超时4秒没有收到挂断通知，主动返回上一页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
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

- (void)tio_localReviewReady:(nonnull UIView *)localView {
    NSLog(@"tio_localReviewReady");
}

- (void)tio_receiveCall:(nonnull TIOWxCallItem *)object {
    
}

- (void)tio_remoteViewReady:(nonnull UIView *)remoteView {
    NSLog(@"tio_remoteViewReady");
}

- (void)tio_responseAccept:(nonnull TIOWxCallItemReply *)accept {
    // 对方同意接听
    NSLog(@"tio_responseAccept");
    
    if (accept.result == TIORTCReplyResultCancel) {
        [MBProgressHUD showInfo:accept.reason toView:self.view];
//        // 自动返回上一页
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.navigationController popViewControllerAnimated:YES];
//        });
        
    } else {
        self.msgLabel.text = @"接通中...";
    }
}

/// 渲染远端视频
/// @param view 渲染远端视频的view
/// @param width 远端视频的宽
/// @param height 远端视频的高
- (void)tio_remoteview:(UIView *)view changeWidth:(CGFloat)width height:(CGFloat)height
{
    
}

@end
