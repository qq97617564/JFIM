//
//  TP2PSessionConfig.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSessionConfig.h"
#import "TSessionDataProovider.h"

@interface TSessionConfig ()
@property (nonatomic, strong) TIOSession *session;
@property (nonatomic, strong) id<IMKitSessionDataProvider> provider;
@end

@implementation TSessionConfig

- (instancetype)initWithSession:(TIOSession *)session
{
    self = [super init];
    
    if (self) {
        _session = session;
        _provider = [TSessionDataProovider.alloc init];
    }
    
    return self;
}

- (BOOL)shouldShowTime
{
    return NO;
}

- (id<IMKitSessionDataProvider>)messageDataProvider
{
    return self.provider;
}

/// 聊天会话内，未滑动到最底部，有新消息来时，开启新消息提醒
- (BOOL)canTipBottomNewMessages
{
    return YES;
}

- (NSArray<IMKitInputMoreItem *> *)moreItems
{
    NSArray *array = nil;
    
    IMKitInputMoreItem *ablumItem = [IMKitInputMoreItem itemWithTitle:@"相册" normalImage:[UIImage imageNamed:@"Album"] selectedImage:[UIImage imageNamed:@"Album"] selector:@"onTapPicture"];
    
    IMKitInputMoreItem *cameraItem = [IMKitInputMoreItem itemWithTitle:@"拍摄" normalImage:[UIImage imageNamed:@"shoot"] selectedImage:[UIImage imageNamed:@"shoot"] selector:@"onTapCamera"];
    
    IMKitInputMoreItem *videoItem = [IMKitInputMoreItem itemWithTitle:@"视频通话" normalImage:[UIImage imageNamed:@"faceTime"] selectedImage:[UIImage imageNamed:@"faceTime"] selector:@"onTapVideoChat"];
//
    IMKitInputMoreItem *audioItem = [IMKitInputMoreItem itemWithTitle:@"语音通话" normalImage:[UIImage imageNamed:@"call"] selectedImage:[UIImage imageNamed:@"call"] selector:@"onTapAudioChat"];

    IMKitInputMoreItem *fileItem = [IMKitInputMoreItem itemWithTitle:@"文件" normalImage:[UIImage imageNamed:@"file"] selectedImage:[UIImage imageNamed:@"file"] selector:@"onTapFile"];

    IMKitInputMoreItem *cardItem = [IMKitInputMoreItem itemWithTitle:@"名片" normalImage:[UIImage imageNamed:@"cardUser"] selectedImage:[UIImage imageNamed:@"cardUser"] selector:@"onTapCard"];

    IMKitInputMoreItem *groupCardItem = [IMKitInputMoreItem itemWithTitle:@"群名片" normalImage:[UIImage imageNamed:@"cardGroup"] selectedImage:[UIImage imageNamed:@"cardGroup"] selector:@"onTapGroupCard"];
    
    IMKitInputMoreItem *redItem = [IMKitInputMoreItem itemWithTitle:@"红包" normalImage:[UIImage imageNamed:@"card_hb"] selectedImage:[UIImage imageNamed:@"card_hb"] selector:@"onTapRed"];
    
    
    if (_session.sessionType == TIOSessionTypeP2P) {
        array = @[ablumItem, cameraItem, videoItem, audioItem, cardItem, groupCardItem, fileItem, redItem];
    }
    else
    {
        array = @[ablumItem, cameraItem, cardItem, groupCardItem, fileItem, redItem];
    }
    
    
    return array;
}

- (CGSize)moreItemSize
{
    return CGSizeMake(60, 83);
}

- (UIEdgeInsets)moreContainerContentInsets
{
    return UIEdgeInsetsMake(22, 30, 10, 30);
}

- (NSInteger)maxInputCharCount
{
    return 1500; // 限制最大输入字符数
}

@end
