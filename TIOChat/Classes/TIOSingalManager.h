//
//  TIORTCManager.h
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIOWxCallItem.h"
#import "TIOWxCallItemReply.h"
#import "TIOWxCallItemAnswerSDP.h"
#import "TIOWxCallItemAnswerCandidate.h"
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOSocketPackage;

@protocol TIORTCDelegate <NSObject>

- (void)onIceServer:(NSArray <RTCIceServer *>*)iceservers error:(NSError *_Nullable)error;
#pragma mark - B收到呼叫、A收到接受/拒绝
/// 801
- (void)onReciver_recieveCall:(TIOWxCallItem *)model;
/// 803
- (void)onCaller_recieveAnswerCall:(TIOWxCallItemReply * )result;
/// 信令已经接通  “接听中”
- (void)onReciver_SingnalConnected;
#pragma mark - B收到SDP、A收到B的SDP
/// 805
- (void)onReciver_recieveSDP:(TIOWxCallItemAnswerSDP *)callItem;
/// 807
- (void)onCaller_recieveAnswerSDP:(TIOWxCallItemAnswerSDP *)callItem;
#pragma mark - B收到Candidate、A收到B的Candidate
/// 809
- (void)onReciever_recieveCandidate:(TIOWxCallItemAnswerCandidate *)callItem;
/// 811
- (void)onCaller_recieveAnswerCandidate:(TIOWxCallItemAnswerCandidate *)callItem;
- (void)onHangup:(TIOWxCallItem *)callItem;
- (void)onCancelCall:(TIOWxCallItem *)callItem;

- (void)onNetworkChange:(BOOL)connected;

@end

@interface TIOSingalManager : NSObject

- (void)start;
/// 800
- (void)caller_callUser:(NSString *)userId callType:(TIORTCType)callType;
/// 802
- (void)reciver_replyCall:(NSString *)callId result:(TIORTCReplyResult)result resaon:(NSString *)reason;
/// 804
- (void)caller_offerSDP:(NSDictionary *)sdp toCallId:(NSString *)callId;
/// 806
- (void)reciver_offerSDP:(NSDictionary *)sdp toCallId:(NSString *)callId;
/// 808
- (void)caller_offerCandidate:(NSDictionary *)candidate toCallId:(NSString *)callId;
/// 810
- (void)reciever_offerCandidate:(NSDictionary *)candidate toCallId:(NSString *)callId;
/// 812
-(void)hangup:(NSString *)callId type:(TIOCallHangupType)hangupType;

- (void)cancelCall:(NSString *)callId;

- (void)handler:(TIOSocketPackage *)data;

/// 添加聊天委托
/// @param delegate 聊天委托
- (void)addDelegate:(id<TIORTCDelegate>)delegate;

/// 移除聊天委托
/// @param delegate 聊天委托
- (void)removeDelegate:(id<TIORTCDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
