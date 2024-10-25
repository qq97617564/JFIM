//
//  CBSocketData.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2017/10/12.
//

#import "TIOSocketPackage.h"
#import "TIOSocketUtils.h"
#import "NSData+GZIP.h"
#import "TIOMacros.h"

@implementation TIOSocketPackage

+ (TIOSocketPackage *)modelWithData:(NSData *)data
{
    return [[self alloc] initWithData:data];
}

+ (TIOSocketPackage *)socketPackageWithCmd:(int16_t)cmd gzip:(int8_t)gzip body:(id)body
{
    TIOSocketPackage *data = [TIOSocketPackage.alloc init];
    data.cmd = cmd;
    data.gzip = gzip;
    data.body = body;
    
    return data;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self == [super init]) {
        // 解码消息体长度
        NSData *bodyLengthData = [TIOSocketUtils dataWithReverse:[data subdataWithRange:NSMakeRange(0, 2)]];
        self.bodyLength = [TIOSocketUtils int16FromBytes:bodyLengthData];
        
        // 解码命令码
        NSData *cmdData = [TIOSocketUtils dataWithReverse:[data subdataWithRange:NSMakeRange(2, 2)]];
        self.cmd = [TIOSocketUtils int16FromBytes:cmdData];
        
        // 解码GZIP压缩标识
        NSData *gzipData = [data subdataWithRange:NSMakeRange(4, 1)];
        self.gzip = [TIOSocketUtils int8FromBytes:gzipData];
        
        if (self.bodyLength > 0) {
            
            NSData *bodyData = [data subdataWithRange:NSMakeRange(5, self.bodyLength)];
            
            if (self.gzip == 1) {
                bodyData = [bodyData gunzippedData];
            }
            
            self.body = [TIOSocketUtils dictionaryFromData:bodyData];
        } else if (self.bodyLength == 0) {
            
        } else {

        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"bodyLength = %d,\ncmd = %d,\ngzip = %d,\nbody = %@",self.bodyLength,self.cmd,self.gzip,self.body];
}

- (NSInteger)length
{
    NSMutableData *data = [NSMutableData.alloc init];
    [data appendData:[TIOSocketUtils bytesFromInt16:self.bodyLength]];
    [data appendData:[TIOSocketUtils bytesFromInt16:self.cmd]];
    [data appendData:[TIOSocketUtils byteFromInt8:self.gzip]];
    [data appendData:[TIOSocketUtils dataFromDictionary:self.body]];
    return data.length;
}


@end
