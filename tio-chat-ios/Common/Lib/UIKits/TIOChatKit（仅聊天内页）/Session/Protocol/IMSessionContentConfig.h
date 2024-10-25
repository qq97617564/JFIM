//
//  IMSessionContentConfig.h
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOMessage;

@protocol IMSessionContentConfig <NSObject>
@optional
/// 计算气泡内容尺寸
/// @param cellWidth cell的宽
/// @param message 消息
- (CGSize)contentSize:(CGFloat)cellWidth message:(TIOMessage *)message;

/// 计算气泡内的复杂布局各个尺寸
- (NSDictionary *)subContentSize:(CGFloat)cellWidth message:(TIOMessage *)message;

/// content view 的名字（一般是类名）
/// @param message 消息
- (NSString *)cellContent:(TIOMessage *)message;

/// cell内容距离气泡的内间距
/// @param message 消息
- (UIEdgeInsets)contentViewInsets:(TIOMessage *)message;

@end

NS_ASSUME_NONNULL_END
