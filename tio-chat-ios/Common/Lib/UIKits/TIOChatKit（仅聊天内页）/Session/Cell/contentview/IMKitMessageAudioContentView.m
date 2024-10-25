//
//  IMKitMessageAudioContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageAudioContentView.h"
#import "TIOKitDependency.h"
#import "TIOChatKit.h"
#import "ImportSDK.h"
#import "IMKitAudioCenter.h"
#import <UIImageView+WebCache.h>

@interface IMKitMessageAudioContentView ()<TIOAudioDelegate>
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *icon;
@end

@implementation IMKitMessageAudioContentView

- (void)dealloc
{
    [TIOChat.shareSDK.audioManager removeDelegate:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        SDAnimatedImageView *imageView = [SDAnimatedImageView.alloc initWithFrame:CGRectMake(0, 0, 24, 24)];
//        [self addSubview:imageView];
//        self.imageView = imageView;
        self.timeLabel = [UILabel.alloc init];
        self.timeLabel.textColor = [UIColor colorWithHex:0x909090];
        self.timeLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.timeLabel];
        
        self.icon = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 24, 24)];
        [self addSubview:self.icon];
        
        [TIOChat.shareSDK.audioManager addDelegate:self];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.timeLabel sizeToFit];
    if (self.messageModel.message.isOutgoingMsg) {
        self.timeLabel.left = 8;
        self.timeLabel.centerY = self.middleY;
        self.icon.right = self.width - 7;
        self.icon.centerY = self.middleY;
    } else {
        self.timeLabel.right = self.width - 8;
        self.timeLabel.centerY = self.middleY;
        self.icon.left = 7;
        self.icon.centerY = self.middleY;
    }
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    
//    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:messageModel.message];
    TIOMessage * message = messageModel.message;
    
    NSTimeInterval recordtimes = message.attachmentObjects.firstObject.seconds;
    NSInteger minutes = (NSInteger)recordtimes / 60;
    NSInteger seconds = (NSInteger)recordtimes % 60;
    if (minutes > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%zd'%zd''", minutes, seconds];
    } else {
        self.timeLabel.text = [NSString stringWithFormat:@"%zd'", seconds];
    }
    
    
    if (message.isOutgoingMsg) {
        self.icon.image = [UIImage imageNamed:@"ownvoice_stop"];
    } else {
        self.icon.image = [UIImage imageNamed:@"voice_stop"];
    }
}

- (void)onTouchUpInside:(id)sender
{
    if ([self isPlaying])
    {
        [self stopPlaying];
    }
    
    [super onTouchUpInside:sender];
}

- (void)startPlaying
{
    if (self.messageModel.message.isOutgoingMsg) {
        NSArray *animateIcons = @[[UIImage imageNamed:@"sender_voice_playing_01"],
                                  [UIImage imageNamed:@"sender_voice_playing_02"],
                                  [UIImage imageNamed:@"sender_voice_playing_03"]];
        self.icon.animationImages = animateIcons;
    } else {
        NSArray *animateIcons = @[[UIImage imageNamed:@"receiver_voice_playing_01"],
                                  [UIImage imageNamed:@"receiver_voice_playing_02"],
                                  [UIImage imageNamed:@"receiver_voice_playing_03"]];
        self.icon.animationImages = animateIcons;
    }
    self.icon.animationDuration = 1;
    self.icon.animationRepeatCount = 0;
    [self.icon startAnimating];
}

- (void)stopPlaying
{
    [self.icon stopAnimating];
}

- (BOOL)isPlaying
{
    return [IMKitAudioCenter.sharedCenter isPlayingMessage:self.messageModel.message];
}

#pragma mark - TIOAudioDelegate

- (void)playAudio:(NSString *)audioUrl didBeganWithError:(NSError *)error
{
    [self stopPlaying];
    if (error) return;
    
    if ([self isPlaying]) {
        [self startPlaying];
    }
}

- (void)playAudio:(NSString *)audioUrl didFinishedWithError:(NSError *)error
{
    [self stopPlaying];
}

@end
