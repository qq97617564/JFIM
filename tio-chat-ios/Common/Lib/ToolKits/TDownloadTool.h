//
//  TDownloadTool.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDownloadTool : NSObject

+ (void)t_download:(NSString *)url name:(NSString *)name ext:(NSString *)ext progress:(void(^)(CGFloat p))progress completion:(void(^)(NSError * _Nullable error , NSString * _Nullable filePath ))completion;

+ (NSString *)documentPath;

+ (BOOL)existFileDocument;

@end

NS_ASSUME_NONNULL_END
