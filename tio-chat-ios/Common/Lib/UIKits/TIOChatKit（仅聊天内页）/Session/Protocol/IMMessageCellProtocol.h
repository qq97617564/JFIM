//
//  IMMessageCellProtocol.h
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IMKitEvent;
@class TIOMessage;

@protocol IMMessageCellProtocol <NSObject>

#pragma mark - 点击事件

- (BOOL)onTapCell:(IMKitEvent *)event;

- (BOOL)onLongPressCell:(TIOMessage *)message
                 inView:(UIView *)view;

- (BOOL)onTapAvatar:(TIOMessage *)message;

- (BOOL)onLongPressAvatar:(TIOMessage *)message;

- (void)onRetryMessage:(TIOMessage *)message;

@end

NS_ASSUME_NONNULL_END
