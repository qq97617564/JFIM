//
//  TIOMessage+RichTip.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/9/8.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOMessage (RichTip)

/// 文本
@property (copy,    nonatomic) NSString *t_linkString;
/// 字体
@property (strong,  nonatomic) UIFont *t_font;
/// 颜色
@property (strong,  nonatomic) UIColor *t_color;
/// 绑定的方法名
@property (copy,    nonatomic) NSString *t_selctorName;

/// 测试
/// 1000——红包
@property (assign,  nonatomic) NSInteger t_tipCode;

@end

NS_ASSUME_NONNULL_END
