//
//  UIControl+T_LimitClickCount.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/9/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (T_LimitClickCount)

// 间隔多少秒才能响应事件
@property(nonatomic, assign) NSTimeInterval  acceptEventInterval;
//是否能执行方法
@property(nonatomic, assign) BOOL T_ignoreEvent;

@end

NS_ASSUME_NONNULL_END
