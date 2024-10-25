//
//  CBDecodeSocket.h
//  CawBar
//
//  Created by 刘宇 on 2017/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOSocketDecoder;
@class TIOSocketPackage;

@protocol TIODecoderDelegate <NSObject>

@required

/**
 解码完成回调

 @param decoder 解码器
 @param data 解码完成的数据
 */
- (void)decoder:(TIOSocketDecoder *)decoder decodeData:(TIOSocketPackage *)data;

@end

@interface TIOSocketDecoder : NSObject

+ (TIOSocketDecoder *)shareInstance;

- (void)decodeWithData:(NSData  *)data output:(id<TIODecoderDelegate>)output;

@end

NS_ASSUME_NONNULL_END
