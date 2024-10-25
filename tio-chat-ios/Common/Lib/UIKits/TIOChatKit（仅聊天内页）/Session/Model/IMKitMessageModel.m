//
//  IMMessageModel.m
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import "IMKitMessageModel.h"
#import "TIOChatKit.h"
#import "TIOKitTool.h"

@interface IMKitMessageModel ()

@property (nonatomic,strong) NSMutableDictionary *contentSizeInfo;

@end

@implementation IMKitMessageModel

@synthesize contentViewInsets  = _contentViewInsets;
@synthesize bubbleViewInsets   = _bubbleViewInsets;
@synthesize shouldShowAvatar   = _shouldShowAvatar;
@synthesize shouldShowLeft     = _shouldShowLeft;
@synthesize shouldShowTime     = _shouldShowTime;
@synthesize avatarMargin       = _avatarMargin;
@synthesize nickNameMargin     = _nickNameMargin;
@synthesize avatarSize         = _avatarSize;
@synthesize messageContentName = _messageContentName;
@synthesize messageTime        = _messageTime;

- (instancetype)initWithMessage:(TIOMessage *)message
{
    if (self = [self init])
    {
        _message = message;
        _contentSizeInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString*)description{
    return @"聊天内容";
}

- (CGSize)contentSize:(CGFloat)width
{
    CGSize size = [self.contentSizeInfo[@(width)] CGSizeValue];
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
        [self updateLayoutConfig];
        id<IMCellLayoutConfig> layoutConfig = [TIOChatKit.shareSDK cellConfig];
        size = [layoutConfig contentSize:self cellWidth:width];
        [self.contentSizeInfo setObject:[NSValue valueWithCGSize:size] forKey:@(width)];
    }
    return size;
}

- (UIEdgeInsets)contentViewInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(_contentViewInsets, UIEdgeInsetsZero))
    {
        id<IMCellLayoutConfig> layoutConfig = [TIOChatKit.shareSDK cellConfig];
        _contentViewInsets = [layoutConfig contentViewInsets:self];
    }
    return _contentViewInsets;
}

- (UIEdgeInsets)bubbleViewInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(_bubbleViewInsets, UIEdgeInsetsZero))
    {
        id<IMCellLayoutConfig> layoutConfig = [TIOChatKit.shareSDK cellConfig];
        _bubbleViewInsets = [layoutConfig cellInsets:self];
    }
    return _bubbleViewInsets;
}

- (void)cleanCache
{
    _contentViewInsets = UIEdgeInsetsZero;
    _bubbleViewInsets = UIEdgeInsetsZero;
}

- (void)updateLayoutConfig
{
    id<IMCellLayoutConfig> layoutConfig = [TIOChatKit.shareSDK cellConfig];
    
    _shouldShowAvatar       = [layoutConfig shouldShowAvatar:self];
    _shouldShowLeft         = [layoutConfig shouldShowLeft:self];
    _avatarMargin           = [layoutConfig avatarMargin:self];
    _nickNameMargin         = [layoutConfig nickNameMargin:self];
    _avatarSize             = [layoutConfig avatarSize:self];
    _shouldShowTime         = [layoutConfig shouldShowTime:self];
}

- (NSTimeInterval)messageTime
{
    return _message.timestamp;
}

@end
