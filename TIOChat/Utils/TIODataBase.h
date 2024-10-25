//
//  TIODataBase.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/21.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIODataBase : NSObject

+ (instancetype)shareInstance;

+ (BOOL)createDataBase;

+ (BOOL)createTable:(NSString *)table;

+ (BOOL)existTable:(NSString *)table;

+ (BOOL)existColumn:(NSString *)column inTable:(NSString *)table;

@end

NS_ASSUME_NONNULL_END
