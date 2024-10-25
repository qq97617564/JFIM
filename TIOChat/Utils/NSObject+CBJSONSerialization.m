//
//  NSObject+GPJSONSerialization.m
//  GoldPlusGold
//
//  Created by 刘宇 on 06/07/2017.
//  Copyright © 2017 刘宇. All rights reserved.
//

#import "NSObject+CBJSONSerialization.h"

#if __has_include(<YYModel/NSObject+YYModel.h>)
#import <YYModel/NSObject+YYModel.h>
#else
#import "NSObject+YYModel.h"
#endif

@interface NSObject (GPJSONSerializationPrivate)<YYModel>

@end

@implementation NSObject (CBJSONSerialization)

- (NSDictionary *)JSONObject
{
    return [self yy_modelToJSONObject];
}

+ (instancetype)objectWithJSONObject:(NSDictionary *)JSONObject
{
    return [self yy_modelWithDictionary:JSONObject];
}

+ (NSArray *)objectArrayWithJSONArray:(NSArray<NSDictionary *> *)JSONArray
{
    return [NSArray yy_modelArrayWithClass:self json:JSONArray];
}

- (void)setValuesForKeysWithJSONObject:(NSDictionary *)JSONObject
{
    [self yy_modelSetWithDictionary:JSONObject];
}

+ (NSDictionary<NSString *,Class> *)JSONArrayClassMapping
{
    return nil;
}

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return nil;
}

+ (NSArray<NSString *> *)JSONPropertyBlackList
{
    return nil;
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass;
{
    return [self JSONArrayClassMapping];
}

+ (NSDictionary<NSString *, NSString *> *)modelCustomPropertyMapper
{
    return [self JSONKeyPropertyMapping];
}

+ (NSArray<NSString *> *)modelPropertyBlacklist
{
    return [self JSONPropertyBlackList];
}

- (BOOL)modelPropertiesTransformFromDictionary:(NSDictionary *)dic
{
    return YES;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    return [self modelPropertiesTransformFromDictionary:dic];
}

- (void)modelEncodeWithCoder:(NSCoder *)aCoder
{
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)modelInitWithCoder:(NSCoder *)aDecoder
{
    return [self yy_modelInitWithCoder:aDecoder];
}

- (id)modelCopy
{
    return [self yy_modelCopy];
}

@end
