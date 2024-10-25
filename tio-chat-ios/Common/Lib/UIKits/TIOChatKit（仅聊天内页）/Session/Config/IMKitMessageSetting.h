//
//  IMMessageSetting.h
//  CawBar
//
//  Created by admin on 2019/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 每种气泡消息设置
@interface IMKitMessageSetting : NSObject

/// 设置消息 Contentview 内间距
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/// 设置消息 Contentview 的文字颜色
@property (nonatomic, strong) UIColor *textColor;

/// 设置消息 Contentview 的文字字体
@property (nonatomic, strong) UIFont *font;

/// 设置消息是否显示头像
@property (nonatomic, assign) BOOL showAvatar;

@property (nonatomic, assign) BOOL showTime;

/// 设置是否显示未读消息
@property (nonatomic, assign) BOOL showUnread;

/// 设置消息按压模式下的背景图
@property (nonatomic, strong) UIImage *highLightBackgroundImage;

/// 气泡图片四边的拉伸范围
@property (nonatomic, assign) UIEdgeInsets bubbleImageStretch;

/// 气泡的最大宽度
/// Note：如果不使用Kit内置的各种消息的配置，重写任意消息配置，此设置都无效
@property (nonatomic, assign) CGFloat bubbleMaxWidth;

/// 扩展字段，目前主要用于扩展气泡内复杂布局的size
@property (nonatomic, strong) NSDictionary *extDictionary;

/// 设置自己或别人消息的气泡
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *backgroundImageDic;
/// 读取气泡背景图 设置气泡通过backgroundImageDic进行设置
@property (nonatomic, strong, readonly) UIImage *normalBackgroundImage;

- (instancetype)init:(BOOL)isRight;

@end

/// 多种气泡的消息的集合
@interface IMKitMessageSettings : NSObject

/// 文本类型消息设置
@property (nonatomic, strong) IMKitMessageSetting *textSetting;

/// 音频类型消息设置
@property (nonatomic, strong) IMKitMessageSetting *audioSetting;

/// 视频类型消息设置
@property (nonatomic, strong) IMKitMessageSetting *videoSetting;

/// 文件类型消息设置
@property (nonatomic, strong) IMKitMessageSetting *fileSetting;

/// 图片类型消息设置
@property (nonatomic, strong) IMKitMessageSetting *imageSetting;

/// 名片
@property (nonatomic, strong) IMKitMessageSetting *cardSetting;

/// 地理位置类型消息设置
@property (nonatomic, strong) IMKitMessageSetting *locationSetting;

/// 提示类型消息设置
@property (nonatomic, strong) IMKitMessageSetting *tipSetting;

/// 视频聊天
@property (nonatomic, strong) IMKitMessageSetting *videochatSetting;

/// 红包
@property (nonatomic, strong) IMKitMessageSetting *redSetting;

/// 超链接消息模版
@property (nonatomic, strong) IMKitMessageSetting *superlinkSetting;

/// 无法识别类型消息设置
@property (nonatomic, strong) IMKitMessageSetting *unsupportSetting;

- (instancetype)init:(BOOL)isRight;

@end

NS_ASSUME_NONNULL_END
