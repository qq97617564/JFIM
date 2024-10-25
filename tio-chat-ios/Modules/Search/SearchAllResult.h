//
//  SearchAllResult.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
/// SDK
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN


/// 搜索全部分页各个分类模块的model
@interface SearchAllResult : NSObject

/// 当前分类下的数据
@property (strong, nonatomic) NSArray *childList;
/// 当前分类中应该展示的数据量
@property (assign, nonatomic) NSInteger showNumber;
/// 分类的索引顺序
@property (assign, nonatomic) NSInteger index;
/// 当前分类标题
@property (copy, nonatomic) NSString *title;
/// 当前分类的更多文案
@property (copy, nonatomic) NSString *moreTitle;
/// 当前分类中cell的identifier
@property (copy, nonatomic) NSString *identifier;

/// 更多按钮的点击状态
@property (assign, nonatomic) UIControlState controlState;

/// 不同状态时的更多按钮显示，如果不设置，以属性moreTitle设置为准, NSNumber 类型同UIControlState
@property (strong, nonatomic) NSDictionary<NSNumber *, NSString *> *stateMoreTitle;

/// 构造分类数据源
+ (instancetype)resultWithChildList:(NSArray *)childList
                         showNumber:(NSInteger)showNumber
                              index:(NSInteger)index
                              title:(NSString *)title
                          moreTitle:(NSString *)moreTitle
                         identifier:(NSString *)identifier;
 
@end

NS_ASSUME_NONNULL_END
