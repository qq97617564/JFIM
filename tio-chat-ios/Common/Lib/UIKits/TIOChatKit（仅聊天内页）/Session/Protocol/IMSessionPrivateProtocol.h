//
//  IMSessionPrivateProtocol.h
//  CawBar
//
//  Created by admin on 2019/11/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IMKitMessageModel;
@class TIOMessage;

@interface IMSessionMessageOperateResult : NSObject

@property (nonatomic,copy) NSArray *indexpaths;

@property (nonatomic,copy) NSArray *messageModels;

@end

@protocol IMSessionDataSource <NSObject>

/// tableview 的数据源
- (NSArray *)items;

/// 插入消息
/// @param models 要插入的消息数组
- (IMSessionMessageOperateResult *)insertMessageModels:(NSArray *)models;

/// 追加消息（非插入消息，日后会优化增加插入消息功能）
/// @param models 要追加的消息数组
- (IMSessionMessageOperateResult *)addMessageModels:(NSArray *)models;

- (IMSessionMessageOperateResult *)deleteMessageModel:(IMKitMessageModel *)model;

- (IMSessionMessageOperateResult *)updateMessageModel:(IMKitMessageModel *)model;

/// 查找消息的IMMessageModel
- (IMKitMessageModel *)findModel:(TIOMessage *)message;

/// 查找model的位置
- (NSInteger)indexAtModelArray:(IMKitMessageModel *)model;

/// 删除指定范围内的消息
- (NSArray *)deleteModels:(NSRange)range;

/// 重置消息
- (void)resetMessages:(void(^)(NSError *error))handler;

/// 加载历史消息
/// @param handler 外部获取的历史消息，可以通过短连接获取
- (void)loadHistoryMessagesWithComplete:(void(^)(NSInteger index, NSArray *messages , NSError *error))handler;

/// 加载新的的历史消息 （场景：从某条消息开始到最新时间，期间丢失的消息）
- (void)loadNewMessagesWithComplete:(void(^)(NSInteger index, NSArray *messages , NSError *error))handler;

/// 清除缓存
- (void)cleanCache;

@end

@protocol IMSessionLayoutDelegate <NSObject>

- (void)onRefresh;

@end

@protocol IMSessionLayout <NSObject>

- (NSInteger)numberOfRows;

- (void)update:(NSIndexPath *)indexPath;

- (void)insert:(NSArray *)indexPaths animated:(BOOL)animated;

- (void)remove:(NSArray *)indexPaths;

- (BOOL)canInsertChatroomMessages;

- (void)calculateContent:(IMKitMessageModel *)model;

- (void)reloadTable;

- (void)resetLayout;

- (void)changeLayout:(CGFloat)inputViewHeight;

- (void)layoutAfterRefresh;

- (void)adjustOffset:(NSInteger)row;

- (void)setDelegate:(id<IMSessionLayoutDelegate>)delegate;

/// 是否可以自动滚动到底部 
@property (assign,  nonatomic) BOOL canAutoScrollToBottom;
- (void)scrollToBottom:(BOOL)animated; // 滚动到最下面一行 最新消息处
@property (assign,  nonatomic) BOOL isRefresh;// 是否下拉刷新

@end

NS_ASSUME_NONNULL_END
