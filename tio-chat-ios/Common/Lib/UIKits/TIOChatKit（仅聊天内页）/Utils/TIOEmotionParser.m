//
//  TIOEmotionParser.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOEmotionParser.h"

@interface TIOEmotionParser ()
/// tokens缓存 当每一次给cell刷新数据时，避免重复计算
@property (strong,  nonatomic) NSCache  *resultsCache;
@end

@implementation TIOEmotionParser

- (instancetype)init
{
    self = [super init];
    if (self) {
        _resultsCache = [NSCache.alloc init];
    }
    return self;
}

- (NSArray<TIOEmotionResult *> *)resultsWithText:(NSString *)text
{
    NSArray *results = nil;
    
    if (text == nil || text.length == 0) {
        return nil;
    }
    
    results = [_resultsCache objectForKey:text];
    
    if (results) {
        return results;
    } else {
        results = [self parserText:text];
        [_resultsCache setObject:results forKey:text];
        return results;
    }
}

- (void)enumerateMatchesInText:(NSString *)text usingBlock:(nonnull void (^)(TIOEmotionResult * _Nonnull, BOOL * _Nonnull))usingBlock
{
    if (text == nil || text.length == 0) {
        return;
    }
    
    NSArray<TIOEmotionResult *> *results = [_resultsCache objectForKey:text];
    
    if (results) {
        [results enumerateObjectsUsingBlock:^(TIOEmotionResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            usingBlock(obj, stop);
        }];
    } else {
        [self parserText:text usingBlock:usingBlock];
    }
}

#pragma mark - 解析

- (NSArray *)parserText:(NSString *)text
{
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:nil];
    
    __block NSInteger lastTrailLocation = 0; // 记录每一次成功匹配正则结果range的尾位素 从0开始
    NSMutableArray *emotionResults = [NSMutableArray array];
    
    [regular enumerateMatchesInString:text
                              options:0
                                range:NSMakeRange(0, text.length)
                           usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        // 每次匹配结果的range
        NSRange resultRange = result.range;
        // 每次匹配结果的string
        NSString *resultString = [text substringWithRange:resultRange];
        
        if (resultRange.location > lastTrailLocation)
        {
            // 说明本次range和上次匹配结果结果之间有非表情文本
            NSRange textRange = NSMakeRange(lastTrailLocation, resultRange.location - lastTrailLocation);
            
            TIOEmotionResult *emotion = [TIOEmotionResult.alloc init];
            emotion.string = [text substringWithRange:textRange];
            emotion.emotionType = TIOEmotionTypeText;
            emotion.range = textRange;
            
            [emotionResults addObject:emotion];
        }
        
        TIOEmotionResult *emotion = [TIOEmotionResult.alloc init];
        emotion.string = resultString;
        emotion.emotionType = TIOEmotionTypeEmotion;
        emotion.range = resultRange;
        
        [emotionResults addObject:emotion];
        
        lastTrailLocation = resultRange.location + resultRange.length;
    }];
    
    if (lastTrailLocation < text.length)
    {
        NSRange textRange = NSMakeRange(lastTrailLocation, text.length - lastTrailLocation);
        TIOEmotionResult *emotion = [TIOEmotionResult.alloc init];
        emotion.string = [text substringWithRange:textRange];
        emotion.emotionType = TIOEmotionTypeText;
        emotion.range = textRange;
        [emotionResults addObject:emotion];
    }
    
    return emotionResults;
}

- (void)parserText:(NSString *)text usingBlock:(void(^)(TIOEmotionResult *result, BOOL * _Nonnull stop))usingBlock
{
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:nil];
    
    __block NSInteger lastTrailLocation = 0; // 记录每一次成功匹配正则结果range的尾位素 从0开始
    
    [regular enumerateMatchesInString:text
                              options:0
                                range:NSMakeRange(0, text.length)
                           usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        // 每次匹配结果的range
        NSRange resultRange = result.range;
        // 每次匹配结果的string
        NSString *resultString = [text substringWithRange:resultRange];
        
        if (resultRange.location > lastTrailLocation)
        {
            // 说明本次range和上次匹配结果结果之间有非表情文本
            NSRange textRange = NSMakeRange(lastTrailLocation, resultRange.location - lastTrailLocation);
            
            TIOEmotionResult *emotion = [TIOEmotionResult.alloc init];
            emotion.string = [text substringWithRange:textRange];
            emotion.emotionType = TIOEmotionTypeText;
            emotion.range = textRange;
            
            usingBlock(emotion, stop);
        }
        
        TIOEmotionResult *emotion = [TIOEmotionResult.alloc init];
        emotion.string = resultString;
        emotion.emotionType = TIOEmotionTypeEmotion;
        emotion.range = resultRange;
        
        usingBlock(emotion, stop);
        
        lastTrailLocation = resultRange.location + resultRange.length;
    }];
    
    if (lastTrailLocation < text.length)
    {
        NSRange textRange = NSMakeRange(lastTrailLocation, text.length - lastTrailLocation);
        TIOEmotionResult *emotion = [TIOEmotionResult.alloc init];
        emotion.string = [text substringWithRange:textRange];
        emotion.emotionType = TIOEmotionTypeText;
        emotion.range = textRange;
        usingBlock(emotion, nil);
    }
}

@end
