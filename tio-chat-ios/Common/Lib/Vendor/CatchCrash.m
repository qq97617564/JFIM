//
//  CatchCrash.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/4/15.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "CatchCrash.h"
#import "PrefixHeader.pch"
#import <DDFileLogger.h>
#import "ImportSDK.h"
#import "APPHTTPManager.h"
#import "TDeviceInfo.h"

@implementation CatchCrash

//在AppDelegate中注册后，程序崩溃时会执行的方法
void uncaughtExceptionHandler(NSException *exception)
{
    //获取系统当前时间，（注：用[NSDate date]直接获取的是格林尼治时间，有时差）
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *crashTime = [formatter stringFromDate:[NSDate date]];
    //异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    //出现异常的原因
    NSString *reason = [exception reason];
    //异常名称
    NSString *name = [exception name];
    
    

    //拼接错误信息
    
    NSString *header = [NSString stringWithFormat:@"异常时间：%@\n手机型号：%@\n系统：%@\n运营商：%@\n",crashTime,TDeviceInfo.deviceModel,TDeviceInfo.sys,TDeviceInfo.mobileOperator];
    
    if ([TIOChat.shareSDK.loginManager isLogined]) {
        header = [header stringByAppendingFormat:@"用户UID：%@\n",TIOChat.shareSDK.loginManager.userInfo.userId?:@"无"];
    }
    
    NSString *exceptionInfo = [header stringByAppendingFormat:@"Exception reason: %@\nException name: %@\nException stack:%@", name, reason, stackArray];

    //把错误信息保存到本地文件，设置errorLogPath路径下
    //并且经试验，此方法写入本地文件有效。
    NSString *errorLogPath = [NSString stringWithFormat:@"%@/Documents/error.log", NSHomeDirectory()];
    
    BOOL isSuccess = [exceptionInfo writeToFile:errorLogPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (!isSuccess) {
        NSLog(@"crash 日志保存失败！");
    }
}

- (void)start
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    //若crash文件存在，则写入log并上传，然后删掉crash文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *errorLogPath = [NSString stringWithFormat:@"%@/Documents/error.log", NSHomeDirectory()];

    for (NSString *str in [fileManager subpathsAtPath:[NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()]]) {
        NSLog(@"str = %@",str);
    }
    
    if ([fileManager fileExistsAtPath:errorLogPath]) {
        //用CocoaLumberJack库的fileLogger.logFileManager自带的方法创建一个新的Log文件，这样才能获取到对应文件夹下排序的Log文件
        NSError *createError = nil;
        [(DDLogFileManagerDefault *)fileLogger.logFileManager isLogFile:@"XXXXXXX"];
        [fileLogger.logFileManager createNewLogFileWithError:&createError];
        if (!createError) {
            //此处必须用firstObject而不能用lastObject，因为是按照日期逆序排列的，即最新的Log文件排在前面
            NSString *newLogFilePath = [fileLogger.logFileManager sortedLogFilePaths].firstObject;
            
            NSError *error = nil;
            NSString *errorLogContent = [NSString stringWithContentsOfFile:errorLogPath encoding:NSUTF8StringEncoding error:nil];
            BOOL isSuccess = [errorLogContent writeToFile:newLogFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            
            if (!isSuccess) {
                DLog(@"crash文件写入log失败: %@", error.userInfo);
            } else {
                DLog(@"crash文件写入log成功");
                NSString *renameLogPath = [self p_setupFileRename:newLogFilePath];
                NSError *error = nil;
                BOOL isSuccess = [fileManager removeItemAtPath:errorLogPath error:&error];
                if (!isSuccess) {
                    DLog(@"删除error文件失败: %@", error.userInfo);
                }
                
                [TIOChat.shareSDK uploadLog:renameLogPath callback:^(NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"上传日志失败");
                    } else {
                        NSError *err = nil;
                        BOOL isSuccess = [fileManager removeItemAtPath:errorLogPath error:&err];
                        if (!isSuccess) {
                            DLog(@"删除本地的crash文件失败: %@", err.userInfo);
                        }
                    }
                }];
            }

        } else {
            NSLog(@"createError = %@",createError.localizedDescription);
        }
    }
}

/**
 对文件重命名

 @param filePath 旧路径
 @return 新路径
 */
- (NSString *)p_setupFileRename:(NSString *)filePath {
    
    NSString *lastPathComponent = [NSString new];
    //获取文件名： 视频.MP4
    lastPathComponent = [filePath lastPathComponent];
    //获取后缀：MP4
    NSString *pathExtension = [filePath pathExtension];
    //用传过来的路径创建新路径 首先去除文件名
    NSString *pathNew = [filePath stringByReplacingOccurrencesOfString:lastPathComponent withString:@""];
    //然后拼接新文件名：新文件名为当前的：年月日时分秒 yyyyMMddHHmmss
    NSString *moveToPath = [NSString stringWithFormat:@"%@%@-%@-%@.%@",pathNew,[self htmi_getCurrentTime],TIOChat.shareSDK.imei?:@"XX",TDeviceInfo.deviceModel,pathExtension];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //通过移动该文件对文件重命名
    BOOL isSuccess = [fileManager moveItemAtPath:filePath toPath:moveToPath error:nil];
    if (isSuccess) {
        NSLog(@"rename success");
    }else{
        NSLog(@"rename fail");
    }
    
    return moveToPath;
}

/**
 获取当地时间
 
 @return 获取当地时间
 */
- (NSString *)htmi_getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}
    
@end
