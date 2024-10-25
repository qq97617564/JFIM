//
//  IMKitTool.m
//  CawBar
//
//  Created by admin on 2019/11/24.
//

#import "TIOKitTool.h"

@implementation TIOKitTool

+ (UIImage *)imkit_imageName:(NSString *)imageName
{
//    // 先从项目里搜索
//    UIImage *image = [UIImage imageNamed:imageName];
//    if (image) {
//        return image;
//    }
    // 若项目没有指定图片，则从Kit的Bundle里读取使用该名字的图片
    UIImage *image = [UIImage imageNamed:[@"IMKit.bundle" stringByAppendingPathComponent:imageName]];
    return image;
}

+ (UIWindow *)keyWindow
{
    if (@available(iOS 13.0, *)) {
        UIWindow *window = nil;
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                window = windowScene.windows[1];
                break;
            }
        }
        return window;
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return UIApplication.sharedApplication.keyWindow;
        #pragma clang diagnostic push
    }
}

+ (NSString *)showTime:(NSTimeInterval)msglastTime showDetail:(BOOL)showDetail
{
    //今天的时间
    NSDate * nowDate = [NSDate date];
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:msglastTime/1000];
    NSString *result = nil;
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:components fromDate:nowDate];
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];
    
    NSInteger hour = msgDateComponents.hour;
    double OnedayTimeIntervalValue = 24*60*60;  //一天的秒数

    result = [self getPeriodOfTime:hour withMinute:msgDateComponents.minute];
    if (hour > 12)
    {
        hour = hour - 12;
    }
    
    BOOL isSameMonth = (nowDateComponents.year == msgDateComponents.year) && (nowDateComponents.month == msgDateComponents.month);
    
    if(isSameMonth && (nowDateComponents.day == msgDateComponents.day)) //同一天,显示时间
    {
        result = [[NSString alloc] initWithFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute];
    }
    else if(isSameMonth && (nowDateComponents.day == (msgDateComponents.day+1)))//昨天
    {
        result = showDetail?  [[NSString alloc] initWithFormat:@"昨天 %@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : @"昨天";
    }
    else if(isSameMonth && (nowDateComponents.day == (msgDateComponents.day+2))) //前天
    {
        result = showDetail? [[NSString alloc] initWithFormat:@"前天 %@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : @"前天";
    }
    else if([nowDate timeIntervalSinceDate:msgDate] < 7 * OnedayTimeIntervalValue)//一周内
    {
        NSString *weekDay = [self weekdayStr:msgDateComponents.weekday];
        result = showDetail? [weekDay stringByAppendingFormat:@" %@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : weekDay;
    }
    else//显示日期
    {
        NSString *day = [NSString stringWithFormat:@"%zd年%zd月%zd日", msgDateComponents.year, msgDateComponents.month, msgDateComponents.day];
        result = showDetail? [day stringByAppendingFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute]:day;
    }
    return result;
}

+ (NSString *)timestrampToTimeLengthFomat:(NSTimeInterval)haosecond
{
    NSInteger seconds = haosecond/1000;
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",(long)seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(long)(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",(long)seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
    
}

+ (NSString *)timeStringWithSecond:(NSTimeInterval)second
{
    NSInteger seconds = second;
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",(long)seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(long)(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",(long)seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
    
}

#pragma mark - 私有

+ (NSString *)getPeriodOfTime:(NSInteger)time withMinute:(NSInteger)minute
{
    NSInteger totalMin = time *60 + minute;
    NSString *showPeriodOfTime = @"";
    if (totalMin > 0 && totalMin <= 5 * 60)
    {
        showPeriodOfTime = @"凌晨";
    }
    else if (totalMin > 5 * 60 && totalMin < 12 * 60)
    {
        showPeriodOfTime = @"上午";
    }
    else if (totalMin >= 12 * 60 && totalMin <= 18 * 60)
    {
        showPeriodOfTime = @"下午";
    }
    else if ((totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0)
    {
        showPeriodOfTime = @"晚上";
    }
    return showPeriodOfTime;
}

+(NSString*)weekdayStr:(NSInteger)dayOfWeek
{
    static NSDictionary *daysOfWeekDict = nil;
    daysOfWeekDict = @{@(1):@"星期日",
                       @(2):@"星期一",
                       @(3):@"星期二",
                       @(4):@"星期三",
                       @(5):@"星期四",
                       @(6):@"星期五",
                       @(7):@"星期六",};
    return [daysOfWeekDict objectForKey:@(dayOfWeek)];
}

+ (NSInteger)timeSwitchTimestamp:(NSString *)formatTime
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    
    return timeSp;
    
}

+ (NSString *)fileSize:(long long)size
{
    long KB = 1024;
    long MB = KB * 1024;
    long GB = MB * 1024;
    
    if (size >= GB)
    {
        return [NSString stringWithFormat:@"%.1f GB", (float) size / GB];
        
    } else if (size >= MB)
    {
        float f = (float) size / MB;
        if (f > 100)
        {
            return [NSString stringWithFormat:@"%.0f MB", f];
        }
        else
        {
            return [NSString stringWithFormat:@"%.1f MB", f];
        }
    } else if (size >= KB)
    {
        float f = (float) size / KB;
        if (f > 100)
        {
            return [NSString stringWithFormat:@"%.0f KB", f];
        }
        else
        {
            return [NSString stringWithFormat:@"%.1f KB", f];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"%lld B", size];
    }
}

@end
