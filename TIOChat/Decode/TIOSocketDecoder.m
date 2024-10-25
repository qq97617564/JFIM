//
//  CBDecodeSocket.m
//  CawBar
//
//  Created by 刘宇 on 2017/10/12.
//

#import "TIOSocketDecoder.h"
#import "TIOSocketPackage.h"
#import "TIOSocketUtils.h"

@interface TIOSocketDecoder()

@property (strong, nonatomic) NSMutableData *buffer;    //数据缓冲区
@property (strong, nonatomic) NSData     *completeData;  //一条完整的数据
@property (assign, nonatomic) int32_t    head;   //数据部分长度
@property (assign, nonatomic) int32_t    headLength; //数据头长度
@property (assign, nonatomic) NSUInteger completeLength; //一个完整数据包（头+数据部分）长度
@property (assign, nonatomic) NSInteger  bufferLength;   //缓存数据的长度

@end

@implementation TIOSocketDecoder

+ (TIOSocketDecoder *)shareInstance
{
    static TIOSocketDecoder *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (void)decodeWithData:(NSData *)data output:(id<TIODecoderDelegate>)output
{
    if (!self.buffer) {
        self.buffer = [NSMutableData data];
    }
    [self.buffer appendData:data];
    
    //  缓存数据长度
    self.bufferLength = self.buffer.length;
    //  计算缓存中第一个数据包长度
    self.completeLength = [self lengthForCompleteData:self.buffer];
    
    /**
     *  缓存长度 >= 待取数据长度
     *  可以取出一条完整的数据
     */
    while (self.bufferLength >= _completeLength) {
        //  截取第一条数据
        self.completeData = [self.buffer subdataWithRange:NSMakeRange(0, self.completeLength)];
        //  将数据回调出去
        [output decoder:self decodeData:[self socektModelWithData:self.completeData]];
        
        /**
         *  计算缓存剩余长度
         */
        unsigned long restLength = self.bufferLength - self.completeLength;
        if (restLength == 0) {
            //  缓存正好全部是已取数据
            [self.buffer resetBytesInRange:NSMakeRange(0, self.bufferLength)];
            [self.buffer setLength:0];
            
            //  计算剩余缓存长度和下一个待取数据长度
            self.bufferLength = self.buffer.length;
            self.completeLength = 0;
            
            break;
        } else if (restLength > 1) {
            self.buffer = [NSMutableData dataWithData:[self.buffer subdataWithRange:NSMakeRange(self.completeLength, self.buffer.length - self.completeLength)]];
            
            //  计算剩余缓存长度和下一个待取数据长度
            self.bufferLength = self.buffer.length;
            self.completeLength = [self lengthForCompleteData:self.buffer];
            
        } else {
            break;
        }
    }
}

/**
 读取一个完整数据包的长度

 @param data 数据
 @return 一个完整数据包的长度
 */
- (int)lengthForCompleteData:(NSData *)data
{
    NSData *bodyLengthData = [TIOSocketUtils dataWithReverse:[data subdataWithRange:NSMakeRange(0, 2)]];
    return 5 + [TIOSocketUtils int16FromBytes:bodyLengthData];
}

- (TIOSocketPackage *)socektModelWithData:(NSData *)data
{
    TIOSocketPackage *socketPackage = [TIOSocketPackage modelWithData:data];
    
    return socketPackage;
}

@end
