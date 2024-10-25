//
//  ThirdResponse.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/29.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThirdConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThirdResponse : NSObject
@property (nonatomic, copy) NSString  *uid;
@property (nonatomic, copy) NSString  *openid;
@property (nonatomic, copy) NSString  *accessToken;
@property (nonatomic, copy) NSString  *unionId;

@property (nonatomic, assign) ThirdPlatform  platformType;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *gender;

/**
 * 第三方原始数据
 */
@property (nonatomic, strong) id  originalResponse;

/**
 6.5版版本新加入的扩展字段
 */
@property (nonatomic, strong)NSDictionary* extDic;//每个平台特有的字段有可能会加在此处，有可能为nil
@end

NS_ASSUME_NONNULL_END
