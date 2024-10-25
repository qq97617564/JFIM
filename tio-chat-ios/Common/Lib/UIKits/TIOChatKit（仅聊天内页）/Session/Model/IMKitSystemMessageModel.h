//
//  IMKitSystemMessageModel.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMKitSystemMessageModel : NSObject

/// msg为nil时，默认显示文本@"未知的系统消息"
@property (copy,    nonatomic) NSString *msg;
@property (assign,  nonatomic) NSTimeInterval timestamp;

/// msg尺寸
@property (assign,  nonatomic) CGSize contentSize;

@property (assign,  nonatomic) CGFloat height;

@end

NS_ASSUME_NONNULL_END
