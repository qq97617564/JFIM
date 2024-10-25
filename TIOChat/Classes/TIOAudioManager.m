//
//  TIOAudioManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/31.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOAudioManager.h"
#import "TIOMacros.h"
#import "TIOBroadcastDelegate.h"
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface TIOAudioManager () <AVAudioRecorderDelegate>
@property (strong,  nonatomic) TIOBroadcastDelegate<TIOAudioDelegate> *multiDelegate;

@property (copy,    nonatomic) NSString *audioSavePath;

@property (strong,  nonatomic) AVAudioRecorder *recorder;

@property (assign,  nonatomic) NSTimeInterval maxDuration;

@property (strong,  nonatomic) AVPlayer *player;

@property (strong,  nonatomic) NSTimer *timer;

@property (assign,  nonatomic) NSInteger seconds;

@property (strong,  nonatomic) NSString *playUrl;

@property (strong,  nonatomic) AVPlayerItem *currentPlayerItem;

@property (assign,  nonatomic) BOOL isMaxDuration;

@property (assign,  nonatomic) BOOL isCanceled;

@end

@implementation TIOAudioManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 多播委托管理初始化
        _multiDelegate = (TIOBroadcastDelegate<TIOAudioDelegate> *)[TIOBroadcastDelegate.alloc init];
    }
    return self;
}

- (void)recordWithDuration:(NSTimeInterval)duration
{
    if (![self canRecord]) {
        [_multiDelegate recordAudio:nil didBeganWithError:[NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"未开启麦克风权限"}]];
        return;
    }
    
    self.maxDuration = duration;
    self.isMaxDuration = NO;
    self.isCanceled = NO;
    
    // AVAudioSession
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (session == nil) {
        NSString *err = @"Error creating session: ";
        err = [err stringByAppendingString:[error description]];
        [_multiDelegate recordAudio:nil didBeganWithError:[NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:err}]];
    } else {
        [session setActive:YES error:nil];
    }
    
//    AVEncoderAudioQualityKey
    //设置参数
    NSDictionary *recordSetting = @{AVFormatIDKey:@(kAudioFormatMPEG4AAC),// AAC
                                    AVSampleRateKey: @44100.00f, // 采样率 8000Hz
                                    AVEncoderBitRateKey : @(96000), // 编码比特率
                                    AVEncoderAudioQualityKey : @(AVAudioQualityHigh), // 录音质量
                                    AVNumberOfChannelsKey: @1, // 单声道
                                    AVLinearPCMBitDepthKey: @16, // 采样点位数：16
                                    AVLinearPCMIsNonInterleaved: @NO, // 是否支持浮点处理：NO
                                    AVLinearPCMIsFloatKey: @NO, //
                                    AVLinearPCMIsBigEndianKey: @NO // YES 大端模式 NO 小端模式
                                    
    };
    
    _recorder = [AVAudioRecorder.alloc initWithURL:[NSURL URLWithString:self.audioSavePath] settings:recordSetting error:nil];
    _recorder.delegate = self;
    
    if (_recorder) {
        // 开启定时器
        self.seconds = 0;
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordTimer) userInfo:nil repeats:YES];
        }
        
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
        [_multiDelegate recordAudio:self.audioSavePath didBeganWithError:nil];
        [_multiDelegate recordAudioProgress:0];
    } else {
        [_multiDelegate recordAudio:nil didBeganWithError:[NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"音频格式和文件存储格式不匹配,无法初始化Recorder"}]];
    }
}

- (void)pauseRecord
{
    [_recorder pause];
}

- (void)stopRecord
{
    [_recorder stop];
}

- (BOOL)cancelRecord
{
    self.isCanceled = YES;
    _audioSavePath = nil;
    if ([_recorder isRecording]) {
        [_recorder stop];
        BOOL f = [_recorder deleteRecording];
        return f;
    } else {
        return YES;
    }
}

- (BOOL)isRecording
{
    return _recorder.isRecording;
}

#pragma mark - play

- (void)playAudio:(NSString *)url
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    AVAudioSession *avSession = [AVAudioSession sharedInstance];

    [avSession setCategory:AVAudioSessionCategoryPlayback error:nil];

    [avSession setActive:YES error:nil];
    
    self.playUrl = url;
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    
    self.currentPlayerItem = playerItem;
    
    if (!self.player) {
        self.player = [AVPlayer.alloc initWithPlayerItem:playerItem];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    }
    
    [self.player play];
    
    [_multiDelegate playAudio:url didBeganWithError:nil];
}

- (void)stopPlay
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [self.player pause];
    self.isPlaying = NO;
    [_multiDelegate playAudio:self.playUrl didFinishedWithError:nil];
//    self.player = nil;
//    self.currentPlayerItem = nil;
}

- (void)playbackFinished:(NSNotification *)notice {
    [_multiDelegate playAudio:self.playUrl didFinishedWithError:nil];
    self.currentPlayerItem = nil;
    self.player = nil;
    self.isPlaying = NO;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
     
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
                self.isPlaying = NO;
                [_multiDelegate playAudio:self.playUrl didBeganWithError:[NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"未知状态，不能播放"}]];
                break;
            case AVPlayerStatusReadyToPlay:
                self.isPlaying = YES;
                break;
            case AVPlayerStatusFailed:
                self.isPlaying = NO;
                [_multiDelegate playAudio:self.playUrl didBeganWithError:[NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"音频加载失败"}]];
                break;
            default:
                break;
        }
        
        [self.currentPlayerItem removeObserver:self forKeyPath:@"status"];
    }
}

#pragma mark - AudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self closeTimer];
    
    _audioSavePath = nil;
    if (flag) {
        if (self.seconds<1) {
            [_multiDelegate recordAudio:_audioSavePath didFinishedWithMaxDuration:self.isMaxDuration error:[NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"说话时间太短"}]];
        } else {
            if (!self.isCanceled) {
                [_multiDelegate recordAudio:recorder.url.absoluteString didFinishedWithMaxDuration:self.isMaxDuration error:nil];
            }
        }
    } else {
        [_multiDelegate recordAudio:_audioSavePath didFinishedWithMaxDuration:self.isMaxDuration error:[NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"录音失败"}]];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    _audioSavePath = nil;
    [_multiDelegate recordAudio:_audioSavePath didFinishedWithMaxDuration:self.isMaxDuration error:error];
    self.seconds = 0;
}

#pragma mark - 私有

- (NSString *)audioSavePath
{
    if (!_audioSavePath) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        _audioSavePath = [path stringByAppendingPathComponent:@"voice_record.m4a"];
    }
    
    return _audioSavePath;
}

- (BOOL)canRecord {
    __block BOOL bCanRecord = YES;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            } else {
                bCanRecord = NO;
            }
        }];
    }
    return bCanRecord;
}

- (void)recordTimer
{
    self.seconds++;
    [_multiDelegate recordAudioProgress:self.seconds];
    
    if (self.seconds > self.maxDuration-1) {
        self.isMaxDuration = YES;
        [self closeTimer];
        [self stopRecord];
    } else {
    }
}

- (void)closeTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - 绑定代理

- (void)addDelegate:(id<TIOAudioDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIOAudioDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)handler:(TIOSocketPackage *)data
{
    
}

@end
