//
//  WalletInputField.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WalletInputField : UITextField <UIKeyInput, UITextFieldDelegate>

/// 最大输入的字符数
@property (assign,  nonatomic) NSInteger maxNumberOfChar;

/// 小数位数，默认精确两位，一般足够
@property (assign,  nonatomic) NSInteger numberOfDecimal;

/// 监听每次点击删除事件
@property (copy,    nonatomic) void(^w_deleteBlock)(NSString *text);

@end

NS_ASSUME_NONNULL_END
