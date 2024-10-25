//
//  TIODefines.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#ifndef TIODefines_h
#define TIODefines_h

/**
 *  消息内容类型枚举
 */
typedef NS_ENUM(NSInteger, TIOMessageType){
  
    TIOMessageTypeText          = 0,    ///< 文本类型消息
  
    TIOMessageTypeImage         = 1,    ///< 图片类型消息
  
    TIOMessageTypeAudio         = 2,    ///< 声音类型消息
  
    TIOMessageTypeVideo         = 3,    ///< 视频类型消息
  
    TIOMessageTypeLocation      = 4,    ///< 位置类型消息
 
    TIOMessageTypeNotification  = 5,    ///< 通知类型消息

    TIOMessageTypeFile          = 6,    ///< 文件类型消息

    TIOMessageTypeRed           = 7,    ///< 红包类型消息
 
    TIOMessageTypeTip           = 10,   ///< 提醒类型消息
  
    TIOMessageTypeRobot         = 11,   ///< 机器人类型消息
 
    TIOMessageTypeSuperLink     = 12,   ///< 超链接类型消息 类似在微信里分享的美团红包
   
    TIOMessageTypeCard          = 13,   ///< 个人/群名片
    
    TIOMessageTypeVideoChat     = 14,   ///< 视频通话
    
    TIOMessageTypeAudioChat     = 15,   ///< 语音通话
    
    TIOMessageTypeRichTip       = 16,   ///< 富文本提醒类型消息
  
    TIOMessageTypeCustom        = 100   ///< 自定义类型消息
};

/**
 *  消息送达状态枚举
 */
typedef NS_ENUM(NSInteger, TIOMessageDeliveryState){
    /**
     *  消息发送失败
     */
    TIOMessageDeliveryStateFailed,
    /**
     *  消息发送中
     */
    TIOMessageDeliveryStateDelivering,
    /**
     *  消息发送成功
     */
    TIOMessageDeliveryStateDeliveried
};

typedef NS_ENUM(NSInteger, TIOSessionType) {
    /**
     *  P2P
     */
    TIOSessionTypeP2P  = 0,
    /**
     *  群
     */
    TIOSessionTypeTeam = 1,
    /**
     *  聊天室
     */
    TIOSessionTypeChatroom = 2,
    /**
     *  超大群
     */
    TIOSessionTypeSuperTeam = 5,
};

typedef NS_ENUM(NSInteger, TIOTeamUserRole) {
    TIOTeamUserRoleNotMember    =   0, ///< 非群成员
    TIOTeamUserRoleOwner    =   1,     ///< 群主
    TIOTeamUserRoleMember   =   2,     ///< 成员
    TIOTeamUserRoleManager  =   3,     ///< 管理员
};


typedef NS_ENUM(NSUInteger, TIOMessageSendBy) {
    TIOMessageSendBySystem  =   1, ///< 系统发出的消息
    TIOMessageSendByUser    =   2,   ///< 用户发出的消息
};


typedef NS_ENUM(NSUInteger, TIOUserSex) {
    TIOUserSexMan   =   1,  ///< 男性
    TIOUserSexWomen =   2,  ///< 女性
    TIOUserSexUnkown=   3,  ///< 保密未知
};

typedef NS_ENUM(NSUInteger, TIOSessionLinkStatus) {
    TIOSessionLinkStatusUnknown =   0,  ///< 未知
    TIOSessionLinkStatusValid   =   1,  ///<  有效的连接
    TIOSessionLinkStatusInvalid =   2,  ///<  无效的连接
};

#pragma mark - 音视频

typedef NS_ENUM(NSUInteger, TIORTCType) {
    TIORTCTypeAudio = 1,    ///< 音频通话
    TIORTCTypeVideo = 2,    ///< 视频通话
};

typedef NS_ENUM(NSUInteger, TIORTCDeviceType) {
    TIORTCDeviceTypePC = 1,
    TIORTCDeviceTypeAndroid = 2,
    TIORTCDeviceTypeIOS = 3,
};

typedef NS_ENUM (NSUInteger, TIORTCStatus) {
    TIORTCStatusCalling         =   1,    ///< 正在发起筒话
    TIORTCStatusSingnalConnected=   2,   ///< 信令接通
    TIORTCStatusMediaConnected  =   3, ///< 流媒体接通
    TIORTCStatusCallFinished    =   4,   ///< 通话结束
};

typedef NS_ENUM(NSUInteger, TIORTCReplyResult) {
    TIORTCReplyResultAgree    = 1,    ///< 同意接听
    TIORTCReplyResultCancel   = 2,    ///< 拒绝接听
    TIORTCReplyResultNoInputDevices = 3,    ///< 无输入设备
};

typedef NS_ENUM(NSUInteger, TIOCallCamera) {
    TIOCallCameraFront, ///< 前置摄像头
    TIOCallCameraBack   ///< 后置摄像头
};

typedef NS_ENUM(NSUInteger, TIOCallAudioDevice) {
    TIOCallAudioDeviceSpeaker,  ///< 扬声器
    TIOCallAudioDeviceEarphone  ///< 耳机
};

typedef NS_ENUM(NSUInteger, TIOCallHangupType) {
    TIOCallHangupTypeNormal         = 1,    ///< 正常挂断
    TIOCallHangupTypeRefuse         = 2,    ///< 拒接挂断
    TIOCallHangupTypeInCalling      = 3,    ///< 对方正在通话
    TIOCallHangupTypeNetError       = 4,    ///< TCP断开时，系统自动挂断
    TIOCallHangupTypeMobileError    = 5,    ///< 客户端出现异常，系统自动挂机（譬如获取摄像头失败等），这个请求是客户端发起的挂断请求
    TIOCallHangupTypeIceError       = 6,    ///< ICE服务器异常，这个请求是客户端发起的挂断请求
    TIOCallHangupTypeSystemRestart  = 7,    ///< 系统重启
    TIOCallHangupTypeNotOnline      = 8,    ///< 对方不在线
    TIOCallHangupTypeTimeout        = 9,    ///< 等待响应超时
    TIOCallHangupTypeCallerHangup   = 10,   ///< 发起方取消了通话
    TIOCallHangupTypeNone           = 99    ///< 还没有挂断
};


typedef NS_ENUM(NSUInteger, TIOFileType) {
    TIOFileTypePDF  = 1, ///< PDF
    TIOFileTypeTXT  = 2, ///< TXT
    TIOFileTypeDOC  = 3, ///< DOC
    TIOFileTypeXLS  = 4, ///< XLS
    TIOFileTypePPT  = 5, ///< PPT
    TIOFileTypeAPK  = 6, ///< APK
    TIOFileTypeIMG  = 7, ///< IMG
    TIOFileTypeZIP  = 8, ///< ZIP
    TIOFileTypeVIDEO= 9, ///< VIDEO
    TIOFileTypeAUDIO= 10,///< AUDIO
    TIOFileTypeOTHER= 11,///< OTHER
};

typedef NS_ENUM(NSUInteger, TIOReportType) {
    TIOReportTypeUser   =   1, ///< 举报用户
    TIOReportTypeTeam   =   2, ///< 举报群
    TIOReportTypeMessage=   3, ///< 举报消息
};

#endif /* TIODefines_h */
