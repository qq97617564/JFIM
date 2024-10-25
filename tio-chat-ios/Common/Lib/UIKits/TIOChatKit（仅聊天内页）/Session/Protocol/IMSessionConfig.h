//
//  IMSessionConfig.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMKitSessionDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// 单个会话的配置
/// 和IMKitConfig区别：
/// IMKitConfig面向全局属性配置，层级更高；
/// IMSessionConfig 可以针对每个聊天页做差异化处理，例如：单独配置数加载更多的数据源、控制面板控件显隐等
@protocol IMSessionConfig <NSObject>

@optional

/// 是否显示分割时间
@property (nonatomic, assign) BOOL shouldShowTime;

- (id<IMKitSessionDataProvider>)messageDataProvider;

/// 是否提示新的未读消息
- (BOOL)canTipBottomNewMessages;

@end

NS_ASSUME_NONNULL_END
