//
//  NSData+GZIP.h
//  CawBar
//
//  Created by admin on 2017/11/17.
//

#import <Foundation/Foundation.h>

@interface NSData (GZIP)

- (nullable NSData *)gzippedDataWithCompressionLevel:(float)level;
- (nullable NSData *)gzippedData;
- (nullable NSData *)gunzippedData;
- (BOOL)isGzippedData;

@end
