# 集成
# 一、 工程目录结构

.
├── TIOChat  **（SDK，不依赖APP中的代码）**
├── tio-chat-ios **（APP）**
│   ├── TIOChatKit **（可扩展的聊天页组件，不依赖APP中的代码）**
│   ├── Common（公共组件库、工具库、资源库、常量宏的定义）
│   │   ├── Lib **封装的工具库和UI库**
│   │   │   ├── UIKit `钱包、强提示弹窗、加号弹窗、聊天页、按钮`等基础UI组件
│   │   │   └── ToolKit `网络、UIImage\UIImageView、输入框校验、消息模版`等
│   │   ├── Defins `配置API服务器、资源服务器、二维码地址、密钥`
│   │   └── Resourse
│   ├── Modules（业务模块）
│   │   ├── Friends ```好友通讯录```
│   │   ├── Teams ```自己的群聊列表```
│   │   ├── LoginAndRegister ```登录注册```
│   │   ├── Mine ```个人中心```
│   │   ├── Session ```私聊/群聊会话```
│   │   └── SessionList ```会话列表```
│   ├── README.md
│   ├── TIOTabBarController.h
│   ├── ViewController.h
└── └── main.m

* APP中的文件命名

# `（⚠️不包括SDK、TIOChatKit）Demo中文件均只以T作前缀。例如：TTabBarViewConreoller`




# 二、工程集成配置
## 1、工程内引入SDK
⚠️ 如果是源码版，请直接忽略这一步

手动拖入 **TIOChatSDK.framework** ：放到工程里，建议放在Frameworks下面，如此工程所示位置

## 2、更改APP名称：
**target -> General -> Display Name** 
## 3、pod安装相应依赖库

### 3.1
销售包内已经安装集成所需的Pod库，如果自己重新`pod install` 请注意AFNetworking版本要为 3.2.1

如需自行 `pod install` 
* 请先删除销售包内和pod有关的 Podfile.lock、Pods/、tio-chat-ios.xcworkspace。
* `pod install` 
⚠️ 这个过程可能会比较慢

## 4、隐私权限：
    1、Privacy - Camera Usage Description ： 摄像头
    2、Privacy - Microphone Usage Description ：麦克风
    3、Privacy - Photo Library Usage Description ：相册

## 5、推送
    
参考APP源码Appdelegate.m 中，关于推送的部分，在
`- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken`
中调用 SDK 的 `bindRegistrationID` 方法，将极光推送和SDK进行绑定

如下：
    
```
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  /// Required - 注册 DeviceToken
    // important!!!! 和TIO SDK 绑定
    [TIOChat.shareSDK bindRegistrationID:JPUSHService.registrationID];
    [JPUSHService registerDeviceToken:deviceToken];
}
```
## 6、钱包集成
### 6.1 易支付相关文件集成
项目中使用的是易支付，需要到易支付自行申请相关证书。钱包的所有代码均在/Common/Lib/UIKit/Wallet。申请到的易支付相关文件证书，在/Common/Lib/UIKit/Wallet/vendor中做替换
### 6.2 代码中商户号修改
在 utils.m 类的 `+(void)configuration:(EHKWeboxManager * )wallet walletid:(nonnull NSString *)walletid token:(nonnull NSString *)token businessCode:(EHKWEBOX_BUSINESSCODE)businessCode vc:(nonnull UIViewController *)sender` 方法中 的 `wallet.merchantId = @"商户号";` 填入商户号。

# 三、TIOChat/源码 配置及使用
引用示例，在需要用到SDK的类中，以下面之一的方式倒入SDK
`#import "TIOChat.h"` 或者 `#import <TIOChatSDK/TIOChatSDK.h>`


## 1、在入口类Appdelegate.m 中配置TIOChat/源码
### 1.1 配置二维码的下载识别地址、资源服务器地址前缀、H5地址前缀
在 `/Common/ServerConfig.h` 内
 QR_SERVER  二维码
 kHTMLBaseURLString H5
 kResourceURLString 资源服务器
 kSecturyKey 密钥
 kBaseURLString API服务器
### 1.2 Appdelegate.m
```
///<---------------------------------------- 配置开始 ----------------------------------------
    /* 配置TIOChat */
    
    TIOConfig *tioConfig = [TIOConfig.alloc init];
    
    // 开启日志 发布的时候关闭
    #ifdef DEBUG
    [TIOChat setLogEnable:YES];
    #else
    // 线上环境
    [TIOChat setLogEnable:NO];
    #endif
    
    // 服务器配置
    tioConfig.httpsAddress = kBaseURLString;
    tioConfig.resourceAddress = kResourceURLString;
    tioConfig.secrectKey = kSecturyKey;
    
    TIOChat.shareSDK.config = tioConfig;
    TIOSDKOption *option = [TIOSDKOption.alloc init];
    //    option.isOpenSSL = YES; 默认关闭，请手动开启
    [TIOChat.shareSDK registerWithOption:option];

        [TIOChat.shareSDK.loginManager addDelegate:self];
    // 配置基础网络信息
    [TIOChat requestNetConfig:^(NSDictionary *result) {
        // result为空，说明配置失败
        if (result) {
            // 开始检查版本:自己处理更新类型及提示
            [CBVersionManager.shareInstance starManager];
        }
    }];
    
    
    ///<---------------------------------------- 配置结束 ----------------------------------------
```
当您的业务需求需要启动SDK的时候，使用`lunch`方法启动SDK，前提是：SDK必须得登录
```
    // 启动SDK
    [TIOChat.shareSDK lunch];
```
## 2、SSL
默认SSL关闭，如需开启，将 
`[TIOChat.shareSDK registerWithOption:option];` 中 option 的 `isOpenSSL` 设为 `YES`。

```
TIOChat.shareSDK.config = tioConfig;
TIOSDKOption *option = [TIOSDKOption.alloc init];
//    option.isOpenSSL = YES; 默认关闭，请手动开启
[TIOChat.shareSDK registerWithOption:option];
```

# SDK 功能分布
## 一、登录模块 TIOLoginManager
* 登录
* 退出
* 注册
* 更改用户信息：头像、昵称、性别、电话、密码等
* 找回密码
* 权限设置：好友加自己的权限、通知权限
* 收到登录结果（通知）
* 收到退出登录（通知）
* 收到被挤掉登录（通知）

## 二、好友模块 TIOFriendManager
* 添加好友
* 处理好有申请
* 删除好友
* 获取好友列表
* 添加进黑名单
* 移除黑名单
* 获取好友信息
* 判断是不是自己的好友
* 收到删除好友的（通知）

## 三、聊天模块 TIOChatManager
* 发送消息：（文本、图片、表情、名片、语音等）
* 撤回消息
* 删除消息
* 转发消息
* 新消息（通知）
* 收到文件上传（通知）
* 收到消息删除（通知）
* 收到消息撤回（通知）

## 四、群模块 TIOTeamManager
* 创建群
* 添加用户进群
* 将用户踢出群
* 获取群信息
* 搜索群成员
* 搜索自己的群聊
* 获取所有的群聊列表
* 分享群名片
* 更改群内昵称
* 修改群名（群主）
* 修改群公告（群主）
* 修改群简介（群主）
* 解散群（群主）
* 转让群（群主）
* 修改成员邀请权限（群主）
* 修改群审核开关（群主）
* 退群
* 收到已解散群（通知）
* 收到已转让群（通知）
* 收到已退群（通知）
* 收到群信息变更（通知）
* 收到被踢出群（通知）
* 收到重新加入群聊（通知）
* 收到群成员数量变更（通知）

## 五、会话模块 TIOConversationManager
* 进入会话
* 离开会话
* 更新本地会话列表
* 获取历史消息
* 获取会话ID
* 获取会话信息
* 置顶会话
* 取消置顶会话
* 删除会话
* 举报会话
* 清空会话内聊天记录
* 新增会话通知
* 更新会话通知
* 收到即将开始同步远端数据到本地数据库（通知）
* 收到已经从远端服务器同步本地数据（通知）
* 收到已清除某个会话内的所有聊天记录（通知）
* 收到已经将某个会话置顶（通知）
* 收到已经将某个会话取消置顶（通知）
* 收到好友已读自己的消息（通知）
* 收到所有会话的总未读消息数改变（通知）
* 收到某个会话的未读消息发生变更（通知）

## 六、语音模块 TIOAudioManager
不是音视频实时聊天，语音发送功能

* 是否正在录音
* 是否正在播放
* 开始录音
* 暂停录音
* 结束录音
* 播放
* 停止播放
* 收到开始录音（通知）
* 收到完成录音（通知）
* 收到录音时间进度（通知）

## 七、音视频聊天模块 TIOVideoChatManager
* 发起呼叫
* 接听处理：接听｜拒接
* 挂断
* 取消呼叫
* 切换摄像头
* 收到呼叫（通知）
* 收到接听人的接听或拒绝响应（通知）
* 收到被挂断（通知）
* 收到本地视频预览已准备好（通知）
* 收到信令接通（通知）
* 收到通话已经建立连接，开始通话（通知）
* 收到通话被断开（通知）
* 远端视频尺寸变化（通知）


