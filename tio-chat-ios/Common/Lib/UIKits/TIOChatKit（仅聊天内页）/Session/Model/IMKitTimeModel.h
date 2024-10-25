//
//  IMKitTimeModel.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMKitTimeModel : NSObject

/// 时间戳
@property (nonatomic, assign) NSTimeInterval messageTime;

/// cell高度
@property (nonatomic, assign) CGFloat height;

@end

NS_ASSUME_NONNULL_END
