//
//  TIOSessionViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/27.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOSessionViewController.h"
#import "IMKitTitleView.h"
#import "IMKitLeftBarView.h"
#import "IMKitSessionTableAdapter.h"
#import "IMKitInputViewImpl.h"
#import "TIOGlobalMacro.h"
#import "IMKitEvent.h"
#import "IMKitTableView.h"
#import "TMessageMaker.h"

#import "TIOKitDependency.h"

@interface TIOSessionViewController () <IMKitInputViewDelegate>
@property (nonatomic, strong)   IMKitTitleView *titleView;
@property (nonatomic, strong)   UILabel *titleLabel;
@property (nonatomic, strong)   UILabel *subTitleLabel;
@property (nonatomic, strong)   UIImageView *backgroundImageView;

@property (nonatomic, strong)   IMKitSessionConfigurator *configurator;
@property (nonatomic, weak)     id<IMKitSessionInteractor> interactor;
@end

@implementation TIOSessionViewController

- (instancetype)initWithSession:(TIOSession *)session
{
    self = [super init];
    
    if (self) {
        self.session = session;
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc %@",NSStringFromClass(self.class));
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTableView];
    [self setupInputView];
    // 导航栏
    [self setUpTitleView];
    [self setupNav];
//    [self setupConfigurator];
    // 将导航条提到最上层，否则会被tableview遮盖
    [self.view bringSubviewToFront:self.navigationBar];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appDidEnterBack)
                                               name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appWillResignActive)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appWillEnterForeground)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
}

- (void)setupNav
{
    IMKitTitleView *titleView = (IMKitTitleView *)self.navigationItem.titleView;
    if (!titleView || ![titleView isKindOfClass:[IMKitTitleView class]])
    {
        titleView = [[IMKitTitleView alloc] initWithFrame:CGRectZero];
        titleView.translatesAutoresizingMaskIntoConstraints = NO;
        self.navigationItem.titleView = titleView;
        
        titleView.titleLabel.text = self.sessionTitle;
        titleView.subtitleLabel.text = self.sessionSubTitle;
        
        self.titleLabel    = titleView.titleLabel;
        self.subTitleLabel = titleView.subtitleLabel;
        self.titleView = titleView;
    }
    
    [titleView sizeToFit];
}

- (void)setupTableView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, self.view.width, self.view.height - self.titleView.bottom) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    if (self.sessionBackgroundColor) {
        self.tableView.backgroundColor = self.sessionBackgroundColor;
    }
    if (self.sessionBackgroundImage) {
        self.backgroundImageView = [UIImageView.alloc initWithFrame:self.tableView.bounds];
        self.backgroundImageView.image = self.sessionBackgroundImage;
        [self.tableView.backgroundView addSubview:self.backgroundImageView];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.tableView.contentInsetTop = IM_Height_NavBar;
    [self.view addSubview:self.tableView];
}

- (void)setupInputView
{
    self.sessionInputView = [IMKitInputViewImpl.alloc initWithFrame:CGRectMake(0, 0, self.view.width, 56) config:self.sessionConfig];
    self.sessionInputView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.sessionInputView setActionDelegate:self];
    [self.sessionInputView setDelegate:self];
    [self.view addSubview:self.sessionInputView.view];
}

- (void)setupConfigurator
{
    _configurator = [IMKitSessionConfigurator.alloc init];
    [_configurator setup:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.interactor onViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
    [_sessionInputView endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.interactor onViewDidDisappear];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.interactor resetLayout];
    [self setupNav];
}

#pragma mark - 监听

/// APP 已经进入后台
- (void)appDidEnterBack
{
    [self.interactor onApplicationDidEnterBack];
}

/// APP 将要挂起
- (void)appWillResignActive
{
    
}

/// APP 将要恢复前台
- (void)appWillEnterForeground
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 返回前台活跃状态后 刷新数据
        [self.interactor onApplicationDidBecomeActive];
    });
}

#pragma mark - 会话title
- (NSString *)sessionTitle
{
    NSString *title = @"";
    TIOSessionType type = self.session.sessionType;
    switch (type) {
        case TIOSessionTypeTeam:{
            title = self.session.name;
        }
            break;
        case TIOSessionTypeP2P:{
            title = self.session.name;
        }
            break;
        case TIOSessionTypeSuperTeam: {
            title = @"超大群";
        }
        default:
            break;
    }
    return title;
}

- (NSString *)sessionSubTitle{return @"";};

- (id<IMSessionConfig>)sessionConfig
{
    return nil;
}

#pragma mark - 消息接口

- (void)sendMessage:(id)message
{
    
}

- (void)sendMessage:(id)message completion:(void (^)(NSError * _Nonnull))completion
{
    
}

#pragma mark - 操作接口

- (void)uiAddMessages:(NSArray *)messages
{
    // 向下追加新消息，过滤替换音视频显示文案
    for (TIOMessage *message in messages) {
        if (message.messageType == TIOMessageTypeVideoChat || message.messageType == TIOMessageTypeAudioChat) {
            message.text = [TMessageMaker videoChatMessageFor:message];
        }
    }
    [self.interactor addMessages:messages];
}

- (void)uiInsertMessages:(NSArray *)messages callback:(void (^ _Nullable)(id _Nonnull))callback
{
    // 向上加载历史消息，过滤替换音视频显示文案
    for (TIOMessage *message in messages) {
        if (message.messageType == TIOMessageTypeVideoChat || message.messageType == TIOMessageTypeAudioChat) {
            message.text = [TMessageMaker videoChatMessageFor:message];
        }
    }
    [self.interactor insertMessages:messages callback:callback];
}

- (IMKitMessageModel *)uiDeleteMessage:(TIOMessage *)message
{
    return [self.interactor deleteMessage:message];
}

- (IMKitMessageModel *)uiUpdateMessage:(TIOMessage *)message
{
    return [self.interactor updateMessage:message];
}

- (void)uiClearAllMessages
{
    [self.interactor clearAllMessages];
}

#pragma mark - 排版

- (void)scrollToBottom:(BOOL)animated
{
    [self.interactor scrollToBottom:animated];
}

#pragma mark - IMKitInputViewActionDelegate

- (void)onTextChanged:(id)sender {}

- (void)onSendText:(NSString *)text
           atUsers:(NSArray *)atUsers
{}

- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId
{}

- (void)onCancelRecording {}

- (void)onStopRecording {}

- (void)onStartRecording {}

- (void)onTapMoreBtn:(id)sender {}

- (void)onTapEmoticonBtn:(id)sender{}

- (void)onTapVoiceBtn:(id)sender {}

- (void)onTapMoreItem:(nonnull IMKitInputMoreItem *)moreItem {}


#pragma mark - IMKitInputViewDelegate

- (void)didChangeInputHeight:(CGFloat)inputHeight
{
    [self.interactor changeLayout:inputHeight];
}

- (void)recordBeginTouch
{
    // 调用SDK开始录音API
}

- (void)recordFinishInButton
{
    // 调用SDK结束录音API
}

- (void)recordDragToOut
{
    // UI显示松开取消的提示
}

- (void)recordDragBackToButton
{
    // 关闭松开取消提示 继续显示录音计时弹窗
}

- (void)recordFinishOutButton
{
    // 调用SDK取消录音API
}

#pragma mark - IMKitSessionInteractorDelegate

- (void)didPullUpMessageData {}

- (void)didFetchMessageData {}

- (void)didRefreshMessageData {}


#pragma mark - IMMessageCellDelegate

- (BOOL)onTapCell:(IMKitEvent *)event
{
    NSLog(@"点击了消息:%@",event.messageModel.message.text);
    return YES;
}

- (BOOL)onLongPressCell:(TIOMessage *)message inView:(UIView *)view
{
    BOOL handle = NO;
    NSArray *items = [self menusItems:message];
    if ([items count] ) {
        UIMenuController *controller = [UIMenuController sharedMenuController];
        controller.menuItems = items;
        _messageForMenu = message;
        [controller setTargetRect:view.bounds inView:view];
        [controller setMenuVisible:YES animated:YES];
        handle = YES;
    }
    return handle;
}

- (BOOL)onTapAvatar:(TIOMessage *)message
{
    NSLog(@"点击了的%@头像",message.from);
    return YES;
}

- (BOOL)onLongPressAvatar:(TIOMessage *)message
{
    return YES;
}

- (void)onRetryMessage:(TIOMessage *)message
{
    
}

#pragma mark - Private

- (void)setUpTitleView
{
    [self.titleView sizeToFit];
}

- (void)refreshSessionTitle:(NSString *)title
{
    self.titleView.titleLabel.text = title;
    [self setUpTitleView];
}


- (void)refreshSessionSubTitle:(NSString *)title
{
    self.subTitleLabel.text = title;
    [self setUpTitleView];
}

- (void)refreshMessages {
    [self.interactor resetMessages:^(NSError * _Nonnull error) {
        
    }];
}

- (void)loadNewMessgaes
{
    // 返回前台活跃状态后 刷新数据
    [self.interactor onApplicationDidBecomeActive];
}

- (void)markRead
{
    [self.interactor markRead];
}

- (void)changeLeftBarBadge:(NSInteger)unreadCount
{
    IMKitLeftBarView *leftBarView = (IMKitLeftBarView *)self.navigationItem.leftBarButtonItem.customView;
    leftBarView.badgeView.badgeValue = @(unreadCount).stringValue;
    leftBarView.badgeView.hidden = !unreadCount;
}

#pragma mark - 气泡长按的菜单选项

- (NSArray *)menusItems:(TIOMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    
    BOOL copyText = NO;
    
    if (message.messageType == TIOMessageTypeText)
    {
        copyText = YES;
    }
    
    if (copyText) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                    action:@selector(copyText:)]];
    }
    
    return items;
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSArray *items = [[UIMenuController sharedMenuController] menuItems];
    for (UIMenuItem *item in items) {
        if (action == [item action]){
            return YES;
        }
    }
    return NO;
}

- (void)copyText:(id)sender
{
    TIOMessage * message = [self messageForMenu];
    if (message.text.length) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:message.text];
    }
}

- (void)deleteMsg:(id)sender
{
    
}

- (void)revokeMsg:(id)sender
{
    
}

- (void)reportMsg:(id)sender
{
    
}

- (void)multiSelectMsgs:(id)sender
{
    
}

#pragma mark - 手势

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_sessionInputView endEditing:YES];
}

@end

