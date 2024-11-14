//
//  IMSessionLayoutImpl.m
//  CawBar
//
//  Created by admin on 2019/11/12.
//

#import "IMKitSessionLayoutImpl.h"
#import "TIOChatKit.h"
#import "TIOGlobalMacro.h"
#import "IMKitMessageModel.h"
#import "IMKitMesssageCell.h"
#import "IMKitKeyInfo.h"
#import "UITableView+CBIMScrollToBottom.h"
#import "TIOKitDependency.h"
#import "IMSessionConfig.h"

@interface IMKitSessionLayoutImpl ()
{
    NSMutableArray *_inserts;
    CGFloat _inputViewHeight;
}

@property (nonatomic,strong)  UIRefreshControl *refreshControl;
@property (nonatomic, strong) TIOSession *session;
@property (nonatomic, weak) id<IMSessionLayoutDelegate> delegate;
@property (nonatomic, strong) id<IMSessionConfig> sessionConfig;

@end

@implementation IMKitSessionLayoutImpl

@synthesize canAutoScrollToBottom;
@synthesize isRefresh;

- (void)dealloc
{
    NSLog(@"dealloc %@",NSStringFromClass(self.class));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithSession:(TIOSession *)session sessionConfig:(nonnull id)sessionConfig
{
    self = [super init];
    
    if (self) {
        _sessionConfig = sessionConfig;
        
        self.canAutoScrollToBottom = YES; // 默认初始化是可以自动滚动到底部
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:IMKitKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView
{
    BOOL change = _tableView != tableView;
    
    if (change) {
        _tableView = tableView;
        [self setupRefreshControl];
    }
}

#pragma mark - IMSessionLayout

- (NSInteger)numberOfRows
{
    return [self.tableView numberOfRowsInSection:0];
}

- (void)reloadTable
{
    [self.tableView reloadData];
}

- (void)resetLayout
{
    [self adjustInputView];
    [self adjustTableView];
}

- (void)adjustOffset:(NSInteger)row {
    
}

- (void)calculateContent:(nonnull IMKitMessageModel *)model {
    IMKit_Dispatch_Sync_Main(^{
        [model contentSize:self.tableView.width];
    });
}

- (BOOL)canInsertChatroomMessages {
    return !self.tableView.isDecelerating && !self.tableView.isDragging;
}

- (void)changeLayout:(CGFloat)inputViewHeight {
    BOOL change = _inputViewHeight != inputViewHeight;
    if (change)
    {
        _inputViewHeight = inputViewHeight;
        [self adjustInputView];
        [self adjustTableView];
    }
}

- (void)insert:(nonnull NSArray *)indexPaths animated:(BOOL)animated {
    if (!indexPaths.count)
    {
        return;
    }

    NSMutableArray *addIndexPathes = [NSMutableArray array];
    [indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[obj integerValue] inSection:0];
        [addIndexPathes addObject:indexPath];
    }];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:addIndexPathes withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView reloadData];
    [self.tableView endUpdates];
    
    if (self.sessionConfig.canTipBottomNewMessages) {
        // 需要进一步检测当前是否已经滑动到底部

        if (self.canAutoScrollToBottom) {
            [UIView animateWithDuration:0.2 animations:^{
                [self.tableView scrollToRowAtIndexPath:addIndexPathes.lastObject atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }];
        } else {
            if (self.isRefresh) {
                self.isRefresh = NO;

                NSIndexPath *locationToIndexpath = addIndexPathes.lastObject;
                [self.tableView scrollToRowAtIndexPath:locationToIndexpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
    } else {
        [self.tableView scrollToRowAtIndexPath:addIndexPathes.lastObject atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}


- (void)layoutAfterRefresh {
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
}


- (void)remove:(nonnull NSArray *)indexPaths {
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    NSInteger row = [self.tableView numberOfRowsInSection:0] - 1;
    if (row > 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


- (void)update:(nonnull NSIndexPath *)indexPath {
    IMKitMesssageCell *cell = (IMKitMesssageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        CGFloat scrollOffsetY = self.tableView.contentOffset.y;
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, scrollOffsetY) animated:NO];
    }
}


- (void)adjustInputView
{
    UIView *superView = self.inputView.view.superview;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *))
    {
        safeAreaInsets = superView.safeAreaInsets;
    }
    self.inputView.view.bottom = superView.height - safeAreaInsets.bottom;
}

- (void)adjustTableView
{
    // 输入框是否弹起
    BOOL inputViewUp = NO;
    switch (self.inputView.status)
    {
        case IMInputStatusText:
            inputViewUp = [self.inputView keyboardIsVisiable];
            break;
        case IMInputStatusAudio:
            inputViewUp = NO;
            break;
        case IMInputStatusMore:
        case IMInputStatusEmoticon:
            inputViewUp = YES;
        default:
            break;
    }
    // 键盘弹起时 tableview不能响应手势：长按气泡、头像等操作
    self.tableView.userInteractionEnabled = !inputViewUp;
    CGRect rect = self.tableView.frame;
    
    //tableview 的位置
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *))
    {
        safeAreaInsets = UIEdgeInsetsMake(Height_NavBar, 0, safeBottomHeight, 0);
    }
    
    CGFloat containerSafeHeight = self.tableView.superview.frame.size.height - safeAreaInsets.bottom - safeAreaInsets.top;
    
    rect.size.height = containerSafeHeight - self.inputView.toolBar.height;
    
    
    //tableview 的内容 inset
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    CGFloat visiableHeight = 0;
    if (@available(iOS 11.0, *))
    {
        contentInsets = self.tableView.adjustedContentInset;
    }
    else
    {
        contentInsets = self.tableView.contentInset;
    }
    
    //如果气泡过少，少于总高度，输入框视图需要顶到最后一个气泡的下面。
    visiableHeight = visiableHeight + self.tableView.contentSize.height + contentInsets.top + contentInsets.bottom;
    visiableHeight = MIN(visiableHeight, rect.size.height);
    
    rect.origin.y    = containerSafeHeight - visiableHeight;
    rect.origin.y    = rect.origin.y > 0? Height_NavBar : rect.origin.y;
    
    
    BOOL tableChanged = !CGRectEqualToRect(self.tableView.frame, rect);
    if (tableChanged)
    {
        [self.tableView setFrame:rect];
        [self.tableView cb_scrollToBottom:YES];
    }
}

- (void)scrollToBottom:(BOOL)animated
{
    [self.tableView cb_scrollToBottom:animated];
}

#pragma mark - Notification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    if (!self.tableView.window)
    {
        //如果当前视图不是顶部视图，则不需要监听
        return;
    }
    [self.inputView.view sizeToFit];
}

- (void)menuDidHide:(NSNotification *)notification
{
    [UIMenuController sharedMenuController].menuItems = nil;
}

#pragma mark - Private

- (void)setupRefreshControl
{
    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing:)];
}

- (void)headerRereshing:(id)sender
{
    if (@protocol(IMSessionLayoutDelegate) && [self.delegate respondsToSelector:@selector(onRefresh)]) {
        [self.delegate onRefresh];
    }
}

@end
