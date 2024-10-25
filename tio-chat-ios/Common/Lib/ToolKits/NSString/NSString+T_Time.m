//
//  NSString+T_Time.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "NSString+T_Time.h"


@implementation NSString (T_Time)

- (NSString *)getMMdd
{
    NSArray *arr1 = [self componentsSeparatedByString:@" "];
    NSString *str = arr1.firstObject;
    NSArray *arr2 = [str componentsSeparatedByString:@"-"];
    return [NSString stringWithFormat:@"%@-%@",arr2[1],arr2[2]];
}

- (NSString *)getHHmm
{
    NSArray *arr1 = [self componentsSeparatedByString:@" "];
    
    NSString *HHmmss = arr1.lastObject;
    
    NSArray *HHmmssArray = [HHmmss componentsSeparatedByString:@":"];
    
    NSString *HH = HHmmssArray[0];
    NSString *mm = HHmmssArray[1];
    return [NSString stringWithFormat:@"%@:%@",HH,mm];
}

+ (NSString *)getTimeWithFormat:(NSString *)format timeInterval:(NSTimeInterval)timeInterval
{
    NSTimeInterval time = timeInterval/1000;//因为时差问题要加8小时 == 28800 sec
    
    NSDate* detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    
//    NSLog(@"date:%@",[detaildate description]);
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:format];
    
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    return currentDateStr;
}

+ (NSString *)calculateSpendTimeFromDate:(NSString *)date1 toDate:(NSString *)date2
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* startDate = [formater dateFromString:date1];
    NSDate* endDate = [formater dateFromString:date2];
    NSTimeInterval timeInterval = [endDate timeIntervalSinceDate:startDate];
    
//    timeInterval = -timeInterval;
    long temp = 0;
    //    NSString *time;
    if (timeInterval<60) {
        return [NSString stringWithFormat:@"%.0f秒",timeInterval];
    }else if ((temp = timeInterval/60)<60){
        return [NSString stringWithFormat:@"%ld分钟",temp];
    }else if ((temp = timeInterval/(60*60))<24){
        return [NSString stringWithFormat:@"%ld小时",temp];
    }else if((temp = timeInterval/(24*60*60))<30){
        return [NSString stringWithFormat:@"%ld天",temp];
    }else if (((temp = timeInterval/(24*60*60*30)))<12){
        return [NSString stringWithFormat:@"%ld月",temp];
    }else {
        temp = timeInterval/(24*60*60*30*12);
        return [NSString stringWithFormat:@"%ld年",temp];
    }
}

+ (NSString *)transferToLengthFromSeconds:(NSTimeInterval)timeInterval
{
    NSInteger seconds = timeInterval;
    NSInteger hours = seconds / 60 / 60;
    
    if (hours) return [NSString stringWithFormat:@"%zd小时", hours];
    
    NSInteger minutes = seconds / 60;
    
    if (minutes) return [NSString stringWithFormat:@"%zd分钟", minutes];
    
    if (seconds) return [NSString stringWithFormat:@"%zd秒", seconds];
    
    return @"无时长";
}

/// 会话列表中每条会话的时间显示规则
- (NSString *)timeOfsessionList
{
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate*inputDate = [inputFormatter dateFromString:self];
    //NSLog(@"startDate= %@", inputDate);
    
    NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //get date str
    NSString *str= [outputFormatter stringFromDate:inputDate];
    //str to nsdate
    NSDate *strDate = [outputFormatter dateFromString:str];
    //修正8小时的差时
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: strDate];
    NSDate *endDate = [strDate  dateByAddingTimeInterval: interval];
    //NSLog(@"endDate:%@",endDate);
    NSString *lastTime = [self compareDate:endDate];
    return lastTime;
}

- (NSString *)compareDate:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    
    //修正8小时之差
    NSDate *date1 = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date1];
    NSDate *localeDate = [date1  dateByAddingTimeInterval: interval];
    
    //NSLog(@"nowdate=%@\nolddate = %@",localeDate,date);
    NSDate *today = localeDate;
    NSDate *yesterday,*beforeOfYesterday;
    //今年
    NSString *toYears;
    
    toYears = [[today description] substringToIndex:4];
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    beforeOfYesterday = [yesterday dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString *todayString = [[today description] substringToIndex:10];
    NSString *yesterdayString = [[yesterday description] substringToIndex:10];
    NSString *beforeOfYesterdayString = [[beforeOfYesterday description] substringToIndex:10];
    
    NSString *dateString = [[date description] substringToIndex:10];
    NSString *dateYears = [[date description] substringToIndex:4];
    
    if ([dateYears isEqualToString:toYears]) {//同一年
        //今 昨 前天的时间
        NSString *time = [[date description] substringWithRange:(NSRange){11,5}];
        //其它时间
        NSString *time2 = [[date description] substringWithRange:(NSRange){5,5}];
        if ([dateString isEqualToString:todayString]){
            return time;
        } else if ([dateString isEqualToString:yesterdayString]){
            return @"昨天";
        }else if ([dateString isEqualToString:beforeOfYesterdayString]){
            return @"前天";
        }else{
            return time2;
        }
    }else{
        return dateString;
    }
}

- (NSTimeInterval)timeSpaceSinceNow
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *lastDate = [formatter dateFromString:self];
    //八小时时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:lastDate];
    NSDate *mydate = [lastDate dateByAddingTimeInterval:interval];
    NSDate *nowDate = [[NSDate date] dateByAddingTimeInterval:interval];
    //两个时间间隔
    NSTimeInterval timeInterval = [mydate timeIntervalSinceDate:nowDate];
    timeInterval = -timeInterval;
    return timeInterval;
}

- (NSString *)timeYYMMdd
{
    NSArray *arr1 = [self componentsSeparatedByString:@" "];
    
    if (arr1.count == 0) {
        return self;
    }
    
    NSString *YYMMdd = arr1.firstObject;
    NSArray *YYMMddArray = [YYMMdd componentsSeparatedByString:@"-"];
    
    if (YYMMddArray.count == 0) {
        return self;
    }
    
    if (YYMMddArray.count == 1) {
        NSString *YY = YYMMddArray[0];
        return [NSString stringWithFormat:@"%@",YY];
    }
    
    if (YYMMddArray.count == 2) {
        NSString *YY = YYMMddArray[0];
        NSString *MM = YYMMddArray[1];
        return [NSString stringWithFormat:@"%@-%@",YY,MM];
    }
    
    NSString *YY = YYMMddArray[0];
    NSString *MM = YYMMddArray[1];
    NSString *dd = YYMMddArray[2];
    return [NSString stringWithFormat:@"%@-%@-%@",YY,MM,dd];
}

@end
