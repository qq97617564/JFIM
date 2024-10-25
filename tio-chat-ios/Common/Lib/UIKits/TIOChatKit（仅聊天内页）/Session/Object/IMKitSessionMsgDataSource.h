//
//  IMSessionMsgDataSource.h
//  CawBar
//
//  Created by admin on 2019/11/13.
//

#import <Foundation/Foundation.h>
#import "IMKitSessionDataProvider.h"
#import "IMSessionConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOSession;
@class IMKitMessageModel;

/// 数据源的细分 上层是 IMSessionDataSourceImpl
@interface IMKitSessionMsgDataSource : NSObject

- (instancetype)initWithSession:(TIOSession *)session sessionConfig:(id<IMSessionConfig>)sessionConfig;

@property (nonatomic, strong) NSMutableArray    *items;

- (NSInteger)indexAtModelArray:(IMKitMessageModel *)model;

//数据对外接口
- (void)loadHistoryMessagesWithComplete:(void(^)(NSInteger index , NSArray *messages ,NSError *error))handler;
- (void)loadNewMessagesWithComplete:(void(^)(NSInteger index , NSArray *messages ,NSError *error))handler;

//添加消息，会根据时间戳插入到相应位置
- (NSArray<NSNumber *> *)insertMessageModels:(NSArray*)models;

//添加消息，直接插入消息列表末尾
- (NSArray<NSNumber *> *)appendMessageModels:(NSArray *)models;

//删除消息
- (NSArray<NSNumber *> *)deleteMessageModel:(IMKitMessageModel*)model;

//根据范围批量删除消息
- (NSArray<NSNumber *> *)deleteModels:(NSRange)range;

//复位消息
- (void)resetMessages:(void(^)(NSError *error)) handler;

//清理缓存数据
- (void)cleanCache;

@end

NS_ASSUME_NONNULL_END
