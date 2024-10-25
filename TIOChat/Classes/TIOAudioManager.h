//
//  TIOAudioManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/31.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOSocketPackage;

@protocol TIOAudioDelegate <NSObject>

@optional

/// 开始录音
/// @param audioSavePath 录音保存路径
- (void)recordAudio:(nullable NSString *)audioSavePath didBeganWithError:(nullable NSError *)error;

/// 结束录音
/// @param audioSavePath 录音保存路径
/// @param maxDuration 触发了最大录音时长
- (void)recordAudio:(nullable NSString *)audioSavePath didFinishedWithMaxDuration:(BOOL)maxDuration error:(nullable NSError *)error;

/// 录音已经取消 audioSavePath也会被清空
- (void)recordAudioDidCancel;

/// 录音过程中，时间进度
/// @param currentTime 当前的第几秒的时间
- (void)recordAudioProgress:(NSTimeInterval)currentTime;

#pragma mark - 播放

/// 声音开始播放
- (void)playAudio:(nullable NSString *)audioUrl didBeganWithError:(nullable NSError *)error;

/// 声音播放结束
- (void)playAudio:(nullable NSString *)audioUrl didFinishedWithError:(nullable NSError *)error;

@end

@interface TIOAudioManager : NSObject

/// 正在录音
@property (assign,  nonatomic) BOOL isRecording;
/// 正在播放
@property (assign,  nonatomic) BOOL isPlaying;

#pragma mark - 录音

/// 开始录音
/// @param duration 最大录音时长
- (void)recordWithDuration:(NSTimeInterval)duration;

/// 暂停录音
- (void)pauseRecord;

/// 停止录音
- (void)stopRecord;

/// 取消录音
- (BOOL)cancelRecord;

/// 添加聊天委托
/// @param delegate 聊天委托
- (void)addDelegate:(id<TIOAudioDelegate>)delegate;

#pragma mark - 播放

- (void)playAudio:(NSString *)url;

- (void)stopPlay;

/// 移除聊天委托
/// @param delegate 聊天委托
- (void)removeDelegate:(id<TIOAudioDelegate>)delegate;

- (void)handler:(TIOSocketPackage *)data;

@end

NS_ASSUME_NONNULL_END
