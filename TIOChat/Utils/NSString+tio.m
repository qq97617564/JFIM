//
//  NSString+tio.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "NSString+tio.h"
#import "TIOChat.h"
#import "TIOMacros.h"

@implementation NSString (tio)

+ (BOOL)isEmpty:(NSString *)str
{
    if (!str) {
        return YES;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (NSString *)tio_resourceURLString
{
    if (self) {
        if (![self hasPrefix:@"http"] && self.length!= 0) {
            NSString *url = [TIOChat.shareSDK.config.resourceAddress stringByAppendingString:self?:@""];
            // 处理URL中的中文编码
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            return url;
        } else {
            return self;
        }
    } else {
        return nil;
    }
}

- (NSString *)tio_HTML5URLString
{
    if (![self hasPrefix:@"http"]) {
        return [TIOChat.shareSDK.config.httpsAddress stringByAppendingString:self?:@""];
    } else {
        return self;
    }
}

- (NSString *)tio_getMMdd
{
    NSArray *arr1 = [self componentsSeparatedByString:@" "];
    NSString *str = arr1.firstObject;
    NSArray *arr2 = [str componentsSeparatedByString:@"-"];
    return [NSString stringWithFormat:@"%@-%@",arr2[1],arr2[2]];
}

- (NSString *)tio_getHHmm
{
    NSArray *arr1 = [self componentsSeparatedByString:@" "];
    
    NSString *HHmmss = arr1.lastObject;
    
    NSArray *HHmmssArray = [HHmmss componentsSeparatedByString:@":"];
    
    NSString *mm = HHmmssArray[1];
    NSString *SS = HHmmssArray[1];
    return [NSString stringWithFormat:@"%@:%@",mm,SS];
}

+ (NSString *)tio_getTimeWithFormat:(NSString *)format timeInterval:(NSTimeInterval)timeInterval
{
    NSTimeInterval time = timeInterval/1000;//因为时差问题要加8小时 == 28800 sec
    
    NSDate* detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    
    TIOLog(@"date:%@",[detaildate description]);
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:format];
    
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    return currentDateStr;
}

@end
