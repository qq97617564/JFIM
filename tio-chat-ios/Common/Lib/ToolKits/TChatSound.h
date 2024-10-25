//
//  TVideoChatTool.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TChatSound : NSObject

+ (instancetype)shareInstance;

/// 播放呼叫声音
- (void)startCalling;
/// 结束呼叫声音
- (void)finishCalling;

/// 播放挂断声音
- (void)playHangupSound;

- (void)playPrivateMessageSound;
- (void)playTeamMessageSound;

@end

NS_ASSUME_NONNULL_END
