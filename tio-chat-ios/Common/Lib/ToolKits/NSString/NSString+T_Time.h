//
//  NSString+T_Time.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (T_Time)

/// 月-日
- (NSString *)getMMdd;
/// 时：分
- (NSString *)getHHmm;

+ (NSString *)getTimeWithFormat:(NSString *)format timeInterval:(NSTimeInterval)timeInterval;

+ (NSString *)calculateSpendTimeFromDate:(NSString *)date1 toDate:(NSString *)date2;

+ (NSString *)transferToLengthFromSeconds:(NSTimeInterval)timeInterval;

- (NSString *)timeOfsessionList;

@end

NS_ASSUME_NONNULL_END
