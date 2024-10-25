//
//  P2PMessageMaker.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/15.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOMessage;
@class TIOSession;

/// 消息工厂类
@interface TMessageMaker : NSObject

+ (TIOMessage *)messageForTextWithText:(NSString *)text session:(TIOSession *)session;

+ (TIOMessage *)messageForImage:(UIImage *)image session:(TIOSession *)session;
+ (TIOMessage *)messageForImageData:(NSData *)data session:(TIOSession *)session ext:(NSString  * _Nullable )ext;

+ (TIOMessage *)messageForFileURL:(NSURL *)fileURL session:(TIOSession *)session;

+ (TIOMessage *)messageForVideoURL:(NSURL *)videoURL session:(TIOSession *)session;

+ (TIOMessage *)messageForFriendCard:(NSString *)shareId type:(BOOL)isTeam session:(TIOSession *)session;

+ (TIOMessage *)messageForAudioFileURL:(NSURL *)audioFileURL session:(TIOSession *)session;

/// 计算不同消息类型的最新消息显示
/// @param message 消息
/// @param at 别人@自己
/// @param beread 自己的消息被对方读取状态    0不显示  1:已读 2:未读
/// @param unreadCount 自己未读的消息数
+ (NSMutableAttributedString *)messageForMessage:(TIOMessage *)message isAt:(BOOL)at beread:(NSInteger)beread unreadCount:(NSInteger)unreadCount;
+ (NSString *)tipForMessage:(TIOMessage *)message;
+ (NSString *)videoChatMessageFor:(TIOMessage *)message;
+ (NSMutableAttributedString *)redpackageTipForMessage:(TIOMessage *)message;

/// 对原字符串中的特殊字符编码成转义字符
+ (NSString *)htmlEncode:(NSString *)string;
/// 将包含转义字符的字符串解码
+ (NSString *)htmlDecode:(NSString *)string;


@end

NS_ASSUME_NONNULL_END
