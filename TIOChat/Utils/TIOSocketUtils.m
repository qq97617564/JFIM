//
//  CBSocketUtils.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2017/10/13.
//

#import "TIOSocketUtils.h"
#import <iconv.h>

@implementation TIOSocketUtils

/**
 *  反转字节序列
 *
 *  @param srcData 原始字节NSData
 *
 *  @return 反转序列后字节NSData
 */
+ (NSData *)dataWithReverse:(NSData *)srcData
{
    NSUInteger byteCount = srcData.length;
    NSMutableData *dstData = [[NSMutableData alloc] initWithData:srcData];
    NSUInteger halfLength = byteCount / 2;
    for (NSUInteger i=0; i<halfLength; i++) {
        NSRange begin = NSMakeRange(i, 1);
        NSRange end = NSMakeRange(byteCount - i - 1, 1);
        NSData *beginData = [srcData subdataWithRange:begin];
        NSData *endData = [srcData subdataWithRange:end];
        [dstData replaceBytesInRange:begin withBytes:endData.bytes];
        [dstData replaceBytesInRange:end withBytes:beginData.bytes];
    }
    
    return dstData;
}

+ (NSData *)byteFromInt8:(int8_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    [valData appendBytes:&val length:1];
    return valData;
}

+ (NSData *)bytesFromInt16:(int16_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    [valData appendBytes:&val length:2];
    return valData;
}

+ (NSData *)bytesFromInt32:(int32_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    [valData appendBytes:&val length:4];
    return valData;
}

+ (NSData *)bytesFromInt64:(int64_t)val
{
    NSMutableData *tempData = [[NSMutableData alloc] init];
    [tempData appendBytes:&val length:8];
    return tempData;
}

+ (NSData *)bytesFromValue:(int64_t)value byteCount:(int)byteCount
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    int64_t tempVal = value;
    int offset = 0;
    
    while (offset < byteCount) {
        unsigned char valChar = 0xff & tempVal;
        [valData appendBytes:&valChar length:1];
        tempVal = tempVal >> 8;
        offset++;
    }
    
    return valData;
}

+ (NSData *)bytesFromValue:(int64_t)value byteCount:(int)byteCount reverse:(BOOL)reverse
{
    NSData *tempData = [self bytesFromValue:value byteCount:byteCount];
    if (reverse) {
        return tempData;
    }
    
    return [self dataWithReverse:tempData];
}

+ (int8_t)int8FromBytes:(NSData *)data
{
    NSAssert(data.length >= 1, @"uint8FromBytes: (data length < 1)");
    
    int8_t val = 0;
    [data getBytes:&val length:1];
    return val;
}

+ (int16_t)int16FromBytes:(NSData *)data
{
    NSAssert(data.length >= 2, @"uint16FromBytes: (data length < 2)");
    
    int16_t val = 0;
    [data getBytes:&val length:2];
    return val;
}

+ (int32_t)int32FromBytes:(NSData *)data
{
    NSAssert(data.length >= 4, @"uint16FromBytes: (data length < 4)");
    
    int32_t val = 0;
    [data getBytes:&val length:4];
    return val;
}

+ (int64_t)int64FromBytes:(NSData *)data
{
    NSAssert(data.length >= 8, @"uint16FromBytes: (data length < 8)");
    
    int64_t val = 0;
    [data getBytes:&val length:8];
    return val;
}

+ (int64_t)valueFromBytes:(NSData *)data
{
    NSUInteger dataLen = data.length;
    int64_t value = 0;
    int offset = 0;
    
    while (offset < dataLen) {
        int32_t tempVal = 0;
        [data getBytes:&tempVal range:NSMakeRange(offset, 1)];
        value += (tempVal << (8 * offset));
        offset++;
    }
    
    return value;
}

+ (int64_t)valueFromBytes:(NSData *)data reverse:(BOOL)reverse
{
    NSData *tempData = data;
    if (reverse) {
        tempData = [self dataWithReverse:tempData];
    }
    return [self valueFromBytes:tempData];
}

/** 将字符串转换为data。例如：返回8个字节的data， upano --> <7570616e 6f000000> */
+ (NSData *)dataFromNormalString:(NSString *)normalString byteCount:(int)byteCount
{
    NSAssert(byteCount > 0, @"byteCount <= 0");
    
    char normalChar[byteCount];
    memset(normalChar, 0, byteCount);
    memcpy(normalChar, [normalString UTF8String], MIN(normalString.length, byteCount));
    return [[NSData alloc] initWithBytes:normalChar length:byteCount];
}

+ (NSData *)dataFromHexString:(NSString *)hexString
{
    NSAssert((hexString.length > 0) && (hexString.length % 2 == 0), @"hexString.length mod 2 != 0");
    NSMutableData *data = [[NSMutableData alloc] init];
    for (NSUInteger i=0; i<hexString.length; i+=2) {
        NSRange tempRange = NSMakeRange(i, 2);
        NSString *tempStr = [hexString substringWithRange:tempRange];
        NSScanner *scanner = [NSScanner scannerWithString:tempStr];
        unsigned int tempIntValue;
        [scanner scanHexInt:&tempIntValue];
        [data appendBytes:&tempIntValue length:1];
    }
    return data;
}

+ (NSString *)hexStringFromData:(NSData *)data
{
    NSAssert(data.length > 0, @"data.length <= 0");
    NSMutableString *hexString = [[NSMutableString alloc] init];
    const Byte *bytes = data.bytes;
    for (NSUInteger i=0; i<data.length; i++) {
        Byte value = bytes[i];
        Byte high = (value & 0xf0) >> 4;
        Byte low = value & 0xf;
        [hexString appendFormat:@"%x%x", high, low];
    }//for
    return hexString;
}

+ (NSString *)asciiStringFromHexString:(NSString *)hexString
{
    NSMutableString *asciiString = [[NSMutableString alloc] init];
    const char *bytes = [hexString UTF8String];
    for (NSUInteger i=0; i<hexString.length; i++) {
        [asciiString appendFormat:@"%0.2X", bytes[i]];
    }
    return asciiString;
}

+ (NSString *)hexStringFromASCIIString:(NSString *)asciiString
{
    NSMutableString *hexString = [[NSMutableString alloc] init];
    const char *asciiChars = [asciiString UTF8String];
    for (NSUInteger i=0; i<asciiString.length; i+=2) {
        char hexChar = '\0';
        
        if (asciiChars[i] >= '0' && asciiChars[i] <= '9') {
            hexChar = (asciiChars[i] - '0') << 4;
        } else if (asciiChars[i] >= 'a' && asciiChars[i] <= 'z') {
            hexChar = (asciiChars[i] - 'a' + 10) << 4;
        } else if (asciiChars[i] >= 'A' && asciiChars[i] <= 'Z') {
            hexChar = (asciiChars[i] - 'A' + 10) << 4;
        }
        
        if (asciiChars[i+1] >= '0' && asciiChars[i+1] <= '9') {
            hexChar += asciiChars[i+1] - '0';
        } else if (asciiChars[i+1] >= 'a' && asciiChars[i+1] <= 'z') {
            hexChar += asciiChars[i+1] - 'a' + 10;
        } else if (asciiChars[i+1] >= 'A' && asciiChars[i+1] <= 'Z') {
            hexChar += asciiChars[i+1] - 'A' + 10;
        }
        
        [hexString appendFormat:@"%c", hexChar];
    }
    return hexString;
}

/** 将字典转成字节 */
+ (NSData *)dataFromDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSAssert(!error, error.localizedDescription);
    return !error ? data : nil;
}

/** 将字节转成字典 */
+ (NSDictionary *)dictionaryFromData:(NSData *)data
{
    NSError *error = nil;
//    data = [self cleanUTF8:data];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *toData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:toData options:NSJSONReadingMutableLeaves error:&error];
    NSAssert(!error, error.localizedDescription);
    return !error ? dictionary : nil;
}

+ (NSArray *)arrayFromNSData:(NSData *)data
{
    NSError *error = nil;
    //    data = [self cleanUTF8:data];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *toData = [string dataUsingEncoding:NSUTF8StringEncoding];
    id targetData = [NSJSONSerialization JSONObjectWithData:toData options:NSJSONReadingMutableLeaves error:&error];
    NSAssert(!error, error.localizedDescription);
    return !error ? targetData : nil;
}

// Return line separators.
+ (NSData *)CRLFData
{
    return [NSData dataWithBytes:"\x0D\x0A" length:2];
}

+ (NSData *)CRData
{
    return [NSData dataWithBytes:"\x0D" length:1];
}

+ (NSData *)LFData
{
    return [NSData dataWithBytes:"\x0A" length:1];
}

+ (NSData *)ZeroData
{
    return [NSData dataWithBytes:"" length:1];
}

#pragma mark - 过滤非UTF-8

+ (NSData *)cleanUTF8:(NSData *)data {
    iconv_t cd = iconv_open("UTF-8", "UTF-8"); // 从utf8转utf8
    int one = 1;
    iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // 丢弃不正确的字符
    
    size_t inbytesleft, outbytesleft;
    inbytesleft = outbytesleft = data.length;
    char *inbuf  = (char *)data.bytes;
    char *outbuf = malloc(sizeof(char) * data.length);
    char *outptr = outbuf;
    if (iconv(cd, &inbuf, &inbytesleft, &outptr, &outbytesleft)
        == (size_t)-1) {
        NSLog(@"this should not happen, seriously");
        return nil;
    }
    NSData *result = [NSData dataWithBytes:outbuf length:data.length - outbytesleft];
    iconv_close(cd);
    free(outbuf);
    return result;
}

@end
