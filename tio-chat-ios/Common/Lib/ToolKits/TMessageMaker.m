//
//  P2PMessageMaker.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/15.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TMessageMaker.h"
#import "ImportSDK.h"
#import "TIOKitTool.h"

@implementation TMessageMaker

+ (TIOMessage *)messageForTextWithText:(NSString *)text session:(nonnull TIOSession *)session
{
    TIOMessage *message = [TIOMessage.alloc init];
    message.messageType = TIOMessageTypeText;
    message.session = session;
    message.text = text;
    
    return message;
}

+ (TIOMessage *)messageForImage:(UIImage *)image session:(TIOSession *)session
{
    TIOMessage *message = [TIOMessage.alloc init];
    message.messageType = TIOMessageTypeImage;
    message.session = session;
    TIOMessageAttachmnet *attachment = [TIOMessageAttachmnet.alloc init];
    attachment.localData    = [image data_compressToByte:3000];
    message.attachmentObjects = @[attachment];
    
    return message;
}

+ (TIOMessage *)messageForImageData:(NSData *)data session:(TIOSession *)session ext:(NSString * _Nullable)ext
{
    TIOMessage *message = [TIOMessage.alloc init];
    message.messageType = TIOMessageTypeImage;
    message.session = session;
    TIOMessageAttachmnet *attachment = [TIOMessageAttachmnet.alloc init];
    attachment.localData    = data;
    attachment.ext = ext;
    message.attachmentObjects = @[attachment];
    
    return message;
}

+ (TIOMessage *)messageForFileURL:(NSURL *)fileURL session:(TIOSession *)session
{
    TIOMessage *message = [TIOMessage.alloc init];
    message.messageType = TIOMessageTypeFile;
    message.session = session;
    TIOMessageAttachmnet *attachment = [TIOMessageAttachmnet.alloc init];
    attachment.localURL = fileURL; // 本地文件URL
    message.attachmentObjects = @[attachment];
    
    return message;
}

+ (TIOMessage *)messageForVideoURL:(NSURL *)videoURL session:(TIOSession *)session
{
    TIOMessage *message = [TIOMessage.alloc init];
    message.messageType = TIOMessageTypeVideo;
    message.session = session;
    TIOMessageAttachmnet *attachment = [TIOMessageAttachmnet.alloc init];
    attachment.localURL = videoURL; // 本地视频URL
    message.attachmentObjects = @[attachment];
    
    return message;
}

+ (TIOMessage *)messageForFriendCard:(NSString *)shareId type:(BOOL)isTeam session:(TIOSession *)session
{
    TIOMessage *message = [TIOMessage.alloc init];
    message.messageType = TIOMessageTypeCard;
    message.session = session;
    message.cardType = isTeam ? 2 : 1;
    message.cardid = shareId;
    
    return message;
}

+ (TIOMessage *)messageForAudioFileURL:(NSURL *)audioFileURL session:(TIOSession *)session
{
    TIOMessage *message = [TIOMessage.alloc init];
    message.messageType = TIOMessageTypeAudio;
    message.session = session;
    TIOMessageAttachmnet *attachment = [TIOMessageAttachmnet.alloc init];
    attachment.localURL = audioFileURL; // 本地视频URL
    message.attachmentObjects = @[attachment];
    
    return message;
}

/// 计算不同消息类型的最新消息显示
/// @param message 消息
/// @param at 是否被at
/// @param beread 自己的消息被读状态
+ (NSMutableAttributedString *)messageForMessage:(TIOMessage *)message isAt:(BOOL)at beread:(NSInteger)beread unreadCount:(NSInteger)unreadCount
{
    NSMutableAttributedString *attributedString = nil;
    
    UIFont *font = [UIFont systemFontOfSize:14];
    UIColor *normalColor = [UIColor colorWithHex:0x888888];//[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    UIColor *specialColor = [UIColor colorWithRed:58/255.0 green:136/255.0 blue:251/255.0 alpha:1.0];
    UIColor *atMsgColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    
    // 自己的消息未被读标记
    NSAttributedString *unBeReadString = [NSAttributedString.alloc initWithString:@"[未读] " attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:specialColor}];
    // 自己的消息已被读标记
    NSAttributedString *beReadString = [NSAttributedString.alloc initWithString:@"[已读] " attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
    
    TIOLoginUser *curruser = [TIOChat.shareSDK.loginManager userInfo];
    NSString *from = [message.fromUId isEqualToString:curruser.userId] ? @"我" : message.from;
    
    switch (message.messageType) {
            
        case TIOMessageTypeText:
        {
            message.text = [message.text stringByReplacingOccurrencesOfString:@"\n" withString:@"、"];
            if (!message.text.length) {
                break;
            }
            
            if (message.sysFlag == 1 && message.sysmsgkey.length) {
                attributedString = [NSMutableAttributedString.alloc initWithString:[self tipForMessage:message] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
                break;
            }
            
            if (at) {
                attributedString = [NSMutableAttributedString.alloc initWithString:@"[有人@我] " attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:specialColor}];
                
                [attributedString appendAttributedString:[NSAttributedString.alloc initWithString:[NSString stringWithFormat:@"%@：%@",message.from,message.text] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:atMsgColor}]];
                break;
            }
            
            if (message.session.sessionType == TIOSessionTypeP2P) {
                attributedString = [NSMutableAttributedString.alloc initWithString:message.text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            } else {
                attributedString = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@"%@：%@",from,message.text] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            }
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
            
        }
            break;
        case TIOMessageTypeImage:
        {
            if (message.session.sessionType == TIOSessionTypeP2P) {
                attributedString = [NSMutableAttributedString.alloc initWithString:message.text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            } else {
                attributedString = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@"%@：%@",from,message.text] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            }
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeAudio:
        {
            
            if (message.session.sessionType == TIOSessionTypeP2P) {
                attributedString = [NSMutableAttributedString.alloc initWithString:message.text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            } else {
                attributedString = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@"%@：%@",from,message.text] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            }
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeVideo:
        {
            if (message.session.sessionType == TIOSessionTypeP2P) {
                attributedString = [NSMutableAttributedString.alloc initWithString:message.text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            } else {
                attributedString = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@"%@：%@",from,message.text] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            }
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeLocation:
        {
            attributedString = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@"%@：%@",from,message.text] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeNotification:
        {
            attributedString = [NSMutableAttributedString.alloc initWithString:message.text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeFile:
        {
            NSString *text = [NSString stringWithFormat:@"%@：%@",from,message.text];
            
            if (message.session.sessionType == TIOSessionTypeP2P) {
                text = message.text;
            }
            
            attributedString = [NSMutableAttributedString.alloc initWithString:text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeRed:
        {
            NSString *text = [NSString stringWithFormat:@"%@：%@",from,message.text];
            
            if (message.session.sessionType == TIOSessionTypeP2P) {
                text = message.text;
            }
            attributedString = [NSMutableAttributedString.alloc initWithString:text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
        }
            break;
        case TIOMessageTypeTip:
        {
            
            attributedString = [NSMutableAttributedString.alloc initWithString:[self tipForMessage:message] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
        }
            break;
        case TIOMessageTypeCard:
        {
            NSString *text = [NSString stringWithFormat:@"%@：%@",from,message.text];
            
            if (message.session.sessionType == TIOSessionTypeP2P) {
                text = message.text;
            }
            attributedString = [NSMutableAttributedString.alloc initWithString:text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeRobot:
        {
            attributedString = [NSMutableAttributedString.alloc initWithString:message.text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeAudioChat:
        {
            NSString *text = [NSString stringWithFormat:@"%@：%@",from,message.text];
            
            if (message.session.sessionType == TIOSessionTypeP2P) {
                text = message.text;
            }
            attributedString = [NSMutableAttributedString.alloc initWithString:text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeVideoChat:
        {
            NSString *text = [NSString stringWithFormat:@"%@：%@",from,message.text];
            
            if (message.session.sessionType == TIOSessionTypeP2P) {
                text = message.text;
            }
            attributedString = [NSMutableAttributedString.alloc initWithString:text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
        case TIOMessageTypeSuperLink:
        {
            NSString *text = [NSString stringWithFormat:@"%@：%@",from,message.text];
            
            if (message.session.sessionType == TIOSessionTypeP2P) {
                text = message.text;
            }
            attributedString = [NSMutableAttributedString.alloc initWithString:text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
            
        default:
        {
            attributedString = [NSMutableAttributedString.alloc initWithString:message.text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
            
            if (beread == 2) {
                [attributedString insertAttributedString:unBeReadString atIndex:0];
            } else if (beread == 1) {
                [attributedString insertAttributedString:beReadString atIndex:0];
            }
        }
            break;
    }
    
    // 消息前加上未读消息【XXX条消息】
    NSAttributedString *unreadString = nil;
    if (unreadCount > 0) {
        unreadString = [NSAttributedString.alloc initWithString:[NSString stringWithFormat:@"[%zd条消息]",unreadCount] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor}];
        [attributedString insertAttributedString:unreadString atIndex:0];
    }
    
    return attributedString;
}

+ (NSString *)tipForMessage:(TIOMessage *)message
{
    if (!message.opernick || !message.opernick.length) {
        return message.text;
    }
    
    TIOLoginUser *curruser = [TIOChat.shareSDK.loginManager userInfo];
    
    NSString *nick = message.opernick;
    NSString *tonicks = message.tonicks;
    nick = [nick isEqualToString:curruser.nick] ? @"你" : nick;
    tonicks = [tonicks isEqualToString:curruser.nick] ? @"你" : tonicks;
    NSString * c= message.text;
    
    if ([message.sysmsgkey isEqualToString:@"create"]) {
        c = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入了群聊",nick,tonicks];
    } else if ([message.sysmsgkey isEqualToString:@"join"]) {
        c = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入了群聊",nick,tonicks];
        if ([message.session.name isEqualToString:@"123456"]) {
            NSLog(@"c = %@",c);
        }
    } else if ([message.sysmsgkey isEqualToString:@"ownerleave"]) {
        c = [NSString stringWithFormat:@"\"%@\"退出了群聊，\"%@\"自动成为了群主",nick,tonicks];
    } else if ([message.sysmsgkey isEqualToString:@"leave"]) {
        // c=nick+"退出了群聊";
        c = [NSString stringWithFormat:@"\"%@\"退出了群聊",nick];
    } else if ([message.sysmsgkey isEqualToString:@"operkick"]) {
        // c=nick+"将"+tonicks+"移除了群聊";
        c = [NSString stringWithFormat:@"\"%@\"将\"%@\"移除了群聊",nick,tonicks];
    } else if ([message.sysmsgkey isEqualToString:@"tokick"]) {
        // c=tonicks+"被"+nick+"移除了群聊";
        c = [NSString stringWithFormat:@"\"%@\"被\"%@\"移除了群聊",tonicks,nick];
    } else if ([message.sysmsgkey isEqualToString:@"msgback"]) {
        // c=nick+"撤回了一条消息";
        c = [NSString stringWithFormat:@"\"%@\"撤回了一条消息",nick];
    } else if ([message.sysmsgkey isEqualToString:@"ownerchange"]) {
        // c=nick+"将群主转让给了"+tonicks;
        c = [NSString stringWithFormat:@"\"%@\"将群主转让给了 %@",nick,tonicks];
    } else if ([message.sysmsgkey isEqualToString:@"applyopen"]) {
        // c=nick+"开启了群邀请开关：所有人都可以邀请人员进群";
        c = [NSString stringWithFormat:@"\"%@\"开启了群邀请开关：所有人都可以邀请人员进群",nick];
    } else if ([message.sysmsgkey isEqualToString:@"applyclose"]) {
        // c=nick+"关闭了群邀请开关：只有群主或者群管理员才能邀请人员进群";
        c = [NSString stringWithFormat:@"\"%@\"关闭了群邀请开关：只有群主或者群管理员才能邀请人员进群",nick];
    } else if ([message.sysmsgkey isEqualToString:@"reviewopen"]) {
        // c=nick+"开启群审核开关：成员进群前,必须群主或者群管理员审核通过";
        c = [NSString stringWithFormat:@"\"%@\"开启群审核开关：成员进群前,必须群主或者群管理员审核通过",nick];
    } else if ([message.sysmsgkey isEqualToString:@"reviewclose"]) {
        // c=nick+"关闭了群审核开关：成员进群不需要审核";
        c = [NSString stringWithFormat:@"\"%@\"关闭了群审核开关：成员进群不需要审核",nick];
    } else if ([message.sysmsgkey isEqualToString:@"updatenotice"]) {
        // c=nick+"修改了群公告:"+tonicks;
        c = [NSString stringWithFormat:@"\"%@\"修改了群公告:\"%@\"",nick,tonicks];
    } else if ([message.sysmsgkey isEqualToString:@"updatename"]) {
        // c=nick+"修改了群名称:"+tonicks;
        c = [NSString stringWithFormat:@"\"%@\"修改了群名称:\"%@\"",nick,tonicks];
    } else if ([message.sysmsgkey isEqualToString:@"delgroup"]) {
        // c=nick+"解散了群";
        c = [NSString stringWithFormat:@"\"%@\"解散了群",nick];
    } else if ([message.sysmsgkey isEqualToString:@"forbidden"]) {
        c = [NSString stringWithFormat:@"\"%@\" 已被禁言",tonicks];
    } else if ([message.sysmsgkey isEqualToString:@"cancelforbidden"]) {
        c = [NSString stringWithFormat:@"\"%@\" 已被解除禁言",tonicks];
    } else if ([message.sysmsgkey isEqualToString:@"managermsgback"]) {
        c = [NSString stringWithFormat:@"\"%@\"撤回了一条成员消息",nick];
    } else {
        NSLog(@"[消息模板] sysmsgkey = %@, opernick:%@, tonicks:%@",message.sysmsgkey,nick, tonicks);
        c = message.text;
    }
    
    return c;
}

+ (NSString *)videoChatMessageFor:(TIOMessage *)message
{
    NSString *msg = @"";
    BOOL isVideoChat = message.messageType == TIOMessageTypeVideoChat;
    // 是不是自己发起的
    BOOL isSelf = message.isOutgoingMsg;
    
    switch (message.attachmentObjects.firstObject.hanguptype) {
        case TIOCallHangupTypeNormal:
        {
            msg = [NSString stringWithFormat:@"通话时长 %@",[TIOKitTool timestrampToTimeLengthFomat:message.attachmentObjects.firstObject.duration]];
        }
            break;
        case TIOCallHangupTypeRefuse:
        {
            msg = isSelf ? @"对方已拒绝" : @"已拒绝";
        }
            break;
        case TIOCallHangupTypeInCalling:
        {
            msg = isSelf ? @"对方忙线中" : @"忙线未接听";
        }
            break;
        case TIOCallHangupTypeNotOnline:
        {
            if (!isSelf) {
                if (isVideoChat) {
                    msg = @"视频通话未接听";
                } else {
                    msg = @"音频通话未接听";
                }
            } else {
                msg = @"对方不在线";
            }
        }
            break;
        case TIOCallHangupTypeTimeout:
        {
            if (!isSelf) {
                if (isVideoChat) {
                    msg = @"视频通话未接听";
                } else {
                    msg = @"音频通话未接听";
                }
            } else {
                msg = @"对方未接听";
            }
        }
            break;
        case TIOCallHangupTypeCallerHangup:
        {
            if (isSelf) {
                msg = isVideoChat ? @"视频通话已取消" : @"音频通话已取消";
            } else {
                msg = @"对方已取消";
            }
        }
            break;
            
        default:
            msg = @"网络中断";
            break;
    }
    
    return msg;
}

+ (NSMutableAttributedString *)redpackageTipForMessage:(TIOMessage *)message
{
    NSString *linkString = @"红包";
    
    NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
    NSTextAttachment *attach = [NSTextAttachment.alloc init];
    attach.bounds = CGRectMake(0, -3, 17, 17);
    attach.image = [UIImage imageNamed:@"red_tip"];
    [aString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
    
    [aString appendAttributedString:[NSAttributedString.alloc initWithString:[NSString stringWithFormat:@"%@领取了你的",message.from] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor colorWithHex:0xB7B7B7]}]];
    [aString appendAttributedString:[NSAttributedString.alloc initWithString:linkString attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor colorWithHex:0xFF5E5E]}]];
    
    return aString;;
}

+ (NSString *)htmlEncode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&ldquo;"];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&rdquo;"];
    string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
    return string;
}

+ (NSString *)htmlDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    return string;
}

@end
