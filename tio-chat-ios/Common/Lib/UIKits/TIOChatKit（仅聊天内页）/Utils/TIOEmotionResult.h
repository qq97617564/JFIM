//
//  TIOEmotion.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TIOEmotionType) {
    TIOEmotionTypeText,
    TIOEmotionTypeEmotion,
};

@interface TIOEmotionResult : NSObject

@property (copy,    nonatomic) NSString *string;
@property (assign,  nonatomic) NSRange range;
@property (assign,  nonatomic) TIOEmotionType emotionType;

@end

NS_ASSUME_NONNULL_END
