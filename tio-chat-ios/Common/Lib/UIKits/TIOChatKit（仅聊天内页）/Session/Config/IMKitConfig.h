//
//  IMKitConfig.h
//  CawBar
//
//  Created by admin on 2019/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IMKitMessageSetting;
@class IMKitMessageSettings;
@class TIOMessage;

/// 全局设置
@interface IMKitConfig : NSObject

@property (nonatomic, strong) IMKitMessageSettings *leftMessageSettings;
@property (nonatomic, strong) IMKitMessageSettings *rightMessageSettings;

@property (nonatomic, strong) UIColor *nickColor;
@property (nonatomic, strong) UIFont *nickFont;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, copy) NSString *messageCellClass;

/// “已读” 颜色
@property (nonatomic, strong) UIColor *msgReadColor;
/// “未读” 颜色
@property (nonatomic, strong) UIColor *msgUnReadColor;
/// 已读未读字体大小
@property (nonatomic, strong) UIFont *msgReadFont;

/// “时间”颜色
@property (nonatomic, strong) UIColor *timeColor;
/// “时间”字体
@property (nonatomic, strong) UIFont *timeFont;

/// 每页最大消息数量 超过删除之前的消息
/// 默认1000条
@property (nonatomic, assign) NSInteger limitMessageCount;
/// 每间隔多久显示一次消息的日期时间
@property (nonatomic, assign) NSTimeInterval showMessageTimeInterval;

/// 获取消息的配置
- (IMKitMessageSetting *)setting:(TIOMessage *)message;

@end

NS_ASSUME_NONNULL_END
