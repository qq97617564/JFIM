//
//  TFriendSettingViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/27.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TP2PSessionSettingViewController.h"
#import "TUserHomePageViewController.h"

#import "TSettingCell.h"
#import "TCommonCell.h"
#import "FrameAccessor.h"
#import "ImportSDK.h"
#import "MBProgressHUD+NJ.h"
#import "UIImageView+Web.h"
#import "TInputAlertController.h"

@interface TP2PSessionSettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong,  nonatomic) UITableView *tableView;
@property (strong,  nonatomic) NSArray<NSArray *> *cells;
@property (strong,  nonatomic) UITableViewCell *avatarCell;
@property (strong,  nonatomic) TSettingCell *msgNotificell;
@property (strong,  nonatomic) TSettingCell *msgTopCell;
@property (strong,  nonatomic) TCommonCell *clearCell;
@property (strong,  nonatomic) TCommonCell *tipoffCell;
@property (weak,    nonatomic) UIImageView *avatar;
@end

@implementation TP2PSessionSettingViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"聊天信息";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self requestData];
}

- (void)setupUI
{
    self.avatarCell     = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    self.msgNotificell  = [TSettingCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.msgNotificell.textLabel.text = @"消息免打扰";
    CBWeakSelf
    self.msgNotificell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
        CBStrongSelfElseReturn
        CBWeakSelf
        [TIOChat.shareSDK.conversationManager answerMessageNotificationForUid:self.uid orTeamid:nil flag:open?1:2 completion:^(NSError * _Nullable error, id  _Nonnull data) {
            CBStrongSelfElseReturn
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
                cell.open = !open;
            } else {
                
            }
        }];
    };
    
    self.msgTopCell     = [TSettingCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.msgTopCell.textLabel.text = @"消息置顶";
    self.msgTopCell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
        CBStrongSelfElseReturn
        CBWeakSelf
        TIOSession *session = [TIOSession session:self.sessionId toUId:self.uid type:TIOSessionTypeP2P];
        [TIOChat.shareSDK.conversationManager topSession:session isTop:open completon:^(NSError * _Nullable error) {
            CBStrongSelfElseReturn
            if (error) {
                cell.open = !open;
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
        }];
    };
    // 数据库查找免打扰、置顶状态
    [TIOChat.shareSDK.conversationManager findSession:self.sessionId complete:^(TIORecentSession * _Nullable session) {
        if (session) {
            self.msgNotificell.open = session.msgfreeflag == 1;
            self.msgTopCell.open = session.isTop;
        }
    }];
    
    
    self.clearCell      = [TCommonCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.clearCell.textLabel.text = @"清空聊天记录";
    self.clearCell.hasIndiractor = YES;
    
    self.tipoffCell     = [TCommonCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.tipoffCell.textLabel.text = @"举报用户";
    self.tipoffCell.hasIndiractor = YES;
    
    self.cells = @[@[self.avatarCell]
                   ,@[self.msgNotificell, self.msgTopCell, self.clearCell],@[self.tipoffCell]];
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorInset = UIEdgeInsetsMake(0, 17, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.friendManager fetchUserInfo:self.uid completion:^(TIOUser * _Nullable users, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [self.avatarCell.contentView addSubview:({
            UIImageView *imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 60, 60)];
            imageView.left = 16;
            imageView.centerY = self.avatarCell.contentView.middleY;
            [imageView tio_imageUrl:users.avatar placeHolderImageName:@"avatar_placeholder" radius:4];
            
            imageView;
        })];
        [self.avatarCell.contentView addSubview:({
            UILabel *label = [UILabel.alloc init];
            label.text = users.remarkname.length?users.remarkname:users.nick;
            label.textColor = [UIColor colorWithHex:0x333333];
            label.font = [UIFont systemFontOfSize:16];
            [label sizeToFit];
            label.left = 87;
            label.centerY = self.avatarCell.contentView.middleY;
            if (label.width > 125) label.width = 125;
            label;
        })];
        [self.avatarCell.contentView addSubview:({
            UIImageView *imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 60, 60)];
            imageView.left = 16;
            imageView.centerY = self.avatarCell.contentView.middleY;
            [imageView tio_imageUrl:users.avatar placeHolderImageName:@"avatar_placeholder" radius:4];
            
            imageView;
        })];
        [self.avatarCell.contentView addSubview:({
            UIImageView *indiractor = [UIImageView.alloc initWithFrame:CGRectZero];
            indiractor.image = [UIImage imageNamed:@"inner"];
            [indiractor sizeToFit];
            indiractor.right = self.avatarCell.contentView.width - 16;
            indiractor.centerY = self.avatarCell.contentView.middleY;
            indiractor;
        })];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.section][indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80;
    } else {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view= [UIView.alloc init];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (selectCell == self.avatarCell) {
        [self jumpToUserhome:self.uid];
    } else if (selectCell == self.tipoffCell) {
        [self alertTiptop];
    } else if (selectCell == self.clearCell) {
        CBWeakSelf
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"确定要删除当前会话的聊天记录吗？" preferredStyle:TAlertControllerStyleAlert];
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"清除" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            CBStrongSelfElseReturn
            TIOSession *session = [TIOSession session:self.sessionId toUId:@"" type:TIOSessionTypeTeam];
            CBWeakSelf
            [TIOChat.shareSDK.conversationManager clearAllMessagesInSession:session completion:^(NSError * _Nullable error) {
                CBStrongSelfElseReturn
                if (error) {
                    DDLogError(@"%@",error.localizedDescription);
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                }
            }];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/// 跳转指定用户的主页
/// @param targetUserId 目标用户ID
- (void)jumpToUserhome:(NSString *)targetUserId
{
    // 可能已经解除好友关系 但是会话还在，查看的对方信息主页就会不一样
    // 所以 先验证是不是好友
    
    CBWeakSelf
    [TIOChat.shareSDK.friendManager isMyFriend:targetUserId
                                    completion:^(BOOL isFriend, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (error)
        {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
        else
        {
            // 预处理Block
            void (^jumpToUserInfoVCBlock)(TIOUser *userInfo, NSInteger type) = ^(TIOUser *userInfo, NSInteger type) {
                TUserHomePageViewController *vc = [TUserHomePageViewController.alloc initWithUser:userInfo type:type];
                [self.navigationController pushViewController:vc animated:YES];
            };
            
            
            BOOL isSelf = [targetUserId isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId];
            
            // 获取用户信息，再执行block跳转
            [TIOChat.shareSDK.friendManager fetchUserInfo:targetUserId completion:^(TIOUser * _Nullable user, NSError * _Nullable error) {
                if (error)
                {
                    DDLogError(@"%@",error);
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                }
                else
                {
                    jumpToUserInfoVCBlock(user, isSelf?0:(isFriend?1:3));
                }
            }];
        }
    }];
}

- (void)alertTiptop
{
    TInputAlertController *alert = [TInputAlertController alertWithTitle:@"请输入举报原因" placeholder:@"举报原因" inputHeight:40 inputStyle:TAlertInputStyleTextField];
    alert.titleLabel.textAlignment = NSTextAlignmentCenter;
    alert.titleLabel.textColor = [UIColor colorWithHex:0x333333];
    alert.titleLabel.font = [UIFont systemFontOfSize:16];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"举报" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        NSLog(@"%@",alert.text);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
