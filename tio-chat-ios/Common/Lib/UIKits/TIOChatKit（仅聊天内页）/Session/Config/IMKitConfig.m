//
//  IMKitConfig.m
//  CawBar
//
//  Created by admin on 2019/11/14.
//

#import "IMKitConfig.h"
#import "IMKitMessageSetting.h"
#import "ImportSDK.h"

@implementation IMKitConfig

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _leftMessageSettings = [IMKitMessageSettings.alloc init:NO];
        _rightMessageSettings = [IMKitMessageSettings.alloc init:YES];
        _nickFont = [UIFont systemFontOfSize:12];
        _nickColor = [UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1.0];
        _limitMessageCount = 1000;
        _cornerRadius = 4;
        _messageCellClass = @"IMKitMesssageCell";
        _msgReadColor = [UIColor colorWithRed:205/255.0 green:208/255.0 blue:211/255.0 alpha:1.0];
        _msgUnReadColor = [UIColor colorWithRed:76/255.0 green:148/255.0 blue:255/255.0 alpha:1.0];
        _msgReadFont = [UIFont systemFontOfSize:10];
        _timeColor = [UIColor colorWithRed:205/255.0 green:208/255.0 blue:211/255.0 alpha:1.0];
        _timeFont = [UIFont systemFontOfSize:12];
        _showMessageTimeInterval = 1 * 3 * 60 * 1000; // 5分钟显示一次时间消息时间 因为时间戳精确到毫秒 所以*1000
    }
    
    return self;
}

- (IMKitMessageSetting *)setting:(TIOMessage *)message
{
    IMKitMessageSettings *settings = message.isOutgoingMsg? self.rightMessageSettings : self.leftMessageSettings;
    switch (message.messageType) {
        case TIOMessageTypeText:
            return settings.textSetting;
        case TIOMessageTypeImage:
            return settings.imageSetting;
        case TIOMessageTypeLocation:
            return settings.unsupportSetting;
        case TIOMessageTypeAudio:
            return settings.audioSetting;
        case TIOMessageTypeVideo:
            return settings.videoSetting;
        case TIOMessageTypeFile:
            return settings.fileSetting;
        case TIOMessageTypeTip:
        case TIOMessageTypeRichTip:
            return settings.tipSetting;
        case TIOMessageTypeNotification:
        {
            break;
        }
        case TIOMessageTypeCard:
            return settings.cardSetting;
        case TIOMessageTypeVideoChat:
        case TIOMessageTypeAudioChat:
            return settings.videochatSetting;
        case TIOMessageTypeRed:
            return settings.redSetting;
        case TIOMessageTypeSuperLink:
            return settings.superlinkSetting;
        default:
            break;
    }
    return settings.unsupportSetting;
}

@end
