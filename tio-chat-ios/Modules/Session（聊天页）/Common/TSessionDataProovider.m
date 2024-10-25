//
//  P2PDataProovider.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSessionDataProovider.h"
#import "ImportSDK.h"
#import "TMessageMaker.h"

@implementation TSessionDataProovider

- (void)pullDown:(TIOMessage *)firstMessage session:(nonnull TIOSession *)session handler:(nonnull IMKitDataProvideHandler)handler
{
    // TODO: 下拉刷新
    [TIOChat.shareSDK.conversationManager fetchMessagesHistory:session startMsgId:firstMessage.messageId endMsgId:nil completion:^(NSError * _Nullable error, NSArray<TIOMessage *> * _Nullable messages) {
        for (TIOMessage *message in messages) {
            if (message.messageType == TIOMessageTypeVideoChat) {
                message.text = [TMessageMaker videoChatMessageFor:message];
            }
        }
        handler(error, messages);
    }];
}

- (void)loadNew:(TIOMessage *)endMessage session:(TIOSession *)session handler:(IMKitDataProvideHandler)handler
{
    [TIOChat.shareSDK.conversationManager fetchMessagesHistory:session startMsgId:nil endMsgId:endMessage.messageId completion:handler];
}

@end
