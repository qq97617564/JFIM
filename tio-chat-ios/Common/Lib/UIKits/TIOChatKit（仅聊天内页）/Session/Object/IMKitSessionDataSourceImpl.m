//
//  IMSessionDataSourceImpl.m
//  CawBar
//
//  Created by admin on 2019/11/12.
//

#import "IMKitSessionDataSourceImpl.h"
#import "TIOChatKit.h"
#import "IMKitMessageModel.h"
#import "IMKitSessionMsgDataSource.h"

@interface IMKitSessionDataSourceImpl ()

@property (strong, nonatomic) TIOSession *session;

@property (strong, nonatomic) id<IMSessionConfig> sessionConfig;

@property (strong, nonatomic) IMKitSessionMsgDataSource *dataSource;

@end

@implementation IMKitSessionDataSourceImpl

- (void)dealloc
{
    NSLog(@"dealloc %@",NSStringFromClass(self.class));
}

- (instancetype)initWithSession:(TIOSession *)session sessionConfig:(nonnull id<IMSessionConfig>)sessionConfig
{
    self = [super init];
    
    if (self) {
        _session    =   session;
        _sessionConfig = sessionConfig;
        _dataSource =   [IMKitSessionMsgDataSource.alloc initWithSession:session sessionConfig:sessionConfig];
    }
    
    return self;
}

- (NSArray *)items
{
    return self.dataSource.items;
}

- (IMSessionMessageOperateResult *)insertMessageModels:(NSArray *)models
{
    NSArray *indexpaths = [self.dataSource insertMessageModels:models];
    IMSessionMessageOperateResult *result = [[IMSessionMessageOperateResult alloc] init];
    result.indexpaths = indexpaths;
    result.messageModels = models;
    return result;
}

- (IMSessionMessageOperateResult *)addMessageModels:(NSArray *)models
{
    NSArray *indexpaths = [self.dataSource appendMessageModels:models];
    IMSessionMessageOperateResult *result = [[IMSessionMessageOperateResult alloc] init];
    result.indexpaths = indexpaths;
    result.messageModels = models;
    return result;
}

- (IMSessionMessageOperateResult *)deleteMessageModel:(IMKitMessageModel *)model
{
    NSArray *indexs = [self.dataSource deleteMessageModel:model];
    IMSessionMessageOperateResult *result = [[IMSessionMessageOperateResult alloc] init];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSNumber *index in indexs) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:0];
        [indexPaths addObject:indexPath];
    }
    result.indexpaths    = indexPaths;
    result.messageModels = @[model];
    return result;
}

- (IMSessionMessageOperateResult *)updateMessageModel:(IMKitMessageModel *)model
{
    NSInteger index = [self.dataSource indexAtModelArray:model];
    [[self.dataSource items] replaceObjectAtIndex:index withObject:model];
    IMSessionMessageOperateResult *result = [[IMSessionMessageOperateResult alloc] init];
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
    result.indexpaths = @[indexpath];
    result.messageModels = @[model];
    return result;
}

- (void)resetMessages:(void (^)(NSError * _Nonnull))handler
{
    [self.dataSource resetMessages:handler];
}

- (NSArray *)deleteModels:(NSRange)range
{
    return [self.dataSource deleteModels:range];
}

- (NSInteger)indexAtModelArray:(IMKitMessageModel *)model
{
    return [self.dataSource indexAtModelArray:model];
}

- (IMKitMessageModel *)findModel:(TIOMessage *)message
{
    IMKitMessageModel *model;
    for (IMKitMessageModel *item in self.dataSource.items.reverseObjectEnumerator.allObjects) {
        if ([item isKindOfClass:[IMKitMessageModel class]] && [item.message.messageId isEqualToString:message.messageId]) {
            model = item;
            /// 防止那种进了会话又退出去再进来这种行为
            /// 防止SDK里回调上来的message和会话持有的message不是一个，导致刷界面刷跪了的情况
            model.message = message;
        }
    }
    return model;
}

- (void)cleanCache
{
    [self.dataSource cleanCache];
}

- (void)loadHistoryMessagesWithComplete:(nonnull void (^)(NSInteger, NSArray * _Nonnull, NSError * _Nonnull))handler {
    [self.dataSource loadHistoryMessagesWithComplete:handler];
}

- (void)loadNewMessagesWithComplete:(void (^)(NSInteger, NSArray * _Nonnull, NSError * _Nonnull))handler
{
    [self.dataSource loadNewMessagesWithComplete:handler];
}

#pragma mark - Private

@end

@implementation IMSessionMessageOperateResult

@end
