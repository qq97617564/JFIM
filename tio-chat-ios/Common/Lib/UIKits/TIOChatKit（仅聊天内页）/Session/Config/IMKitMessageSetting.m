//
//  IMMessageSetting.m
//  CawBar
//
//  Created by admin on 2019/11/14.
//

#import "IMKitMessageSetting.h"
#import "TIOKitTool.h"
#import "UIImage+TColor.h"

@implementation IMKitMessageSetting
{
    BOOL _isRight;
}

- (instancetype)init:(BOOL)isRight
{
    self = [super init];
    
    if (self) {
        _isRight = isRight;
        
        _bubbleMaxWidth = UIScreen.mainScreen.bounds.size.width - 120;
        _backgroundImageDic = [NSMutableDictionary dictionaryWithCapacity:2];
        
        // 设置左右自己和非自己的消息的气泡图
        _backgroundImageDic[[NSNumber numberWithBool:YES]] = [UIImage imageNamed:@"right_bubble"];
        _backgroundImageDic[[NSNumber numberWithBool:NO]] = [UIImage imageNamed:@"left_bubble"];
        
        _textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        if (isRight) {
            _bubbleImageStretch = UIEdgeInsetsMake(4, 4, 8, 8);
        } else {
            _bubbleImageStretch = UIEdgeInsetsMake(4, 8, 4, 4);
        }
    }
    
    return self;
}

- (UIImage *)normalBackgroundImage
{
    return self.backgroundImageDic[@(_isRight)];
}

@end

@implementation IMKitMessageSettings
{
    BOOL    _isRight;
}

- (instancetype)init:(BOOL)isRight
{
    self = [super init];
    if (self) {
        _isRight = isRight;
        [self applyDefaultSettings];
    }
    return self;
}

- (void)applyDefaultSettings
{
    [self applyDefaultTextSettings];
    [self applyDefaultAudioSettings];
    [self applyDefaultVideoSettings];
    [self applyDefaultFileSettings];
    [self applyDefaultImageSettings];
    [self applyDefaultCardSettings];
    [self applyDefaultLocationSettings];
    [self applyDefaultTipSettings];
    [self applyDefaultUnsupportSettings];
    [self applyDefaultVideochatSettings];
    [self applyDefaultRedSettings];
    [self applyDefaultSuperSettings];
}

/// 文本消息
- (void)applyDefaultTextSettings
{
    _textSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _textSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{10,11,9,17}") : UIEdgeInsetsFromString(@"{10,17,9,11}");
    _textSetting.font      =  [UIFont systemFontOfSize:16];
    _textSetting.backgroundImageDic[@(YES)] = [UIImage imageNamed:@"right_bubble_text"];
    _textSetting.showAvatar = YES;
    _textSetting.showTime = YES;
}

/// 语音消息
- (void)applyDefaultAudioSettings
{
    _audioSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _audioSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{0,0,0,0}") : UIEdgeInsetsFromString(@"{0,0,0,0}");
    _audioSetting.font      = [UIFont systemFontOfSize:16];
    _audioSetting.backgroundImageDic[@(YES)] = [UIImage imageNamed:@"right_bubble_text"];
    _audioSetting.showAvatar = YES;
    _audioSetting.showTime = YES;
}

/// 视频消息
- (void)applyDefaultVideoSettings
{
    _videoSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _videoSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{0,0,0,0}") : UIEdgeInsetsFromString(@"{0,0,0,0}");
    _videoSetting.backgroundImageDic[@(YES)] = [UIImage imageNamed:@"right_bubble_text"];
    _videoSetting.showAvatar = YES;
    _videoSetting.showTime = YES;
}

/// 文件消息
- (void)applyDefaultFileSettings
{
    _fileSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _fileSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{8,10,8,14}") : UIEdgeInsetsFromString(@"{8,14,8,10}");
    _fileSetting.font      = [UIFont systemFontOfSize:16];
    _fileSetting.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _fileSetting.showAvatar = YES;
    _fileSetting.showTime = YES;
}

/// 图片消息
- (void)applyDefaultImageSettings
{
    _imageSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _imageSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{0,0,0,0}") : UIEdgeInsetsFromString(@"{0,0,0,0}");
    _imageSetting.backgroundImageDic[@(YES)] = [UIImage imageWithColor:UIColor.clearColor];
    _imageSetting.backgroundImageDic[@(NO)] = [UIImage imageWithColor:UIColor.clearColor];
    _imageSetting.showAvatar = YES;
    _imageSetting.showTime = YES;
}

/// 名片
- (void)applyDefaultCardSettings
{
    _cardSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _cardSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{12,16,12,60}") : UIEdgeInsetsFromString(@"{12,16,12,60}");
    _cardSetting.font      = [UIFont systemFontOfSize:14];
    _cardSetting.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _cardSetting.backgroundImageDic[@(YES)] = [UIImage imageWithColor:UIColor.whiteColor];
    _cardSetting.backgroundImageDic[@(NO)] = [UIImage imageWithColor:UIColor.whiteColor];
    _cardSetting.showAvatar = YES;
    _cardSetting.showTime = YES;
}

/// 定位消息
- (void)applyDefaultLocationSettings
{
    _locationSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _locationSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{0,0,0,0}") : UIEdgeInsetsFromString(@"{0,0,0,0}");
    _locationSetting.font      = [UIFont systemFontOfSize:12];
    _locationSetting.showAvatar = YES;
    _locationSetting.showTime = YES;
}

/// 提醒消息
- (void)applyDefaultTipSettings
{
    _tipSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _tipSetting.contentInsets = UIEdgeInsetsZero;
    _tipSetting.font  = [UIFont systemFontOfSize:14.f];
    _tipSetting.textColor = [UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1.0];
    _tipSetting.showAvatar = NO;
    _tipSetting.showTime = NO;
    _tipSetting.backgroundImageDic[@(YES)] = [UIImage new];
    _tipSetting.backgroundImageDic[@(NO)] = [UIImage new];
}

- (void)applyDefaultVideochatSettings
{
    _videochatSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _videochatSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{11,10,11,46}") : UIEdgeInsetsFromString(@"{11,44,11,10}");
    _videochatSetting.font      = [UIFont systemFontOfSize:16];
    _videochatSetting.showAvatar = YES;
    _videochatSetting.showTime = YES;
}

/// 未支持的消息
- (void)applyDefaultUnsupportSettings
{
    _unsupportSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _unsupportSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{10,11,9,17}") : UIEdgeInsetsFromString(@"{10,17,9,11}");
    _unsupportSetting.font      = [UIFont systemFontOfSize:16];
    _unsupportSetting.showAvatar = YES;
    _unsupportSetting.showTime = NO;
}

/// 红包消息
- (void)applyDefaultRedSettings
{
    _redSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _redSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{12,16,12,60}") : UIEdgeInsetsFromString(@"{12,16,12,60}");
    _redSetting.font      = [UIFont systemFontOfSize:14];
    _redSetting.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _redSetting.backgroundImageDic[@(YES)] = [UIImage imageWithColor:UIColor.whiteColor];
    _redSetting.backgroundImageDic[@(NO)] = [UIImage imageWithColor:UIColor.whiteColor];
    _redSetting.showAvatar = YES;
    _redSetting.showTime = YES;
}

/// 红包消息
- (void)applyDefaultSuperSettings
{
    _superlinkSetting = [[IMKitMessageSetting alloc] init:_isRight];
    _superlinkSetting.contentInsets = _isRight? UIEdgeInsetsFromString(@"{10,10,10,13}") : UIEdgeInsetsFromString(@"{10,10,10,13}");
    _superlinkSetting.backgroundImageDic[@(YES)] = [UIImage imageWithColor:UIColor.whiteColor];
    _superlinkSetting.backgroundImageDic[@(NO)] = [UIImage imageWithColor:UIColor.whiteColor];
    _superlinkSetting.showAvatar = YES;
    _superlinkSetting.showTime = YES;
    _superlinkSetting.bubbleMaxWidth = 243;
}

@end
