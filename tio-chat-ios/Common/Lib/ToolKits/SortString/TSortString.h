//
//  TSortString.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** * 获取model数组 */
UIKIT_EXTERN NSString *const CYPinyinGroupResultArray;

/** * 获取所包函字母的数组 */
UIKIT_EXTERN NSString *const CYPinyinGroupCharArray;

@interface TSortString : NSObject

///大写首字母
@property (strong, nonatomic) NSString     *initial;

///最原始的字符串
@property (strong, nonatomic) NSString     *string;

///转化得到的大写英文字符串
@property (strong, nonatomic) NSString     *englishString;

///model类型
@property (strong, nonatomic) NSObject     *model;

+ (NSMutableDictionary *)sortAndGroupForArray:(NSArray *)ary PropertyName:(NSString *)name nextPropertyName:(nullable NSString *)nextName;
+ (void)sortAndGroupForArray:(NSArray *)ary PropertyName:(NSString *)name nextPropertyName:(nullable NSString *)nextName callback:(void(^)(NSMutableDictionary *sortDic))callback;

+ (NSMutableArray *)sortForStringAry:(NSArray *)ary;

+ (NSMutableArray *)getAllValuesFromDict:(NSDictionary *)dict;



+ (void)sortObjectsAccordingToInitialWith:(NSArray *)willSortArr SortKey:(NSString *)sortkey subSortKey:(NSString *)subSortKey callback:(void(^)(NSDictionary *sortDic))callback;

@end

NS_ASSUME_NONNULL_END
