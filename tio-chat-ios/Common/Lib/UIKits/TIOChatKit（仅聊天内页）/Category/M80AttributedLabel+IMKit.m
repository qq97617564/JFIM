//
//  M80AttributedLabel+IMKit.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/31.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "M80AttributedLabel+IMKit.h"
#import "PPStickerDataManager.h"
#import "PPSticker.h"
#import "TIOEmotionParser.h"

@implementation M80AttributedLabel (IMKit)

- (void)im_setText:(NSString *)text
{
    [self setText:@""];
    
    text = [self htmlEntityDecode:text];
    
    // TODO: 解析表情
    TIOEmotionParser *emotionParser = [TIOEmotionParser.alloc init];
    
    NSArray<TIOEmotionResult *> *emotions = [emotionParser resultsWithText:text];
    
    [emotions enumerateObjectsUsingBlock:^(TIOEmotionResult * _Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (result.emotionType == TIOEmotionTypeText)
        {
            [self appendText:result.string];
        }
        else
        {
            __block BOOL canMatchImage = NO;
            [PPStickerDataManager.sharedInstance.allStickers.firstObject.emojis enumerateObjectsUsingBlock:^(PPEmoji * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                if ([result.string isEqualToString:obj.emojiDescription])
                {
                    UIImage *image = [UIImage imageNamed:[@"Sticker.bundle" stringByAppendingPathComponent:obj.imageName]];
                    [self appendImage:image maxSize:CGSizeMake(26, 26)];

                    canMatchImage = YES;
                    *stop = YES;
                }
            }];
            
            if (!canMatchImage)
            {
                /// 没有匹配的表情图片
                [self appendText:result.string];
            }
        }
    }];
    
}

- (NSString *)htmlEntityDecode:(NSString *)string
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
