//
//  CBIMConfig.h
//  CawBar
//
//  Created by admin on 2019/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOConfig : NSObject

/// IM 服务器端口号（必填）
@property (nonatomic,   assign) uint16_t linkPort;
/// IM 服务器地址（必填）
@property (nonatomic,   copy)   NSString *linkAddress;
/// 资源服务器地址
@property (nonatomic,   copy)   NSString *resourceAddress;
/// HTTPS 服务器地址（必填）
@property (nonatomic,   copy)   NSString *httpsAddress;
/// IM与服务端通信的密钥（必填）
@property (nonatomic,   copy)   NSString *secrectKey;

/// 心跳间隔时长
/// 默认从服务器获取，
/// 如果自定义设置，优先使用设置的心跳值
@property (nonatomic,   assign) NSInteger heartBeatInterval;

/// 重连间隔时长 每次自动重连的间隔时间
@property (nonatomic,   assign) NSInteger timeoutInterval;
/// 重连次数 默认60 * 60 次， 每隔timeoutInterval秒自动重连一次
/// 服务端端开后，触发重连的次数
@property (nonatomic,   assign) NSInteger reconnectCount;

/// kCFStreamPropertySSLSettings 的安全密钥
/// 一般默认是主机名，如果有特殊情况，请自定义
@property (nonatomic,   copy)   NSString *SSLSettingsName;

/// 务必配置cookieName
@property (nonatomic,   copy)   NSString *cookieName;

@end

NS_ASSUME_NONNULL_END
