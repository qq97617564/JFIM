//
//  TIOCmdConfiguator.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *TIOCmdKey;

/// 心跳
FOUNDATION_EXPORT TIOCmdKey const TioCmdHeartbeatKey;
/// 握手请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdShakehandReq;
/// 握手响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdShakehandResp;
/// 进入房间请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdEnterGroupReq;
/// 进入房间响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdEnterGroupResp;
/// 离开房间请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdLeaveGroupReq;
/// 离开房间响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdLeaveGroupResp;
/// 进入房间通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdEnterGroupNtf;
/// 离开房间通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdLeaveGroupNtf;
/// 群聊请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdTeamChatReq;
/// 群聊通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdTeamChatNtf;
/// 私聊请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdP2PChatReq;
/// 私聊通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdP2PChatNtf;
/// 获取房间信息请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdFetchGroupInforRequestKey;
/// 获取房间信息响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdFetchGroupInforResponseKey;
/// 禁言／解禁请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdForbiddenSayRequestKey;
/// 禁言／解禁响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdForbiddenSayResponseKey;
/// 禁言／解禁通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdForbiddenSayNotifiKey;
/// 设置／解除管理请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdSetManagerRequestKey;
/// 设置／解除管理响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdSetManagerResponseKey;
/// 设置／解除管理通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdSetManagerNotifiKey;
/// 更新用户信息
FOUNDATION_EXPORT TIOCmdKey const TioCmdUpdateUserTokenReq;
/// 更新用户信息响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdUpdateUserTokenResp;
/// 消息提醒
FOUNDATION_EXPORT TIOCmdKey const TioCmdMesssageNotifiKey;
/// 撤回消息 请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdRevokeReq;
/// 消息撤回 通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdRevokeNtf;
/// 进群请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdEnterTeamReq;
/// 进群响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdEnterTeamResp;
/// 获取p2p聊天记录数据-请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdP2pQueryChatRecordReq;
/// 已读请求： 我告诉服务器，张三发给我的私聊消息已读
FOUNDATION_EXPORT TIOCmdKey const TioCmdP2pAlreadyReadReq;
FOUNDATION_EXPORT TIOCmdKey const TioCmdP2pAlreadyReadNtf;
/// 已读请求： 告诉服务器，某群的信息已经阅读了
FOUNDATION_EXPORT TIOCmdKey const TioCmdGroupAlreadyReadReq;
/// 异常通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdErrorNtf;
/// 操作通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdOperNtf;
/// 群操作通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdGroupOperNtf;
/// 系统通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdSystemNtf;
/// 私聊历史消息响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdP2PHistoryMessagesResp;
/// 群聊历史消息响应
FOUNDATION_EXPORT TIOCmdKey const TioCmdTeamHistoryMessagesResp;
/// 更新token请求
FOUNDATION_EXPORT TIOCmdKey const TioCmdUpdateTokenReq;
/// 激活会话状态查询
FOUNDATION_EXPORT TIOCmdKey const TioCmdActiveSessionReq;
/// 激活会话通知
FOUNDATION_EXPORT TIOCmdKey const TioCmdActiveSessionNtf;

#pragma mark - webrtc 命令

FOUNDATION_EXPORT TIOCmdKey const WxCall01Req;
FOUNDATION_EXPORT TIOCmdKey const WxCall02Ntf;
FOUNDATION_EXPORT TIOCmdKey const WxCall03ReplyReq;
FOUNDATION_EXPORT TIOCmdKey const WxCall04ReplyNtf;
FOUNDATION_EXPORT TIOCmdKey const WxCall05OfferSdpReq;
FOUNDATION_EXPORT TIOCmdKey const WxCall06OfferSdpNtf;
FOUNDATION_EXPORT TIOCmdKey const WxCall07AnswerSdpReq;
FOUNDATION_EXPORT TIOCmdKey const WxCall08AnswerSdpNtf;
FOUNDATION_EXPORT TIOCmdKey const WxCall09OfferIceReq;
FOUNDATION_EXPORT TIOCmdKey const WxCall10OfferIceNtf;
FOUNDATION_EXPORT TIOCmdKey const WxCall11AnswerIceReq;
FOUNDATION_EXPORT TIOCmdKey const WxCall12AnswerIceNtf;
FOUNDATION_EXPORT TIOCmdKey const WxCall13EndReq;
FOUNDATION_EXPORT TIOCmdKey const WxCall14EndNtf;
FOUNDATION_EXPORT TIOCmdKey const WxCall02_1CancelReq;
FOUNDATION_EXPORT TIOCmdKey const WxCall02_2CancelNtf;
FOUNDATION_EXPORT TIOCmdKey const WxCallRespNtf;

@interface TIOCmdConfiguator : NSObject

/// 可以直接以字典的形式配置
/// 注意：Key必须为CBTioCmdKey类型
@property (nonatomic, strong) NSMutableDictionary *dic;

- (void)setIntCmd:(NSInteger)cmd forKey:(TIOCmdKey)key;
- (void)setStrCmd:(NSString *)cmd forKey:(TIOCmdKey)key;

- (NSInteger)IntCmdForKey:(TIOCmdKey)key;
- (NSString *)StrCmdForKey:(TIOCmdKey)key;

@end

NS_ASSUME_NONNULL_END
