//
//  CBSocketData.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2017/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  socket 协议
 *            2Byte              2Byte            1Byte
 *  |--------------------|--------------------|----------|-----------|
 *  |     消息体长度       |       命令码        |  压缩标识  |  header  |
 *  |--------------------|--------------------|----------|-----------|
 *  |                          .                         |           |
 *  |                          .                         |   body    |
 *  |                          .                         |           |
 *  |----------------------------------------------------|-----------|
 */
@interface TIOSocketPackage : NSObject

@property (assign, nonatomic) int16_t bodyLength;// 消息体长度
@property (assign, nonatomic) int16_t cmd;  // 命令码
@property (assign, nonatomic) int8_t gzip;  // gzip
@property (strong, nonatomic) id body;

@property (assign, readonly, nonatomic) NSInteger length;// 总长度

/// 用不到
+ (TIOSocketPackage *)modelWithData:(NSData *)data;

/// 构造自定义消息
/// @param cmd 命令码（自定义，与服务端需一致）
/// @param gzip 压缩
/// @param body 自定义参数体（自定义，格式与服务端需要一致）
+ (TIOSocketPackage *)socketPackageWithCmd:(int16_t)cmd gzip:(int8_t)gzip body:(id)body;

@end

NS_ASSUME_NONNULL_END
