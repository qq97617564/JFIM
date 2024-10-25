//
//  TIOCmdConfiguator.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOCmdConfiguator.h"

TIOCmdKey const TioCmdHeartbeatKey = @"TioCmdHeartbeatKey"; /// 心跳
TIOCmdKey const TioCmdShakehandReq = @"TioCmdShakehandRequestKey";  /// 握手请求
TIOCmdKey const TioCmdShakehandResp = @"TioCmdShakehandResponseKey"; /// 握手响应
TIOCmdKey const TioCmdEnterGroupReq = @"TioCmdEnterGroupRequestKey"; /// 进入房间请求
TIOCmdKey const TioCmdEnterGroupResp = @"TioCmdEnterGroupResponseKey";/// 进入房间响应
TIOCmdKey const TioCmdLeaveGroupReq = @"TioCmdLeaveGroupRequestKey"; /// 离开房间请求
TIOCmdKey const TioCmdLeaveGroupResp = @"TioCmdLeaveGroupResponseKey";/// 离开房间响应
TIOCmdKey const TioCmdEnterGroupNtf = @"TioCmdEnterGroupNotifKey";   /// 进入房间通知
TIOCmdKey const TioCmdLeaveGroupNtf = @"TioCmdLeaveGroupNotifKey";   /// 离开房间通知
TIOCmdKey const TioCmdTeamChatReq = @"TioCmdTeamChatRequestKey";   /// 发送群聊请求
TIOCmdKey const TioCmdTeamChatNtf = @"TioCmdTeamChatNotifiKey";  /// 群聊通知
TIOCmdKey const TioCmdP2PChatReq = @"TioCmdP2PChatRequestKey";   /// 私聊请求
TIOCmdKey const TioCmdP2PChatNtf = @"TioCmdP2PChatNotifiKey";  /// 私聊通知
TIOCmdKey const TioCmdFetchGroupInforRequestKey = @"TioCmdFetchGroupInforRequestKey";    /// 获取房间信息请求
TIOCmdKey const TioCmdFetchGroupInforResponseKey = @"TioCmdFetchGroupInforResponseKey";   /// 获取房间信息响应
TIOCmdKey const TioCmdForbiddenSayRequestKey = @"TioCmdForbiddenSayRequestKey";   /// 禁言／解禁请求
TIOCmdKey const TioCmdForbiddenSayResponseKey = @"TioCmdForbiddenSayResponseKey";  /// 禁言／解禁响应
TIOCmdKey const TioCmdForbiddenSayNotifiKey = @"TioCmdForbiddenSayNotifiKey";    /// 禁言／解禁通知
TIOCmdKey const TioCmdSetManagerRequestKey = @"TioCmdSetManagerRequestKey";     /// 设置／解除管理请求
TIOCmdKey const TioCmdSetManagerResponseKey = @"TioCmdSetManagerResponseKey";    /// 设置／解除管理响应
TIOCmdKey const TioCmdSetManagerNotifiKey = @"TioCmdSetManagerNotifiKey";  /// 设置／解除管理通知
TIOCmdKey const TioCmdUpdateUserTokenReq = @"TioCmdUpdateUserTokenRequestKey";  /// 更新用户信息
TIOCmdKey const TioCmdUpdateUserTokenResp = @"TioCmdUpdateUserTokenResponseKey"; /// 更新用户信息响应
TIOCmdKey const TioCmdMesssageNotifiKey = @"TioCmdMesssageNotifiKey";  /// 消息提醒
TIOCmdKey const TioCmdRevokeReq = @"TioCmdRevokeReq";
TIOCmdKey const TioCmdRevokeNtf = @"TioCmdRevokeNotifiKey";  /// 消息撤回通知
TIOCmdKey const TioCmdEnterTeamReq = @"TioCmdEnterTeamRequestKey"; /// 进群请求
TIOCmdKey const TioCmdEnterTeamResp = @"TioCmdEnterTeamResponseKey"; /// 进群响应
TIOCmdKey const TioCmdP2pQueryChatRecordReq = @"TioCmdP2pQueryChatRecordReq";
TIOCmdKey const TioCmdP2pAlreadyReadReq = @"TioCmdP2pAlreadyReadReq";
TIOCmdKey const TioCmdP2pAlreadyReadNtf = @"TioCmdP2pAlreadyReadNtf";
TIOCmdKey const TioCmdGroupAlreadyReadReq = @"TioCmdGroupAlreadyReadReq";
TIOCmdKey const TioCmdErrorNtf = @"TioCmdErrorNtf";
TIOCmdKey const TioCmdOperNtf = @"TioCmdOperNtf";
TIOCmdKey const TioCmdGroupOperNtf = @"TioCmdGroupOperNtf";
TIOCmdKey const TioCmdSystemNtf = @"TioCmdSystemNtf";
TIOCmdKey const TioCmdP2PHistoryMessagesResp = @"TioCmdP2PHistoryMessagesResp";
TIOCmdKey const TioCmdTeamHistoryMessagesResp = @"TioCmdTeamHistoryMessagesResp";
TIOCmdKey const TioCmdUpdateTokenReq = @"TioCmdUpdateTokenReq";
TIOCmdKey const TioCmdActiveSessionReq = @"TioCmdActiveSessionReq";
TIOCmdKey const TioCmdActiveSessionNtf = @"TioCmdActiveSessionNtf";

#pragma mark - webrtc

TIOCmdKey const WxCall01Req = @"WxCall01Req";
TIOCmdKey const WxCall02Ntf = @"WxCall02Ntf";
TIOCmdKey const WxCall03ReplyReq = @"WxCall03ReplyReq";
TIOCmdKey const WxCall04ReplyNtf = @"WxCall04ReplyNtf";
TIOCmdKey const WxCall05OfferSdpReq = @"WxCall05OfferSdpReq";
TIOCmdKey const WxCall06OfferSdpNtf = @"WxCall06OfferSdpNtf";
TIOCmdKey const WxCall07AnswerSdpReq = @"WxCall07AnswerSdpReq";
TIOCmdKey const WxCall08AnswerSdpNtf = @"WxCall08AnswerSdpNtf";
TIOCmdKey const WxCall09OfferIceReq = @"WxCall09OfferIceReq";
TIOCmdKey const WxCall10OfferIceNtf = @"WxCall10OfferIceNtf";
TIOCmdKey const WxCall11AnswerIceReq = @"WxCall11AnswerIceReq";
TIOCmdKey const WxCall12AnswerIceNtf = @"WxCall12AnswerIceNtf";
TIOCmdKey const WxCall13EndReq = @"WxCall13EndReq";
TIOCmdKey const WxCall14EndNtf = @"WxCall14EndNtf";
TIOCmdKey const WxCall02_1CancelReq = @"WxCall02_1CancelReq";
TIOCmdKey const WxCall02_2CancelNtf = @"WxCall02_2CancelNtf";
TIOCmdKey const WxCallRespNtf = @"WxCallRespNtf";

@implementation TIOCmdConfiguator

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _dic = [NSMutableDictionary dictionary];
        [self addDefaultCmd];
    }
    
    return self;
}

- (void)addDefaultCmd
{
    NSDictionary *dic = @{
        TioCmdHeartbeatKey : @(1),
        TioCmdShakehandReq : @(599),
        TioCmdShakehandResp : @(600),
        TioCmdEnterTeamReq : @(4),
        TioCmdEnterTeamResp : @(5),
        TioCmdEnterGroupNtf : @(6),
        TioCmdLeaveGroupNtf : @(614),
        TioCmdOperNtf : @(700),
        TioCmdErrorNtf : @(701),
        TioCmdP2PChatReq : @(602),
        TioCmdP2PChatNtf : @(603),
        TioCmdTeamChatReq : @(606),
        TioCmdTeamChatNtf : @(607),
        TioCmdP2pQueryChatRecordReq : @(604),
        TioCmdUpdateUserTokenReq : @(20),
        TioCmdUpdateUserTokenResp : @(21),
        TioCmdRevokeReq : @(612),
        TioCmdRevokeNtf : @(613),
        TioCmdP2pAlreadyReadReq : @(608),
        TioCmdP2pAlreadyReadNtf : @(609),
        TioCmdGroupAlreadyReadReq : @(610),
        TioCmdSystemNtf : @(738),
        TioCmdGroupOperNtf : @(750),
        TioCmdP2PHistoryMessagesResp : @(605),
        TioCmdTeamHistoryMessagesResp : @(621),
        TioCmdUpdateTokenReq : @(760),
        TioCmdActiveSessionReq : @(776),
        TioCmdActiveSessionNtf : @(777),
        
        WxCall01Req : @(800),
        WxCall02Ntf : @(801),
        WxCall03ReplyReq : @(802),
        WxCall04ReplyNtf : @(803),
        WxCall05OfferSdpReq : @(804),
        WxCall06OfferSdpNtf : @(805),
        WxCall07AnswerSdpReq : @(806),
        WxCall08AnswerSdpNtf : @(807),
        WxCall09OfferIceReq : @(808),
        WxCall10OfferIceNtf : @(809),
        WxCall11AnswerIceReq : @(810),
        WxCall12AnswerIceNtf : @(811),
        WxCall13EndReq : @(812),
        WxCall14EndNtf : @(813),
        WxCall02_1CancelReq : @(814),
        WxCall02_2CancelNtf : @(815),
        WxCallRespNtf : @(888)
    };
    self.dic = [NSMutableDictionary dictionaryWithDictionary:dic];
}

- (void)setIntCmd:(NSInteger)cmd forKey:(nonnull TIOCmdKey)key
{
    _dic[key] = @(cmd);
}

- (NSInteger)IntCmdForKey:(TIOCmdKey)key
{
    if ([_dic.allKeys containsObject:key]) {
        return [_dic[key] integerValue];
    }
    
    return -1006;
}

- (void)setStrCmd:(NSString *)cmd forKey:(nonnull TIOCmdKey)key
{
    if (cmd) {
        _dic[key] = cmd;
    } else {
        NSAssert(cmd&&cmd.length>0, @"命令码不能为空！");
    }
}

- (NSString *)StrCmdForKey:(TIOCmdKey)key
{
    if ([_dic.allKeys containsObject:key]) {
        return _dic[key];
    }
    return @"";
}

@end
