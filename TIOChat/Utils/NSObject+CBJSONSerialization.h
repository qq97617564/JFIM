//
//  NSObject+GPJSONSerialization.h
//  GoldPlusGold
//
//  Created by 刘宇 on 06/07/2017.
//  Copyright © 2017 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CBJSONSerialization)

/**
 转换为JSON对象
 */
@property (strong, nonatomic, readonly) NSDictionary *JSONObject;

/**
 将JSON对象转换为模型对象

 @param JSONObject JSON对象
 @return 模型对象
 */
+ (instancetype)objectWithJSONObject:(NSDictionary *)JSONObject;

/**
 根据JSON对象重新赋值
 
 @param JSONObject JSON对象
 */
- (void)setValuesForKeysWithJSONObject:(NSDictionary *)JSONObject;

/**
 将JSON数组转换为模型数组

 @param JSONArray JSON数组
 @return 模型数组
 */
+ (NSArray *)objectArrayWithJSONArray:(NSArray<NSDictionary *> *)JSONArray;

/**
 JSON数组泛型类映射
 
 @return JSON数组泛型类映射字典
 */
+ (nullable NSDictionary<NSString *, Class> *)JSONArrayClassMapping;

/**
 JSON属性名与模型属性名称映射

 @return JSON属性名与模型属性名称映射字典
 */
+ (nullable NSDictionary<NSString *, NSString *> *)JSONKeyPropertyMapping;

/**
 JSON解析黑名单
 
 @return JSON解析黑名单
 */
+ (nullable NSArray<NSString *> *)JSONPropertyBlackList;

- (BOOL)modelPropertiesTransformFromDictionary:(NSDictionary *)dic;

- (void)modelEncodeWithCoder:(NSCoder *)aCoder;
- (id)modelInitWithCoder:(NSCoder *)aDecoder;
- (id)modelCopy;

@end

NS_ASSUME_NONNULL_END
