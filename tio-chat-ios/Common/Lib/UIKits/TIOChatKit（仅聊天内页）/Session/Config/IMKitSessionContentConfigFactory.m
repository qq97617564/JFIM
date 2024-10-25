//
//  IMSessionContentConfigFactory.m
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import "IMKitSessionContentConfigFactory.h"
#import "IMKitTextMessageContentConfig.h"
#import "IMKitImageContentConfig.h"
#import "IMKitAudioContentConfig.h"
#import "IMKitVideoContentConfig.h"
#import "IMKitFileContentConfig.h"
#import "IMKitLocationContentConfig.h"
#import "IMKitNotificationContentConfig.h"
#import "IMKitTipContentConfig.h"
#import "IMKitCardContentConfig.h"
#import "IMKitVideoChatContentConfig.h"
#import "IMKitUndefineContentConfig.h"
#import "IMKitRedContentConfig.h"
#import "IMKitSuperLinkContentConfig.h"

#import "ImportSDK.h"

@implementation IMKitSessionContentConfigFactory
{
    NSDictionary *_dict;
    IMKitUndefineContentConfig *_undefineConfig;
}

+ (instancetype)sharedFacotry
{
    static IMKitSessionContentConfigFactory *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        /**
         * _dict 内包含的为支持的类型
         * 通过删减可以控制所支持的消息类型
         */
        _dict =@{
            @(TIOMessageTypeText)         :       [IMKitTextMessageContentConfig new],
            @(TIOMessageTypeImage)        :       [IMKitImageContentConfig new],
            @(TIOMessageTypeAudio)        :       [IMKitAudioContentConfig new],
            @(TIOMessageTypeVideo)        :       [IMKitVideoContentConfig new],
            @(TIOMessageTypeFile)         :       [IMKitFileContentConfig new],
//            @(TIOMessageTypeLocation)     :       [IMKitLocationContentConfig new],
//            @(TIOMessageTypeNotification) :       [IMKitNotificationContentConfig new],
            @(TIOMessageTypeTip)          :       [IMKitTipContentConfig new],
            @(TIOMessageTypeRichTip)          :       [IMKitTipContentConfig new],
            @(TIOMessageTypeCard)         :       [IMKitCardContentConfig new],
            @(TIOMessageTypeVideoChat)    :       [IMKitVideoChatContentConfig new],
            @(TIOMessageTypeAudioChat)    :       [IMKitVideoChatContentConfig new],
            @(TIOMessageTypeRed)          :       [IMKitRedContentConfig new],
            @(TIOMessageTypeSuperLink)          :       [IMKitSuperLinkContentConfig new],
        };
        _undefineConfig = [IMKitUndefineContentConfig.alloc init];
    }
    
    return self;
}

- (id<IMSessionContentConfig>)configBy:(TIOMessage *)message
{
    TIOMessageType messageType = message.messageType;
    id<IMSessionContentConfig>config = [_dict objectForKey:@(messageType)];
    if (config == nil) {
        // 不支持的消息类型
        config = _undefineConfig;
    }
    return config;
}

@end
