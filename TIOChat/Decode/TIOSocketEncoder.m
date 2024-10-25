//
//  CBEncoder.m
//  CawBar
//
//  Created by 刘宇 on 2017/10/12.
//

#import "TIOSocketEncoder.h"
#import "TIOSocketPackage.h"
#import "TIOSocketUtils.h"
#import "TIOMacros.h"

@implementation TIOSocketEncoder

+ (TIOSocketEncoder *)shareInstance
{
    static TIOSocketEncoder *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (void)encodeWithData:(TIOSocketPackage *)data output:(id<TIOEncoderDelegate>)output
{
    if (data.length < 4) {
        TIOLog(@"Error：数据包长度错误");
        return;
    }
    
    NSMutableData *sendData = [[NSMutableData alloc] init];
    NSData *bodyData = [TIOSocketUtils dataFromDictionary:data.body];
    NSData *bodyLengthData = [TIOSocketUtils bytesFromValue:bodyData.length byteCount:2 reverse:NO];
    NSData *cmdData = [TIOSocketUtils bytesFromValue:data.cmd byteCount:2 reverse:NO];
    NSData *gzipData = [TIOSocketUtils bytesFromValue:data.gzip byteCount:1 reverse:NO];
    [sendData appendData:bodyLengthData];
    [sendData appendData:cmdData];
    [sendData appendData:gzipData];
    [sendData appendData:bodyData];
    
    
    NSInteger bodyLength = [TIOSocketUtils int16FromBytes:bodyLengthData];
    
    TIOLog(@"\n发送socket数据:\nbodyLength:%zd \ncmd:%hd\ngzip:%hhd\nbody:%@\n",bodyLength,data.cmd,data.gzip,data.body);
    
    if (@protocol(TIOEncoderDelegate) && [output respondsToSelector:@selector(encoder:encodedData:)]) {
        [output encoder:self encodedData:sendData];
    }
}

@end
