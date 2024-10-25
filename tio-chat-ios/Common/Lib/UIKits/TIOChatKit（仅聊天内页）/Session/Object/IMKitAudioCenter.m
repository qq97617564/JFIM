//
//  IMKitAudioCenter.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitAudioCenter.h"
#import "ImportSDK.h"

@interface IMKitAudioCenter ()<TIOAudioDelegate>
@property (strong,  nonatomic) TIOMessage *currentMessage;
@end

@implementation IMKitAudioCenter

+ (instancetype)sharedCenter
{
    static IMKitAudioCenter *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (BOOL)isPlayingMessage:(id)message
{
    if (!self.currentMessage) {
        return NO;
    }
    
    TIOMessage *msg = (TIOMessage *)message;
    
    return [msg.messageId isEqualToString:self.currentMessage.messageId];
}

- (void)play:(id)message
{
    TIOMessage *msg = (TIOMessage *)message;
    self.currentMessage = msg;
    
    [TIOChat.shareSDK.audioManager playAudio:msg.attachmentObjects.firstObject.url];
}

#pragma mark - TIOAudioDelegate

- (void)playAudio:(NSString *)audioUrl didFinishedWithError:(NSError *)error
{
    self.currentMessage = nil;
}

@end


