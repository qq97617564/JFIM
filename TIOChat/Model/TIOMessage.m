//
//  TIOMessage.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/25.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOMessage.h"
#import "NSObject+CBJSONSerialization.h"
#if __has_include(<YYModel/YYModel.h>)
#import <YYModel.h>
#else
#import "YYModel.h"
#endif

@interface TIOMessage ()
/// 消息内容
@property (copy, nonatomic) NSString *c;
@property (copy, nonatomic) NSString *nick;
@property (copy, nonatomic) NSString *mid;
/// 该消息是否由系统发出，1、是系统发出的消息，2、不是系统发的消息
@property (assign, nonatomic) NSInteger sendbysys;
/// 已读标识。1、已读，2、未读
@property (assign, nonatomic) NSInteger readflag;
/// 发送方的userid，此字段和curruid对比
@property (assign, nonatomic) NSInteger uid;
/// 接收方的userid
@property (assign, nonatomic) NSInteger touid;
/// 消息格式。1、普通文本消息，2、博客，3、文件，4、音频，5、视频，6：图片
@property (assign, nonatomic) NSInteger ct;
/// 消息的类型：1：正常消息：2：操作消息
@property (assign, nonatomic) NSInteger msgtype;
/// 聊天会话id
@property (assign, nonatomic) NSInteger chatlinkid;
@property (assign, nonatomic) NSInteger t;
@property (copy, nonatomic) NSString *readtime;

@end

@implementation TIOMessage

- (id)copyWithZone:(NSZone *)zone
{
    return [self modelCopy];
}

@end
