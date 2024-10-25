//
//  IMKitAudioCenter.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMKitAudioCenter : NSObject

+ (instancetype)sharedCenter;

- (BOOL)isPlayingMessage:(id)message;

- (void)play:(id)message;

@end

NS_ASSUME_NONNULL_END
