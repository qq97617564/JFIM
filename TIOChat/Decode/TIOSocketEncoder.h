//
//  CBEncoder.h
//  CawBar
//
//  Created by 刘宇 on 2017/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOSocketEncoder;
@class TIOSocketPackage;

@protocol TIOEncoderDelegate <NSObject>

@required

/**
 编码完成回调

 @param encoder 编码器
 @param encodedData 编码之后的数据
 */
- (void)encoder:(TIOSocketEncoder *)encoder encodedData:(NSData *)encodedData;

@end

@interface TIOSocketEncoder : NSObject

+ (TIOSocketEncoder *)shareInstance;

- (void)encodeWithData:(TIOSocketPackage  *)data output:(id<TIOEncoderDelegate>)output;

@end

NS_ASSUME_NONNULL_END
