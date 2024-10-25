//
//  TIOMessageAttachmnet.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOMessageAttachmnet : NSObject

/// 视频：封面地址
/// 图片：缩略图地址
@property (copy, nonatomic) NSString *coverurl;

/// 视频地址/图片地址
@property (copy, nonatomic) NSString *url;

/// 文件名
@property (copy, nonatomic) NSString *filename;

/// 图片：大图的size，单位是字节
/// 文件：文件的size，单位是字节
/// 视频：视频size，单位是字节
/// 音频：音频size，单位是字节
@property (assign, nonatomic) NSInteger size;

/// 图片：缩略图的宽
/// 视频：封面的宽
@property (assign, nonatomic) NSInteger coverwidth;

/// 图片：小图的size，单位是字节
/// 视频：封图的size，单位是字节
@property (assign, nonatomic) NSInteger coversize;

/// 图片：缩略图的高
/// 视频：封面的高
@property (assign, nonatomic) NSInteger coverheight;

/// 图片：大图的宽
/// 视频：视频宽
@property (assign, nonatomic) NSInteger width;

/// 图片：大图的ah高
/// 视频：视频高
@property (assign, nonatomic) NSInteger height;

#pragma mark - 以下字段在构建发送消息时使用 发送音频、视频、文件、图片等消息时
/// 本地数据  音频、视频、文件、图片等数据
@property (strong, nonatomic) NSData *localData;
/// 本地文件URL沙盒路径   音频、视频、文件、图片等路径
@property (strong, nonatomic) NSURL *localURL;
/// 扩展名
@property (copy,   nonatomic) NSString *ext;

/// 类型
@property (assign, nonatomic) TIOFileType fileicontype;


#pragma mark - 名片

@property (assign,  nonatomic) NSInteger cardtype;  // 1:个人 2:群
@property (copy,    nonatomic) NSString *bizavatar; // 被分享人/群的头像
@property (copy,    nonatomic) NSString *bizid;     // 被分享人的UID或者群ID 在音频中：业务id-群id或者好友id
@property (copy,    nonatomic) NSString *bizname;   // 被分享人/群的昵称
@property (copy,    nonatomic) NSString *shareFromUid;  // 分享着的UID
@property (copy,    nonatomic) NSString *shareToBizid;  // 分享到的会话ID

#pragma mark - call

@property (assign,  nonatomic) NSTimeInterval duration;
@property (copy,    nonatomic) NSString *hangupuid;
@property (assign,  nonatomic) TIOCallHangupType hanguptype;
@property (assign,  nonatomic) TIORTCType callType;

#pragma mark - Audio

@property (assign,  nonatomic) NSInteger seconds;
@property (copy,    nonatomic) NSString *from;

#pragma mark - 红包
/// 【易支付】单号         聊天消息中， 标记红包的唯一ID
@property (copy,    nonatomic) NSString *serialnumber;
/// 【新生支付】红包id   聊天消息中，标记红包的唯一ID
@property (copy,    nonatomic) NSString *rid;
/// 红包文案
@property (copy,    nonatomic) NSString *text;
/// 状态 ：SUCCESS-已抢完;TIMEOUT-24小时超时;SEND-抢红包中
@property (copy,    nonatomic) NSString *status;
/// 类型：1：普通红包；2：人品红包
@property (assign,  nonatomic) NSInteger mode;

@end

NS_ASSUME_NONNULL_END
