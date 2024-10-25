//
//  IMSessionInteractor.m
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import "IMKitSessionInteractorImpl.h"
#import "IMKitSessionLayoutImpl.h"
#import "TIOChatKit.h"
#import "TMessageMaker.h"

#import "TIOKitDependency.h"

static const void * const IMDispatchMessageDataPrepareSpecificKey = &IMDispatchMessageDataPrepareSpecificKey;
dispatch_queue_t IMMessageDataPrepareQueue(void)
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        queue = dispatch_queue_create("tio.message.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(queue, IMDispatchMessageDataPrepareSpecificKey, (void *)IMDispatchMessageDataPrepareSpecificKey, NULL);
    });
    return queue;
}

@interface IMKitSessionInteractorImpl ()
{
    NSInteger   _bottomNewMessagesCount; // 记录底部未读消息数
}
/// 向UI插入新消息cell前的消息缓冲池，用于限制最大消息数量
@property (nonatomic, strong) NSMutableArray *pendingChatModels;
@property (nonatomic, strong) id<IMSessionConfig> sessionConfig;
@property (nonatomic, strong) TIOSession *session;
@end

@implementation IMKitSessionInteractorImpl
@synthesize scrollToBottomStatus = _scrollToBottomStatus;
- (void)dealloc
{
    NSLog(@"dealloc %@",NSStringFromClass(self.class));
}

- (instancetype)initWithSession:(TIOSession *)session sessionConfig:(nonnull id<IMSessionConfig>)sessionConfig
{
    self = [super init];
    
    if (self) {
        _sessionConfig = sessionConfig;
        _session = session;
    }
    
    return self;
}

#pragma mark - 网络接口
- (void)sendMessage:(TIOMessage *)message
{
}

- (void)sendMessage:(TIOMessage *)message completion:(void (^)(NSError * _Nonnull))completion
{
    
}

#pragma mark - 界面操作接口

- (void)insertMessages:(NSArray *)messages callback:(void (^ _Nullable)(id _Nonnull))callback
{
    // 默认所有的消息均不显示
    BOOL flag = NO;
    
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (TIOMessage *message in messages) {
        // 单通道为1 切sigleuid不是自己时 不显示
        if (message.sigleflag == 1 && ![message.sigleuid isEqualToString:_session.ownerId]) {
            continue;
        }
        
        if (!flag) {
            flag = YES;
        }
        
        IMKitMessageModel *model = [[IMKitMessageModel alloc] initWithMessage:message];
        [models addObject:model];
    }
    IMSessionMessageOperateResult *result = [self.dataSource insertMessageModels:models];
    [self.layout insert:result.indexpaths animated:YES];
    
    if (callback) {
        callback(@(flag));
    }
}

- (void)addMessages:(NSArray *)messages
{
    TIOMessage * message = messages.firstObject;
    if (message.session.sessionType == TIOSessionTypeTeam) {
        [self addChatroomMessages:messages];
    }else{
//        [self addNormalMessages:messages];
        [self addChatroomMessages:messages];
    }
}

- (IMKitMessageModel *)deleteMessage:(TIOMessage *)message
{
    IMKitMessageModel *model = [self findMessageModel:message];
    if (model) {
        IMSessionMessageOperateResult *result = [self.dataSource deleteMessageModel:model];
        [self.layout remove:result.indexpaths];
    }
    return model;
}

- (IMKitMessageModel *)updateMessage:(TIOMessage *)message
{
    if (!message)
    {
        return nil;
    }
    
    IMKitMessageModel *model = [self findMessageModel:message];
    if (model)
    {
        IMSessionMessageOperateResult *result = [self.dataSource updateMessageModel:model];
        NSInteger index = [result.indexpaths.firstObject row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self safelyReloadRowAtIndexPath:indexPath];
    }
    return model;
}

- (void)clearAllMessages
{
    // 数据源先删除
    [self.dataSource resetMessages:^(NSError * _Nonnull error) {
        
    }];
    // 重新排版
    [self.layout layoutAfterRefresh];
}

#pragma mark - 数据接口
- (NSArray *)items
{
    return self.dataSource.items;
}

- (void)markRead
{
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:IMKitMessageModel.class]) {
            IMKitMessageModel *model = obj;
            model.message.isReaded = YES;
        }
    }];
    
    [self.layout reloadTable];
}

- (IMKitMessageModel *)findMessageModel:(TIOMessage *)message
{
    return [self.dataSource findModel:message];
}

- (void)resetMessages:(void (^)(NSError *error))handler
{
    __weak typeof(self) weakSelf = self;
    [self.dataSource resetMessages:^(NSError * _Nonnull error) {
        if([weakSelf.delegate respondsToSelector:@selector(didFetchMessageData)])
        {
            [weakSelf.delegate didFetchMessageData];
            if (handler) {
                handler(error);
            }
        }
    }];
}

- (void)loadMessages:(void (^)(NSArray *messages, NSError *error))handler
{
    [self.dataSource loadHistoryMessagesWithComplete:^(NSInteger index, NSArray *messages, NSError *error) {
        if (handler) {
            handler(messages,error);
        }
    }];
}

- (void)loadNewMessages:(void (^)(NSArray * _Nonnull, NSError * _Nonnull))handler
{
    [self.dataSource loadNewMessagesWithComplete:^(NSInteger index, NSArray * _Nonnull messages, NSError * _Nonnull error) {
        
        if (handler) {
            handler(messages, error);
        }
    }];
}

- (NSInteger)findMessageIndex:(TIOMessage *)message
{
    if ([message isKindOfClass:TIOMessage.class]) {
        IMKitMessageModel *model = [[IMKitMessageModel alloc] initWithMessage:message];
        return [self.dataSource indexAtModelArray:model];
    }
    return -1;
}

#pragma mark - 排版接口
- (void)resetLayout
{
    [self.layout resetLayout];
}

- (void)changeLayout:(CGFloat)inputHeight
{
    [self.layout changeLayout:inputHeight];
}

- (void)cleanCache
{
    [self.dataSource cleanCache];
}

- (void)pullUp
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPullUpMessageData)]) {
        [self.delegate didPullUpMessageData];
    }
}

- (void)scrollToBottom:(BOOL)animated
{
    [self.layout scrollToBottom:animated];
}

#pragma mark - 页面状态同步接口
- (void)onViewWillAppear
{
    //fix bug: 竖屏进入会话界面，然后右上角进入群信息，再横屏，左上角返回，横屏的会话界面显示的就是竖屏时的大小
    [self cleanCache];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.layout reloadTable];
    });
}

- (void)onViewDidDisappear
{
    
}

- (void)onApplicationDidEnterBack
{
    
}

- (void)onApplicationDidBecomeActive
{
    [self loadNewMessages:^(NSArray * _Nonnull messages, NSError * _Nonnull error) {
        for (TIOMessage *message in messages) {
            if (message.messageType == TIOMessageTypeVideoChat || message.messageType == TIOMessageTypeAudioChat) {
                message.text = [TMessageMaker videoChatMessageFor:message];
            }
        }
        [self addMessages:messages];
    }];
}

- (void)sendMessageReceipt:(nonnull NSArray *)messages {
    
}

- (void)setScrollToBottomStatus:(NSInteger)scrollToBottomStatus
{
    _scrollToBottomStatus = scrollToBottomStatus;
    
    if (scrollToBottomStatus == 1) {
        // 已经滑动至底部
        self.layout.canAutoScrollToBottom = YES; // 对layout标记，当layout insert新消息滚动时使用
        _bottomNewMessagesCount = 0; // 清空底部未读新消息数目
        if (@protocol(IMKitSessionInteractor) && [self.delegate respondsToSelector:@selector(didReadBottomMessage)]) {
            [self.delegate didReadBottomMessage];
        }
    } else if (scrollToBottomStatus == 2) {
        // 未滑动到底部
        self.layout.canAutoScrollToBottom = NO;
    }
}

#pragma mark - IMSessionLayoutDelegate

- (void)onRefresh
{
    CBWeakSelf
    [self loadMessages:^(NSArray * _Nonnull messages, NSError * _Nonnull error) {
        CBStrongSelfElseReturn
        [self.layout layoutAfterRefresh];
        self.layout.isRefresh = YES;
        if (messages.count) {
            [self insertMessages:messages callback:nil];
        }
    }];
}

#pragma mark - Private

- (void)addNormalMessages:(NSArray *)messages
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (TIOMessage * message in messages) {
        IMKitMessageModel *model = [[IMKitMessageModel alloc] initWithMessage:message];
        [models addObject:model];
    }
    IMSessionMessageOperateResult *result = [self.dataSource addMessageModels:models];
    [self.layout insert:result.indexpaths animated:YES];
}

- (void)addChatroomMessages:(NSArray *)messages
{
    if (!self.pendingChatModels) {
        self.pendingChatModels = [[NSMutableArray alloc] init];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(IMMessageDataPrepareQueue(), ^{
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (TIOMessage * message in messages)
        {
            if (message.sigleflag == 1 && ![message.sigleuid isEqualToString:self->_session.ownerId]) {
                continue;
            }
            
            if (message.whereflag == 1) {
                if (![[message.whereuid componentsSeparatedByString:@","] containsObject:self->_session.ownerId]) {
                    continue;
                }
            }
            
            // 底部消息是不是自己的
            if ([message.fromUId isEqualToString:self->_session.ownerId]) {
                self->_bottomNewMessagesCount = 0;
                self.layout.canAutoScrollToBottom = YES;
            }
            
            
            IMKitMessageModel *model = [[IMKitMessageModel alloc] initWithMessage:message];
            [weakSelf.layout calculateContent:model];
            [models addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.pendingChatModels addObjectsFromArray:models];
            [weakSelf processChatroomMessageModels];
        });
    });
}

- (void)processChatroomMessageModels
{
    NSInteger pendingMessageCount = self.pendingChatModels.count;
    if (pendingMessageCount == 0) {
        return;
    }
    if ([self.layout canInsertChatroomMessages])
    {
        static NSInteger NTESMaxInsert = 2;
        NSArray *insert = nil;
        NSRange range;
        if (pendingMessageCount > NTESMaxInsert)
        {
            range = NSMakeRange(0, NTESMaxInsert);
        }
        else
        {
            range = NSMakeRange(0, pendingMessageCount);
        }
        insert = [self.pendingChatModels subarrayWithRange:range];
        [self.pendingChatModels removeObjectsInRange:range];
        NSUInteger leftPendingMessageCount = self.pendingChatModels.count;
        BOOL animated = leftPendingMessageCount== 0;
        IMSessionMessageOperateResult *result = [self.dataSource addMessageModels:insert];
        [self.layout insert:result.indexpaths animated:animated];
        
        //群聊消息最大保存消息量，超过这个消息量则把消息列表的前一半挪出内存。
        NSInteger count = self.dataSource.items.count;
        if (count > TIOChatKit.shareSDK.config.limitMessageCount) {
            NSRange deleteRange = NSMakeRange(0, count/2);
            NSArray *delete = [self.dataSource deleteModels:deleteRange];
            [self.layout remove:delete];
        }
        
        // 底部新消息处理
        if (self.sessionConfig.canTipBottomNewMessages) {
            if (!self.layout.canAutoScrollToBottom) {
                _bottomNewMessagesCount++;
                [self.delegate didRecievedBottomNewMessage:_bottomNewMessagesCount];
            }
        }
        
        [self processChatroomMessageModels];
    }
    else
    {
        //不能插入是为了保证界面流畅，比如滑动，此时暂停处理
        __weak typeof(self) weakSelf = self;
        NSTimeInterval delay = 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf processChatroomMessageModels];
        });
    }
}

- (void)safelyReloadRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource.items.count != [self.layout numberOfRows]) {
        NSLog(@"Error: trying to reload message while cell count: %zd is not equal to item count %zd.", [self.layout numberOfRows], self.dataSource.items.count);
        return;
    }
    [self.layout update:indexPath];
}

//个人    https://url?uid=XXX
//群      https://url?g=XXX

@end
