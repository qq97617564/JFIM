//
//  TDownloadTool.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TDownloadTool.h"
#import <AFNetworking-umbrella.h>

@implementation TDownloadTool

+ (void)t_download:(NSString *)url name:(NSString *)name ext:(NSString *)ext progress:(void (^)(CGFloat))progress completion:(nonnull void (^)(NSError * _Nullable, NSString * _Nullable))completion
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    /* 下载地址 */
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    /* 下载路径 */
    NSString *path = [self documentPath];
//    path = [path stringByAppendingPathComponent:@"File"];
    NSString *filePath = nil;
    if (name.length) {
        filePath = [path stringByAppendingPathComponent:name];
    } else {
        filePath = [path stringByAppendingPathComponent:url.lastPathComponent];
    }
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
        progress(downloadProgress.fractionCompleted);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //如果需要进行UI操作，需要获取主线程进行操作
        });
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];
                
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
         NSLog(@"下载完成");
        completion(nil, filePath.absoluteString);
    }];
    [downloadTask resume];
}

+ (NSString *)documentPath
{
    //获取Document文件
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * rarFilePath = [docsdir stringByAppendingPathComponent:@"File"];//将需要创建的串拼接到后面
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];

    if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return rarFilePath;
}

+ (BOOL)existFileDocument
{
    //获取Document文件
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * rarFilePath = [docsdir stringByAppendingPathComponent:@"File"];//将需要创建的串拼接到后面
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];
    
    return (isDir == YES && existed == YES);
}

@end
