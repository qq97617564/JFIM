//
//  IMSessionMsgDataSource.m
//  CawBar
//
//  Created by admin on 2019/11/13.
//

#import "IMKitSessionMsgDataSource.h"
#import "IMKitMessageModel.h"
#import "IMKitTimeModel.h"
#import "TIOGlobalMacro.h"
#import "TIOChatKit.h"
#import "TIOKitDependency.h"

@interface IMKitSessionMsgDataSource ()

@property (nonatomic, strong) TIOSession *session;
@property (nonatomic, strong) id<IMSessionConfig> sessionConfig;
@property (nonatomic, assign) id<IMKitSessionDataProvider> dataProvider;
@property (nonatomic, strong) NSMutableDictionary *msgIdDict;
@property (assign, nonatomic) NSTimeInterval messageInterval;

@end

@implementation IMKitSessionMsgDataSource

- (void)dealloc
{
    NSLog(@"dealloc %@",NSStringFromClass(self.class));
}

- (instancetype)initWithSession:(TIOSession *)session sessionConfig:(nonnull id)sessionConfig
{
    self = [super init];
    
    if (self) {
        _session = session;
        _msgIdDict = [NSMutableDictionary dictionary];
        _items     = [NSMutableArray array];
        _sessionConfig = sessionConfig;
        _dataProvider = [sessionConfig respondsToSelector:@selector(messageDataProvider)] ? [_sessionConfig messageDataProvider] : nil;
        _messageInterval = TIOChatKit.shareSDK.config.showMessageTimeInterval;
    }
    
    return self;
}

- (void)cleanCache
{
    for (id item in self.items)
    {
        if ([item isKindOfClass:[IMKitMessageModel class]])
        {
            IMKitMessageModel *model = (IMKitMessageModel *)item;
            [model cleanCache];
        }
    }
}

- (void)resetMessages:(void(^)(NSError *error)) handler
{
    self.items              = [NSMutableArray array];
    self.msgIdDict          = [NSMutableDictionary dictionary];
    
    if ([self.dataProvider respondsToSelector:@selector(pullDown:session:handler:)])
    {
        __weak typeof(self) wself = self;
        [self.dataProvider pullDown:nil session:wself.session handler:^(NSError * _Nonnull error, NSArray<TIOMessage *> * _Nonnull messages) {
            IMKit_Dispatch_Async_Main(^{
                [wself appendMessageModels:[self modelsWithMessages:messages]];
                if (handler) {
                    handler(error);
                }
            });
        }];
    }
}

- (NSArray<NSNumber *> *)insertMessageModels:(NSArray *)models
{
    if (!models.count) {
        return @[];
    }
    NSMutableArray *insert = [[NSMutableArray alloc] init];
    //由于找到插入位置后会直接插入，所以这里按时间戳大小先排个序，避免造成先插了时间大的，再插了时间小的，导致之前时间大的消息的位置还需要后移的情况.
    NSArray *sortModels = models;

    if (sortModels.count > 1) {
        IMKitMessageModel *first  = sortModels.firstObject;
        IMKitMessageModel *last  = sortModels.lastObject;
        if (first.messageTime > last.messageTime) {
            // 时间排序从最早到最新
            sortModels = models.reverseObjectEnumerator.allObjects;
        }
    }
    
//    NSArray *sortModels = [models sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        IMKitMessageModel *first  = obj1;
//        IMKitMessageModel *second = obj2;
//        return first.messageTime <= second.messageTime ? NSOrderedAscending : NSOrderedDescending;
//    }];
    
    for (IMKitMessageModel *model in sortModels) {
        if ([self modelIsExist:model]) {
            continue;
        }
        NSInteger i = [self findInsertPosistion:model];
        NSArray *result = [self insertMessageModel:model index:i];
        [insert addObjectsFromArray:result];
    }
    return insert;
}

/// 从前插入数据
/// @param messages 消息
- (NSInteger)insertMessages:(NSArray *)messages callback:(void (^ _Nullable)(id _Nonnull))callback {
    NSInteger count = self.items.count;
    for (TIOMessage *message in messages.reverseObjectEnumerator.allObjects) {
        [self insertMessage:message];
    }
    NSInteger currentIndex = self.items.count - 1;
    return currentIndex - count;
}

/**
 *  从后插入消息
 *
 *  @param models 消息集合
 *
 *  @return 插入的消息的index
 */
- (NSArray *)appendMessageModels:(NSArray *)models{
    if (!models.count) {
        return @[];
    }
    NSMutableArray *append = [[NSMutableArray alloc] init];
    for (IMKitMessageModel *model in models) {
        if ([self modelIsExist:model]) {
            continue;
        }
        NSArray *result = [self insertMessageModel:model index:self.items.count];
        [append addObjectsFromArray:result];
    }
    return append;
}

- (NSArray<NSNumber *> *)deleteMessageModel:(IMKitMessageModel *)model
{
    NSMutableArray *dels = [NSMutableArray array];
    NSInteger delTimeIndex = -1;
    NSInteger delMsgIndex = [self.items indexOfObject:model];
    // 如果删除的消息前面有“时间”显示，把“时间”也删除
    if (delMsgIndex > self.messageInterval) {
        BOOL delMsgIsSingle = (delMsgIndex == self.items.count-1 || [self.items[delMsgIndex+1] isKindOfClass:[IMKitTimeModel class]]);
        if ([self.items[delMsgIndex-1] isKindOfClass:[IMKitTimeModel class]] && delMsgIsSingle) {
            delTimeIndex = delMsgIndex-1;
            [self.items removeObjectAtIndex:delTimeIndex];
            [dels addObject:@(delTimeIndex)];
        }
    }
    if (delMsgIndex > -1) {
        [self.items removeObject:model];
        [_msgIdDict removeObjectForKey:model.message.messageId];
        [dels addObject:@(delMsgIndex)];
    }
    return dels;
}

- (NSArray<NSNumber *> *)deleteModels:(NSRange)range
{
    NSArray *models = [self.items subarrayWithRange:range];
    NSMutableArray *dels = [NSMutableArray array];
    NSMutableArray *all = [NSMutableArray arrayWithArray:self.items];
    for (IMKitMessageModel *model in models) {
        NSInteger delMsgIndex = [all indexOfObject:model];
        if (delMsgIndex > -1) {
            [self.items removeObject:model];
            [_msgIdDict removeObjectForKey:model.message.messageId];
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:delMsgIndex inSection:0];
            [dels addObject:indexpath];
        }
    }
    return dels;
}

- (NSInteger)indexAtModelArray:(IMKitMessageModel *)model
{
    __block NSInteger index = -1;
    if (![_msgIdDict objectForKey:model.message.messageId]) {
        return index;
    }
    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[IMKitMessageModel class]]) {
            if ([model isEqual:obj]) {
                index = idx;
                *stop = YES;
            }
        }
    }];
    return index;
}

#pragma mark - msg

- (BOOL)modelIsExist:(IMKitMessageModel *)model
{
    return [_msgIdDict objectForKey:model.message.messageId] != nil;
}

- (void)loadHistoryMessagesWithComplete:(void(^)(NSInteger index, NSArray *messages , NSError *error))handler
{
    __block IMKitMessageModel *currentOldestMsg = nil;
    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[IMKitMessageModel class]]) {
            currentOldestMsg = (IMKitMessageModel *)obj;
            *stop = YES;
        }
    }];
    __block NSInteger index = 0;
    
    if ([self.dataProvider respondsToSelector:@selector(pullDown:session:handler:)])
    {
        [self.dataProvider pullDown:currentOldestMsg.message session:self.session handler:^(NSError *error, NSArray *messages) {
            IMKit_Dispatch_Async_Main(^{
                if (handler) {
                    handler(index,messages,error);
                }
            });
        }];
    }
}

- (void)loadNewMessagesWithComplete:(void (^)(NSInteger, NSArray * _Nonnull, NSError * _Nonnull))handler
{
    IMKitMessageModel *currentMsg = self.items.lastObject;
    
    if ([self.dataProvider respondsToSelector:@selector(loadNew:session:handler:)]) {
        [self.dataProvider loadNew:currentMsg.message session:self.session handler:^(NSError * _Nonnull error, NSArray<TIOMessage *> * _Nonnull messages) {
            NSArray *msgs = [[messages reverseObjectEnumerator] allObjects];
            if (handler) {
                handler(0,msgs,error);
            }
        }];
    }
}

#pragma mark - Private

- (void)insertMessage:(TIOMessage *)message{
    IMKitMessageModel *model = [[IMKitMessageModel alloc] initWithMessage:message];

    if ([self modelIsExist:model]) {
        return;
    }
    
    // 会话是否开启显示间隔时间功能
    if ([self.sessionConfig shouldShowTime]) {
        NSTimeInterval firstTimeInterval = [self firstTimeInterval];
        if (firstTimeInterval && firstTimeInterval - model.messageTime < self.messageInterval) {
            //此时至少有一条消息和时间戳（如果有的话）
            //干掉时间戳（如果有的话）
            if ([self.items.firstObject isKindOfClass:[IMKitTimeModel class]]) {
                [self.items removeObjectAtIndex:0];
            }
        }
    }
    
    [self.items insertObject:model atIndex:0];
}

- (NSArray *)insertMessageModel:(IMKitMessageModel *)model index:(NSInteger)index{
    NSMutableArray *inserts = [[NSMutableArray alloc] init];
    if ([self.sessionConfig shouldShowTime]) {
        if ([self shouldInsertTimestamp:model]) {
            IMKitTimeModel *timeModel = [[IMKitTimeModel alloc] init];
            timeModel.messageTime = model.messageTime;
            [self.items insertObject:timeModel atIndex:index];
            [inserts addObject:@(index)];
            index++;
        }
    }
    [self.items insertObject:model atIndex:index];
    [self.msgIdDict setObject:model forKey:model.message.messageId];
    [inserts addObject:@(index)];
    return inserts;
}

- (NSArray<IMKitMessageModel *> *)modelsWithMessages:(NSArray<TIOMessage *> *)messages
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (TIOMessage * message in messages) {
        IMKitMessageModel *model = [[IMKitMessageModel alloc] initWithMessage:message];
        [array addObject:model];
    }
    return array;
}

- (NSInteger)findInsertPosistion:(IMKitMessageModel *)model
{
    return [self findInsertPosistion:self.items model:model];
}

- (NSInteger)findInsertPosistion:(NSArray *)array model:(IMKitMessageModel *)model
{
    if (array.count == 0) {
        //即初始什么消息都没的情况下，调用了插入消息，放在第一个就好了。
        return 0;
    }
    
    
    if (array.count == 1) {
        //递归出口
        IMKitMessageModel *obj = array.firstObject;
        NSInteger index = [self.items indexOfObject:obj];
//        NSInteger result = obj.messageTime > model.messageTime? index : index+1;
        NSInteger result= obj.message.messageId.longLongValue > model.message.messageId.longLongValue ? index : index + 1;
        return result;
    }
    NSInteger sep = (array.count+1) / 2;
    IMKitMessageModel *center = array[sep];
//    NSTimeInterval timestamp = [center messageTime];
//    NSArray *half;
//    if (timestamp <= [model messageTime]) {
//        half = [array subarrayWithRange:NSMakeRange(sep, array.count - sep)];
//    }else{
//        half = [array subarrayWithRange:NSMakeRange(0, sep)];
//    }
        long long messageId = [center.message.messageId longLongValue];
        NSArray *half;
        if (messageId <= [model.message.messageId longLongValue]) {
            half = [array subarrayWithRange:NSMakeRange(sep, array.count - sep)];
        }else{
            half = [array subarrayWithRange:NSMakeRange(0, sep)];
        }
    
    
    return [self findInsertPosistion:half model:model];
}

- (BOOL)shouldInsertTimestamp:(IMKitMessageModel *)model
{
    NSTimeInterval lastTimeInterval = [self lastTimeInterval];
    return model.messageTime - lastTimeInterval > self.messageInterval;
}

- (NSTimeInterval)firstTimeInterval
{
    if (!self.items.count) {
        return 0;
    }
    IMKitMessageModel *model;
    model = self.items[0];
    return model.messageTime;
}

- (NSTimeInterval)lastTimeInterval
{
    IMKitMessageModel *model = self.items.lastObject;
    return model.messageTime;
}

@end
