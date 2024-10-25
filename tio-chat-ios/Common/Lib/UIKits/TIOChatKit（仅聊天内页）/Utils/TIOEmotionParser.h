//
//  TIOEmotionParser.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIOEmotionResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOEmotionParser : NSObject

/// 返回值模式
/// @param text 原文本
- (NSArray<TIOEmotionResult *> *)resultsWithText:(NSString *)text;

/// 迭代模式
/// @param text 原文本
/// @param usingBlock 迭代器
- (void)enumerateMatchesInText:(NSString *)text
                    usingBlock:(void(^)(TIOEmotionResult *result, BOOL * _Nonnull stop))usingBlock;

@end

NS_ASSUME_NONNULL_END
