//
//  TIOWxCallItem.h
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOWxCallItem : NSObject

/// 通话id
@property (copy,    nonatomic) NSString *callId;
/// 通话对方的ipid（ipinfo表的id）
@property (copy,    nonatomic) NSString *toipid;
/// 发起人的ipid（ipinfo表的id）
@property (copy,    nonatomic) NSString *fromipid;
/// 通话发起人的userid
@property (copy,    nonatomic) NSString *fromuid;
@property (copy,    nonatomic) NSString *fromavatar;
@property (copy,    nonatomic) NSString *fromnick;
/// 通话对方的userid
@property (copy,    nonatomic) NSString *touid;
/// 对方响应时间点
@property (copy,    nonatomic) NSString *resptime;
/// 通话发起人的channelcontextid
@property (copy,    nonatomic) NSString *fromcid;
/// 通话对方的channelcontextid
@property (copy,    nonatomic) NSString *tocid;
/// 挂断一方的uid，如果是系统挂断，则是null
@property (copy,    nonatomic) NSString *hangupuid;
/// 呼叫开始时间（一方请求通话请求的时间）
@property (copy,    nonatomic) NSString *calltime;
/// 接通时间（对方同意通话时间）
@property (copy,    nonatomic) NSString *connectedtime;
/// 通话结束时间
@property (copy,    nonatomic) NSString *endtime;
/// 挂断类型  1、正常挂断 2、拒接挂断 3、对方正在通话 4、TCP断开时，系统自动挂断 5、客户端出现异常，系统自动挂机（譬如获取摄像头失败等），这个请求是客户端发起的挂断请求 6、ICE服务器异常，这个请求是客户端发起的挂断请求 7、系统重启 8、对方不在线 9、等待响应超时 10、发起方取消了通话 99、还没有挂断
@property (assign,  nonatomic) NSInteger hanguptype;
/// 通话时长long
@property (assign,  nonatomic) NSInteger callduration;
/// 通话类型：1、 音频通话，2、视频通话
@property (assign,  nonatomic) TIORTCType type;
/// 接通操作时长
@property (assign,  nonatomic) NSInteger streamwait;
/// 发起通话人员的设备类型（DeviceType），1：PC，2：安卓，3：IOS
@property (assign,  nonatomic) TIORTCDeviceType fromdevice;
/// 通话对方的设备类型（DeviceType），1：PC，2：安卓，3：IOS
@property (assign,  nonatomic) TIORTCDeviceType todevice;
/// 呼叫状态：1、发起呼叫， 2、信令接通，3、流媒体接通，4、通话结束（拒接、占线、挂断都属于通话结束）
@property (assign,  nonatomic) TIORTCStatus status;
/// 响应操作时长
@property (assign,  nonatomic) NSInteger respwait;

@end

NS_ASSUME_NONNULL_END
