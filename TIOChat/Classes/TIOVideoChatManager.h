//
//  TIOVideoChatManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/5/26.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"
#import "TIOWxCallItem.h"
#import "TIOWxCallItemReply.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^TIOCallStartHandler)(NSError * __nullable error, NSString *callId);

@protocol TIOVideoChatDelegate <NSObject>
@optional

/// 收到呼叫
/// @param object 呼叫的消息对象：通话ID｜呼叫者
- (void)tio_receiveCall:(TIOWxCallItem *)object;

/// 收到callee的接听拒绝响应
- (void)tio_responseAccept:(TIOWxCallItemReply *)accept;

/// 本地视频预览已准备好
/// @param localView 本地视频的view
- (void)tio_localReviewReady:(UIView *)localView;

/// 远端视频画面已准备好
/// @param remoteView 远端视频画面
- (void)tio_remoteViewReady:(UIView *)remoteView;

/// 被挂断
- (void)tio_hangup:(TIOWxCallItem *)object;

/// 信令接通
- (void)tio_SingnalConnected;
/// 通话已经建立连接，开始通话
- (void)tio_callConnected;

/// 通话被断开
/// @param error 异常信息
- (void)tio_callDisconnected:(nullable NSError *)error;
/// 远端视频尺寸变化
- (void)tio_remoteview:(UIView *)view changeWidth:(CGFloat)width height:(CGFloat)height;

@end

@interface TIOVideoChatManager : NSObject

/// 仅仅是：YES 双方已经建立点对点通话 NO：没有建立通话，包括：呼叫，被呼叫状态
@property (assign,  nonatomic) BOOL isChating;

/// 呼叫
/// @param callee 被呼叫的人
/// @param type 通话类型：视频｜音频
/// @param completion 对方若接听，会返回本次通话ID
- (void)call:(NSString *)callee
        type:(TIORTCType)type 
  completion:(nullable TIOCallStartHandler)completion;

/// 接听
/// @param callId 通话ID
/// @param accept 是否同意接听
/// @param message 附加的扩展消息。拒绝接听的理由
/// @param type 通话类型：视频｜音频
- (void)answer:(NSString *)callId type:(TIORTCType)type accept:(BOOL)accept ext:(NSString *)message;

/// 挂断
- (void)hangup:(TIOCallHangupType)hangupType;
/// 断网下挂断（一般不需要调用）
- (void)hangupInDisconnected:(TIOCallHangupType)hangupType;

/// 取消呼叫
/// @param callId 通话ID
- (void)cancelCall:(NSString *)callId;

// 开启/关闭摄像头
- (BOOL)setCameraEnable:(BOOL)enable;
/// 摄像头状态
//- (BOOL)cameraEnable;
// 切换摄像头
- (void)switchCamera:(TIOCallCamera)camera;
/// 当前摄像头
//- (TIOCallCamera)currentCamera;

// 静音
- (BOOL)setMute:(BOOL)mute;
/// 麦克风静音
- (void)setMicMutex:(BOOL)mutex;
// 切换扬声器
- (void)switchAudioDevice:(TIOCallAudioDevice)device;
//- (TIOCallAudioDevice)currentAudioDevice;
// 调节音量

// 获取当前的本地预览
// 获取远端预览


- (void)destory;

#pragma mark - 后期需要的功能
// 开启美颜
// 关闭美颜

/// 添加聊天委托
/// @param delegate 聊天委托
- (void)addDelegate:(id<TIOVideoChatDelegate>)delegate;

/// 移除聊天委托
/// @param delegate 聊天委托
- (void)removeDelegate:(id<TIOVideoChatDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
