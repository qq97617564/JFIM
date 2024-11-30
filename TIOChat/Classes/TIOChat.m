//
//  TIOChat.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/18.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOChat.h"
#import "TIOBroadcastDelegate.h"
#import "TIOCmdConfiguator.h"
#import "GCDAsyncSocket.h"
#import "TIOSocketEncoder.h"
#import "TIOSocketDecoder.h"
#import "TIOConfig.h"
#import "TIOCmdConfiguator.h"
#import "TIOSocketPackage.h"
#import "TIOSDKOption.h"
#import "TIOHTTPSManager.h"
#import "NSString+MD5.h"
#import "UIDevice+CBExtension.h"
#import "TIONetworkNotificationCenter.h"
#import "TIOMacros.h"
#import "TIOTokenStorage.h"
#import "TIOSessionActiveCenter.h"
#import "BGDB.h"
#import "TIOUploadManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface TIOChat () <TIODecoderDelegate,TIOEncoderDelegate,GCDAsyncSocketDelegate>

@property (nonatomic, strong) TIOBroadcastDelegate<TIOChatLinkDelegate> *multiDelegate;

/// socket
@property (strong, nonatomic) GCDAsyncSocket *tioSocket;
/// 封包 将TIOSocketPackage对象转成socket
@property (strong, nonatomic) TIOSocketEncoder *tioEncoder;
/// 解包 将socket从半包沾包变成TIOSocketPackage对像
@property (strong, nonatomic) TIOSocketDecoder *tioDecoder;
/// 心跳计时器
@property (retain, nonatomic) NSTimer *heartbeatTimer;
/// socket短线重联次数
@property (assign, nonatomic) NSInteger retryCount;

@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *tokenName;

/// 是否是退出前台行为  包括：挂起、进入后台
@property (assign, nonatomic) BOOL isExitFront;

@property (strong,  nonatomic) TIOSDKOption *option;

@property (copy,    nonatomic) NSString *registrationID;

/// 1: 手机的网络故障。如：手机未开启网络、切换网络期间断网、关闭手机网络等行为
/// 0: 外力网络故障，因联网的网络路由设备导致的网络断开。如：路由器断电、断网、热点关闭等
/// 默认状态为0，外力导致的网络故障
@property (assign,  nonatomic) NSInteger networkErrorReason;

@end

NSString * APPContentTypeForPathExtension(NSString *extension) {
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
}

@implementation TIOReportRequest
@end

@implementation TIOChat

+ (instancetype)shareSDK
{
    static TIOChat *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (void)dealloc
{
    [self removeListen];
    [self finish];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _multiDelegate = (TIOBroadcastDelegate<TIOChatLinkDelegate> *)[TIOBroadcastDelegate.alloc init];
        _cmdManager = [TIOCmdConfiguator.alloc init];
        _allowOnlineOnMultiTerminal = YES;
        _tioEncoder = [TIOSocketEncoder.alloc init];
        _tioDecoder = [TIOSocketDecoder.alloc init];
        [self addListen];
    }
    
    return self;
}

#pragma mark - Socket

- (void)startSSL
{
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
    [settings setObject:self.config.linkAddress
                 forKey:(NSString *)kCFStreamSSLPeerName];
    [_tioSocket startTLS:settings];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [_heartbeatTimer invalidate];
    _heartbeatTimer = nil;
    
    //TODO: 握手请求
    [self shakehandToServer];
    
    if (!_heartbeatTimer) {
        NSInteger heart = self.config.heartBeatInterval;
        _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:heart target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
        
    }
    [_heartbeatTimer fire];
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)err
{
    [_heartbeatTimer invalidate];
    
    if (err.code == 57) {
        
        // 网络断线导致，重连
        _tioSocket.userData = @(TIOSocketOfflineByNet);
        
        if (self.networkErrorReason == 1) {
            /// 手机自身没有接入互联网
            TIOLog(@"\n=================\n=================\n网络错误：手机没有网络 Socket断开连接\nerr:%@\nuserData:%@\n=================\n=================",err.localizedDescription,sock.userData);
        } else {
            TIOLog(@"\n=================\n=================\n网络错误：已连接的网络不通，请检查路由器 Socket断开连接\nerr:%@\nuserData:%@\n=================\n=================",err.localizedDescription,sock.userData);
            /// 此时进行自动重连
            [self reConnectToServer];
        }
        
        [self->_multiDelegate tio_linkDisconnected:TIOSocketOfflineByNet];
    }
    else {
        if ([sock.userData  isEqual:@(TIOSocketOfflineByUser)]) {
            TIOLog(@"\n=================\n=================\n客户端断开socket\nerr:%@\nuserData:%@\n=================\n=================",err.localizedDescription,sock.userData);
            // 用户主动cut
            [self->_multiDelegate tio_linkDisconnected:TIOSocketOfflineByUser];
            return;
        }
        // 服务端端开
        _tioSocket.userData = @(TIOSocketOfflineByServer);
        TIOLog(@"\n=================\n=================\n大概率服务端断开socket\nerr:%@\nuserData:%@\n=================\n=================",err.localizedDescription,sock.userData);
        [self->_multiDelegate tio_linkDisconnected:TIOSocketOfflineByServer];
        
        [self reConnectToServer];
//        [NSNotificationCenter.defaultCenter postNotificationName:@"kOnKickNotification" object:@"kOnKickNotification" userInfo:@{@"code":@"3000", @"msg":err.localizedDescription?:@""}];
    }
}

/// 重连
- (void)reConnectToServer
{
    // 如果此时未登录  不进行重连
    if (!self.loginManager.isLogined) {
        return;
    }
    
    if (self.retryCount-- > 0) {
        // 重联计数期内，每1秒尝试建立连接一次
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.config.timeoutInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TIOLog(@"\n=================\n=================\n正在自动尝试重连\n=================\n=================")
            if (!self.tioSocket.isConnected) {
                [self connectToServer];
            }
        });
    }
}

-(void)longConnectToSocket{
    //TODO: 调用代理发送心跳
    TIOSocketPackage *data = [[TIOSocketPackage alloc] init];
    data.cmd = [self.cmdManager IntCmdForKey:TioCmdHeartbeatKey];
    data.gzip = 0;
    [self.tioEncoder encodeWithData:data output:self];
}

- (void)shakehandToServer
{
    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:self.config.httpsAddress]];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:self.tokenName]) {
            self.token = cookie.value;
            break;
        }
    }
    
    if (!self.token) {
        TIOLog(@"token丢失");
        return;
    }
    
    if (!self.config.secrectKey) {
        TIOLog(@"未配置IM的握手密钥，secrectKey");
        return;
    }
    
    NSString *token = self.token?:@"";
    NSString *deviceinfo = UIDevice.currentDevice.deviceModel;
    NSString *devicetype = @"3";
    NSString *cid = @"tio-ios";
    NSString *imei = UIDevice.currentDevice.IMEI;
    
    NSString *signString = [NSString stringWithFormat:@"%@%@%@%@%@%@",token,imei,deviceinfo,devicetype,cid,self.config.secrectKey];
    NSString *sign = [signString MD5Digest];
    
    NSInteger cmd = [self.cmdManager IntCmdForKey:TioCmdShakehandReq];
    
    TIOSocketPackage *model = [[TIOSocketPackage alloc] init];
    model.cmd = cmd;
    model.gzip = 0;
    model.body = @{
                   @"token" : token ?: @"",
                   @"jpushinfo" : self.registrationID?:@"",     // 1开启推送通知 2不开启
                   @"sign" : sign,
                   @"mobileInfo" : @{
                           @"appversion" : NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"],
                           @"imei" : imei,
                           @"deviceinfo" : deviceinfo,
                           @"cid" : cid,
                           @"resolution" : UIDevice.currentDevice.resolution,
                           @"size" : UIDevice.currentDevice.size,
                           @"operator" : UIDevice.currentDevice.mobileOperator
                           },
                   @"devicetype" : devicetype
                   };
    [self.tioEncoder encodeWithData:model output:self];
    TIOLog(@"握手信息 ： %@",model.body);
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // 解包
    [self.tioDecoder decodeWithData:data output:self];
    [_tioSocket readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [_tioSocket readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler
{
    completionHandler(YES);
}

#pragma mark - 编解码

- (void)encoder:(TIOSocketEncoder *)encoder encodedData:(NSData *)encodedData
{
    //TODO: 发送编码后的socket
    [_tioSocket writeData:encodedData withTimeout:-1 tag:0];
}

/// 接收socket
- (void)decoder:(TIOSocketDecoder *)decoder decodeData:(TIOSocketPackage *)data
{
    TIOLog(@"data = %@",data);
    //TODO: 消息广播转发给委托的代理
    /// 按命令码转发给不同的管理器的回调代理
    NSInteger cmd = data.cmd;
    if (cmd == [self.cmdManager IntCmdForKey:TioCmdShakehandResp]) {
        // 握手响应
        self.networkErrorReason = 0;
        TIOLog(@"\n=================\n=================\n[socket] 握手响应完成\n=================\n=================")
        self.retryCount = self.config.reconnectCount;
        [self.loginManager handler:data];
        [self.systemManager handlerServerConnected:YES];
        // 获取最新的焦点
        TIOSocketPackage *package = [TIOSocketPackage.alloc init];
        package.cmd = [self.cmdManager IntCmdForKey:TioCmdActiveSessionReq];
        package.gzip = 1;
        [self sendMessage:package];
        [_multiDelegate tio_linkConnected];
    } else if (cmd == [self.cmdManager IntCmdForKey:TioCmdTeamChatNtf]) {
        // 群聊通知
        [self.chatManager handler:data];
        [self.conversationManager handler:data];
    } else if (cmd == [self.cmdManager IntCmdForKey:TioCmdP2PChatNtf]) {
        // 私聊通知
        [self.chatManager handler:data];
        [self.conversationManager handler:data];
    } else if (cmd == [self.cmdManager IntCmdForKey:TioCmdEnterTeamResp]) {
        // 进群响应
    } else if (cmd == [self.cmdManager IntCmdForKey:TioCmdErrorNtf]) {
//        TIOLog(@"异常通知");
        [self.loginManager handler:data];
        [self.systemManager handler:data];
    } else if (cmd == [self.cmdManager IntCmdForKey:TioCmdOperNtf]) {
//        TIOLog(@"操作通知")
        if ([data.body[@"oper"] integerValue] == 4) {
            [self.conversationManager handler:data];
        } else if ([data.body[@"oper"] integerValue] == 5) {
            // 用户删除的好友的操作：通知上层开发者：删除通讯录好友 + 删除会话
            [self.conversationManager handler:data];
        } else if ([data.body[@"oper"] integerValue] == 8) {
            [self.conversationManager handler:data];
        } else if ([data.body[@"oper"] integerValue] == 21) {
            // 置顶
            [self.conversationManager handler:data];
        } else if ([data.body[@"oper"] integerValue] == 22) {
            // 取消置顶
            [self.conversationManager handler:data];
        } else if ([data.body[@"oper"] integerValue] == 9) {
            // 撤回消息
            [self.chatManager handler:data];
        } else if ([data.body[@"oper"] integerValue] == 10) {
            // 删除消息
            [self.chatManager handler:data];
            [self.conversationManager handler:data];
        } else if ([data.body[@"oper"] integerValue] == 7) {
            // 已读
            [self.chatManager handler:data];
            [self.conversationManager handler:data];
        } else if ([data.body[@"oper"] integerValue] == 1 || [data.body[@"oper"] integerValue] == 2) {
            // 删除会话
            [self.conversationManager handler:data];
        } else {
            [self.conversationManager handler:data];
        }
    } else if (cmd == [self.cmdManager IntCmdForKey:TioCmdSystemNtf]) {
//        TIOLog(@"系统通知");
        [self.systemManager handler:data];
        if ([data.body[@"code"] integerValue] == 33) {
            [self.conversationManager handler:data];
            NSNumber *uid = data.body[@"uid"];
            if ([uid.stringValue isEqualToString:self.loginManager.userInfo.userId]) {
                // 自己的信息发生更新
                [self.loginManager updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) { 
                }];
            }
        } else if ([data.body[@"code"] integerValue] == 32) {
            /// 好友删除通知
            [self.friendManager handler:data];
        }
    } else if (cmd == [self.cmdManager IntCmdForKey:TioCmdGroupOperNtf]) {
//        TIOLog(@"群操作通知");
        [self.chatManager handler:data];
        [self.conversationManager handler:data];
        [self.teamManager handler:data];
    } else if (cmd == [self.cmdManager IntCmdForKey:TioCmdP2PHistoryMessagesResp]) {
//        TIOLog(@"私聊历史消息响应");
        [self.conversationManager handler:data];
    } else if (cmd == [self.cmdManager IntCmdForKey:TioCmdTeamHistoryMessagesResp]) {
//        TIOLog(@"群聊历史消息响应");
        [self.conversationManager handler:data];
    } else if (cmd == [self.cmdManager IntCmdForKey:WxCall02Ntf]) {
//        TIOLog(@"B 收到 被呼叫通知");
        [self.singalManager handler:data];
    } else if (cmd == [self.cmdManager IntCmdForKey:WxCall04ReplyNtf]) {
//        TIOLog(@"A 收到 B 同意或拒绝的通知");
        [self.singalManager handler:data];
    } else if (cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall08AnswerSdpNtf]) {
//        TIOLog(@"A 收到 B 的SDP应答");
        [self.singalManager handler:data];
    } else if (cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall12AnswerIceNtf]) {
//        TIOLog(@"A 收到 B 的ICE应答");
        [self.singalManager handler:data];
    } else if (cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall06OfferSdpNtf]) {
//        TIOLog(@"B 收到 A 的SDP");
        [self.singalManager handler:data];
    } else if (cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall10OfferIceNtf]) {
//        TIOLog(@"B 收到 A 的ICE");
        [self.singalManager handler:data];
    } else if (cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall14EndNtf]) {
//        TIOLog(@"结束通话");
        [self.singalManager handler:data];
    } else if (cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCall02_2CancelNtf]) {
//        TIOLog(@"自己取消呼叫");
        [self.singalManager handler:data];
    } else if (cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:WxCallRespNtf]) {
//        TIOLog(@"处理当前设备是否是合法的接听设备");
        [self.singalManager handler:data];
    } else if (cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdActiveSessionNtf]) {
//        TIOLog(@"收到激活会话状态机的通知");
        TIOSessionActiveCenter.shareInstance.focusMap = data.body[@"focusMap"];
    } else if (cmd == 16) {
        // 群聊发送过快
//        TIOLog(@"群聊发送过快");
        [self.systemManager handler:data];
    } else if (cmd == 709) {
        // 请求的会话详情
        [self.conversationManager handler:data];
    } else {
        // 额外自定义的消息
        [self.systemManager handler:data];
    }
}

#pragma mark - get


- (GFWalletManager *) gfHttpManager{
    if (!_gfHttpManager) {
        _gfHttpManager = [GFWalletManager.alloc init];
    }
    return _gfHttpManager;
}


- (TIOFriendManager *)friendManager
{
    if (!_friendManager) {
        _friendManager = [TIOFriendManager.alloc init];
    }
    return _friendManager;
}

- (TIOChatManager *)chatManager
{
    if (!_chatManager) {
        _chatManager = [TIOChatManager.alloc init];
    }
    return _chatManager;
}

- (TIOTeamManager *)teamManager
{
    if (!_teamManager) {
        _teamManager = [TIOTeamManager.alloc init];
    }
    return _teamManager;
}

- (TIOSystemManager *)systemManager
{
    if (!_systemManager) {
        _systemManager = [TIOSystemManager.alloc init];
    }
    return _systemManager;
}

- (TIOConversationManager *)conversationManager
{
    if (!_conversationManager) {
        _conversationManager = [TIOConversationManager.alloc init];
    }
    return _conversationManager;
}

- (TIOLoginManager *)loginManager
{
    if (!_loginManager) {
        _loginManager = [TIOLoginManager.alloc init];
    }
    return _loginManager;
}

- (TIOSingalManager *)singalManager
{
    if (!_singalManager) {
        _singalManager = [TIOSingalManager.alloc init];
    }
    return _singalManager;
}

- (TIOVideoChatManager *)videoChatManager
{
    if (!_videoChatManager) {
        _videoChatManager = [TIOVideoChatManager.alloc init];
    }
    return _videoChatManager;
}

- (TIOAudioManager *)audioManager
{
    if (!_audioManager) {
        _audioManager = [TIOAudioManager.alloc init];
    }
    return _audioManager;
}

- (TIOWalletManager *)walletManager
{
    if (!_walletManager) {
        _walletManager = [TIOWalletManager.alloc init];
    }
    return _walletManager;
}

- (NSString *)imei
{
    return UIDevice.currentDevice.IMEI;
}

#pragma mark - 监听

- (void)addListen
{
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(networkChangedConnected:)
                                               name:TIONetworkConnectedNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(networkChangedDisconnected:) name:TIONetworkDisconnectedNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(obersverKick:)
                                               name:@"kOnKickNotification"
                                             object:@"kOnKickNotification"];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appDidEnterBack:)
                                               name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appWillEnterForeground:)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(updateToken:)
                                               name:@"TIOTokenUpdated"
                                             object:@"11"];
}

- (void)removeListen
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:TIONetworkConnectedNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:TIONetworkDisconnectedNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"kOnKickNotificationNotification" object:@"kOnKickNotification"];
}

#pragma mark - 网络断开与重连

/*
 触发长链接断开有两个因素：1、APP进入后台 2、（Wi-Fi、蜂窝网络）网络断开
 触发长链接重连也有两个因素：1、APP进入前台 2、（Wi-Fi、蜂窝网络）网络连接上
 */

///（Wi-Fi、蜂窝网络）网络重连
- (void)networkChangedConnected:(NSNotification *)notification
{
    // 网络已连接
    // 需要重练socket
    // 重新握手
    // 需要判断是否登录
    if (self.loginManager.isLogined) {
        
        self.networkErrorReason = 0;
        
        if (_tioSocket) {
            /*
             进到这里，表明网络事先并没有断开，而是触发了下面3和4的场景
             原因如下：
             1、先连着Wi-Fi 再开启4G，系统不会告诉任何事情
             2、先连着Wi-Fi 再断开4G，系统也不会告诉任何事情
             3、先连着4G再开启Wi-Fi 系统会告诉我网络连接了
             4、先连着4G再关闭Wi-Fi 系统也会告诉我网络连接了
             */
            if (self.videoChatManager.isChating) {
                /*
                 进到这里，表明此刻正处于
                 */
                [self.videoChatManager hangupInDisconnected:TIOCallHangupTypeNormal];// 去执行挂断操作
                [_videoChatManager destory];// 先销毁配置
            }
        }
        
        /// 先关闭心跳
        if (_heartbeatTimer) {
            [_heartbeatTimer invalidate];
            _heartbeatTimer = nil;
        }
        
        if (_tioSocket) {
            _tioSocket.userData = @(TIOSocketOfflineByUser);
            [_tioSocket disconnect];
            _tioSocket = nil;
        }
        
        [self requestBaseConfig];
    }
}

///（Wi-Fi、蜂窝网络）网络断开
- (void)networkChangedDisconnected:(NSNotification *)notification
{
    // 网络被断开
    self.networkErrorReason = 1; // 标记是手机网络没开或断开
    
    [self.systemManager handlerServerConnected:NO];
    
    if (self.tioSocket.isConnected) {
        // 手动断开
        // 结束服务
        if (_heartbeatTimer) {
            [_heartbeatTimer invalidate];
            _heartbeatTimer = nil;
        }
        if (_tioSocket) {
            _tioSocket.userData = @(TIOSocketOfflineByUser);
            [_tioSocket disconnect];
            _tioSocket = nil;
        }
    }
    
    if (self.videoChatManager.isChating) {
        [_videoChatManager destory];// 先销毁配置
    }
}

- (void)obersverKick:(NSNotification *)notification
{
    [self finish];
}

/// APP 已经进入后台
- (void)appDidEnterBack:(id)sender
{
    BOOL isRtcing = [NSUserDefaults.standardUserDefaults boolForKey:@"isRtcing"]; // 区别【videoChatManager.isChating】：isRtcing为yes表示音视频完整的流程，呼叫-被呼叫-建立通话整个环节。
    if (isRtcing) {
        return;
    }
    
    if (self.tioSocket.isConnected && !self.videoChatManager.isChating) {
        // 手动断开
        self.isExitFront = YES;
        [self finish];
    }
}

/// APP 将要恢复前台
- (void)appWillEnterForeground:(id)sender
{
    if (self.loginManager.isLogined) {
        if (self.isExitFront) {
            [self lunch];
        }
    }
}

- (void)updateToken:(id)sender
{
//    TIOLog(@"\n更新token 新token:%@ 旧token:%@\n",TIOTokenStorage.shareStorage.token,TIOTokenStorage.shareStorage.oldToken);
    
    NSString *oldToken = TIOTokenStorage.shareStorage.oldToken;
    NSString *token = TIOTokenStorage.shareStorage.token;
    
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = [self.cmdManager IntCmdForKey:TioCmdUpdateTokenReq];
    data.gzip = 0;
    data.body = @{
        @"t" : token,
        @"o" : oldToken
    };
    [self sendMessage:data];
}

#pragma mark - Public

+ (void)setLogEnable:(BOOL)enable
{
    [NSUserDefaults.standardUserDefaults setBool:enable forKey:@"TIO_LOG_ENABLE"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSString *)SDKVersion
{
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

- (void)setConfig:(TIOConfig *)config
{
    _config = config;
    self.tokenName = config.cookieName;
    TIOTokenStorage.shareStorage.cookieName = config.cookieName;
}

- (void)registerWithOption:(TIOSDKOption *)option
{
    self.option = option;
    [TIOHTTPSManager registerBaseURL:[NSURL URLWithString:self.config.httpsAddress]];
    [TIOUploadManager registerBaseURL:[NSURL URLWithString:self.config.httpsAddress]];
}

- (void)lunch
{
    [TIONetworkNotificationCenter.shareManager start];
}

- (void)requestBaseConfig
{
    TIOWeakSelf
    [TIOHTTPSManager tio_POST:@"/config/base" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOStrongSelfElseReturn
        TIOLog(@"config: \n%@",responseObject);
        NSInteger heart_timeout = [responseObject[@"data"][@"im_heartbeat_timeout"] integerValue];
        if (self.config.heartBeatInterval==0) {
            self.config.heartBeatInterval = heart_timeout/1000/2;
        }
        [self connectToServer];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOStrongSelfElseReturn
        TIOLog(@"获取基础配置失败");
    }];
    
    //配置资源服务器
    [TIOHTTPSManager tio_POST:@"/app/conf" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOStrongSelfElseReturn
        TIOLog(@"config: \n%@",responseObject);
        NSString *res_server = responseObject[@"data"][@"res_server"] ;
        self.config.resourceAddress = res_server;
        [self connectToServer];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOStrongSelfElseReturn
        TIOLog(@"失败");
    }];
}

- (void)connectToServer
{
    TIOWeakSelf
    if (!_config.linkAddress || _config.linkAddress.length == 0) {
        // 用户没有配置IM的地址以及端口号
        // 需要从服务器获取
        START_TIME(t2)
        [TIOHTTPSManager tio_POST:@"/im/imserver" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            TIOStrongSelfElseReturn
            
            END_TIME(t2, @"[socket] /im/imserver 耗时结束")
            
            TIOLog(@"IM配置%@",responseObject);
            
     
            NSString *ip = responseObject[@"data"][@"appIp"];
            NSInteger port = [responseObject[@"data"][@"appPort"] integerValue];

            NSInteger timeout = [responseObject[@"data"][@"node"][@"timeout"] integerValue];
            if (timeout > 0) {
                self.config.heartBeatInterval = timeout/1000/2;
            }
            NSInteger ssl = [responseObject[@"data"][@"appSsl"] integerValue];
            
//            NSString *ip = responseObject[@"data"][@"ip"];
//            NSInteger port = [responseObject[@"data"][@"port"] integerValue];
//
//            NSInteger timeout = [responseObject[@"data"][@"timeout"] integerValue];
//            if (timeout > 0) {
//                self.config.heartBeatInterval = timeout/1000/2;
//            }
            
            self.config.linkAddress = ip;
            self.config.linkPort = port;
            self.option.isOpenSSL = ssl == 1 ? true: false;
            
            if (ip) {

                [NSUserDefaults.standardUserDefaults setObject:ip forKey:@"TIO_ip"];
                [NSUserDefaults.standardUserDefaults setInteger:port forKey:@"TIO_port"];
                
                [self connectToHost:ip port:port];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            TIOStrongSelfElseReturn
            TIOLog(@"获取IM配置失败");
        }];
    } else {
        [self connectToHost:self.config.linkAddress port:self.config.linkPort];
    }
    
}

- (void)connectToHost:(NSString *)ip port:(NSInteger)port
{
    if (_tioSocket) {
        _tioSocket.userData = @(TIOSocketOfflineByUser);
        [_tioSocket disconnect];
        _tioSocket = nil;
    }
    
    // 启动服务
    self.tioSocket    = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    [self.tioSocket connectToHost:ip onPort:port error:&error];
    
    if (!error){
        TIOLog(@"\n=================\n=================\n[socket] 连接成功\n=================\n=================")
        if (self.option.isOpenSSL) {
            [self startSSL];
        }
    }else{
        TIOLog(@"初始连接失败");
        TIOLog(@"\n=================\n=================\n[socket] 初始连接失败\n=================\n=================")
    }
}

- (void)finish
{
    // 结束服务
    if (_heartbeatTimer) {
        [_heartbeatTimer invalidate];
        _heartbeatTimer = nil;
    }
    if (_tioSocket) {
        _tioSocket.userData = @(TIOSocketOfflineByUser);
        [_tioSocket disconnect];
        _tioSocket = nil;
    }
    [TIONetworkNotificationCenter.shareManager stop];
}

- (void)updateApnsToken:(NSData *)token
{
    //TODO: 更新推送证书的token
}

- (void)updatePushKitToken:(NSData *)token
{
    //TODO: 更新PushKit证书的token
}

- (void)report:(TIOReportRequest *)request completion:(nonnull void (^)(NSError * _Nullable, id _Nonnull))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (request.type == TIOReportTypeUser) {
        if (request.uid) {
            params[@"touid"] = request.uid;
        } else {
            completion([NSError errorWithDomain:TIOChatErrorDomain code:1005 userInfo:@{NSLocalizedDescriptionKey: @"举报用户时，用户id不存在"}],@"举报用户时，用户id不存在");
            return;
        }
    } else if (request.type == TIOReportTypeTeam) {
        if (request.teamid) {
            params[@"groupid"] = request.teamid;
        } else {
            completion([NSError errorWithDomain:TIOChatErrorDomain code:1005 userInfo:@{NSLocalizedDescriptionKey: @"举报群时，群id不存在"}],@"举报群时，群id不存在");
            return;
        }
    } else if (request.type == TIOReportTypeMessage) {
        if (request.teamid && request.messageid) {
            params[@"mid"] = request.messageid;
            params[@"groupid"] = request.teamid;
        } else {
            completion([NSError errorWithDomain:TIOChatErrorDomain code:1005 userInfo:@{NSLocalizedDescriptionKey: @"举报群消息时，群id或消息id不存在"}],@"举报群消息时，群id或消息id不存在");
            return;
        }
    } else {
        completion([NSError errorWithDomain:TIOChatErrorDomain code:1005 userInfo:@{NSLocalizedDescriptionKey: @"举报类型非法"}],@"举报类型非法");
        return;
    }
    
    if (request.reason) {
        params[@"reason"] = request.reason;
    }
    
    [TIOHTTPSManager tio_POST:@"/sys/report" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error, @"");
    }];
}

- (void)sendMessage:(TIOSocketPackage *)message
{
    [self.tioEncoder encodeWithData:message output:self];
}

- (BOOL)isConnected
{
    return self.tioSocket.isConnected;
}

- (void)bindRegistrationID:(NSString *)registrationID
{
    self.registrationID = registrationID;
}

- (void)uploadLog:(NSString *)url callback:(nonnull void (^)(NSError * _Nullable))callback
{
    __block NSData *data = [NSData dataWithContentsOfFile:url];
    if (!data) {
        return;
    }
    
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [NSURL URLWithString:encodeUrl];
    
//    [TIOHTTPSManager tio_UPLOAD:@"/sys/errlog" parameters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        NSString *fileName = fileURL.lastPathComponent;
//        NSString *ext = fileURL.pathExtension;
//        NSString *mimeType = APPContentTypeForPathExtension(ext);
//
//        [formData appendPartWithFileData:data name:@"uploadFile" fileName:fileName mimeType:mimeType];
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        callback(nil);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        callback(error);
//    }];
    
    [TIOUploadManager upload:@"/sys/errlog" parameters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *fileName = fileURL.lastPathComponent;
        NSString *ext = fileURL.pathExtension;
        NSString *mimeType = APPContentTypeForPathExtension(ext);
        
        [formData appendPartWithFileData:data name:@"uploadFile" fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)addDelegate:(id<TIOChatLinkDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIOChatLinkDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - private



@end
