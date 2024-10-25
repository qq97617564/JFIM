//
//  TVideoChatTool.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TChatSound.h"
#import <AVFoundation/AVFoundation.h>
@interface TChatSound () <AVAudioPlayerDelegate>
{
    AVAudioSession *_audioSession;
    AVAudioPlayer *_player;
}
@end

@implementation TChatSound

- (instancetype)init
{
    if (self = [super init]) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        /*
         Adding the above line of code made it so my audio would start even if the app was in the background.
         */
        
        _audioSession = [AVAudioSession sharedInstance];
        [_audioSession setCategory:AVAudioSessionCategorySoloAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [_audioSession setActive:YES error:nil];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static TChatSound *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startCalling
{
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"RTC.bundle/tio_callingVideo_sound" ofType:@"mp3"]];
    if (!url) {
        return;
    }
    
    [self configAudiosession];
    
    NSError *error = nil;
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"播放呼叫提示声音失败->%@",error);
        return;
    }
    
    _player.numberOfLoops = 1;
    [_player prepareToPlay];
    [_player play];
}

- (void)finishCalling
{
    if (_player && _player.isPlaying) {
        [_player stop];
    }
}

- (void)playHangupSound
{
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"RTC.bundle/tio_finishVideo_sound" ofType:@"mp3"]];
    if (!url) {
        return;
    }
    
    [self configAudiosession];
    
    NSError *error = nil;
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"播放挂断声音失败->%@",error);
        return;
    }
    _player.delegate = self;
    [_player prepareToPlay];
    [_player play];
}

- (void)playPrivateMessageSound
{
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"RTC.bundle/tio_private_sound" ofType:@"mp3"]];
    if (!url) {
        return;
    }
    [self configAudiosession];
    
    NSError *error = nil;
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"播放私聊提示音失败->%@",error);
        return;
    }
    _player.volume = 1;
    [_player prepareToPlay];
    [_player play];
}

- (void)playTeamMessageSound
{
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"RTC.bundle/tio_team_sound" ofType:@"mp3"]];
    if (!url) {
        return;
    }
    
    [self configAudiosession];
    
    NSError *error = nil;
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"播放群聊提示音失败->%@",error);
        return;
    }
    
    [_player prepareToPlay];
    [_player play];
}

- (void)configAudiosession
{
    [_audioSession setCategory:AVAudioSessionCategorySoloAmbient withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [_audioSession setActive:YES error:nil];
}

#pragma mark -

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
{
    [_player stop];
}

@end
