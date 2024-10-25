//
//  TTeamHomePageController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamHomePageController.h"
#import "TTeamMembersViewController.h"
#import "TTeamModifyNickViewController.h"
#import "TTeamModifyIntroViewController.h"
#import "TTeamInviteViewController.h"
#import "TTeamTransferViewController.h"
#import "TeamManageViewController.h"
#import "UIImageView+User.h"
/// common
#import "TCommonCell.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"
#import "TAlertController.h"
#import "TInputAlertController.h"
#import "MBProgressHUD+NJ.h"
#import "TSettingCell.h"
#import "CTMediator+ModuleActions.h"
#import "UIButton+Enlarge.h"
#import "QRCodeViewController.h"
#import "ServerConfig.h"

@interface TTeamHomePageController () <UITableViewDelegate, UITableViewDataSource, TTeamModifyNickViewControllerDelegate, TTeamModifyIntroViewControllerDelegate, TIOTeamDelegate>
@property (nonatomic, strong) TIOTeam *team;
@property (nonatomic, strong) TIOTeamMember *teamUser;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) NSArray<NSArray *> *cells;

@property (nonatomic, strong) TCommonCell *tNameCell;
@property (nonatomic, strong) TCommonCell *introCell;
@property (nonatomic, strong) TCommonCell *noticeCell;
@property (nonatomic, strong) TCommonCell *ownerCell; // 群主/管理员
@property (nonatomic, strong) TCommonCell *myNickCell;
@property (nonatomic, strong) TCommonCell *msgNotifCell;
@property (nonatomic, strong) TCommonCell *msgNoDisturbingCell;
@property (nonatomic, strong) TCommonCell *clearMsgCell;
@property (nonatomic, strong) TCommonCell *tipoffCell;
@property (nonatomic, strong) TCommonCell *qrCell;
@property (nonatomic, strong) TCommonCell *manageCell; // 群管理

@property (strong,  nonatomic) TSettingCell *topCell;//置顶开关
@property (strong,  nonatomic) TSettingCell *msgRemindCell;//消息提醒（免打扰）开关

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, copy) NSString *tapMemberId;

@end

@implementation TTeamHomePageController

- (instancetype)initWithTeam:(TIOTeam *)team
{
    self = [super init];
    
    if (self) {
        self.team = team;
        self.leftBarButtonText = @"群聊信息";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cells = @[];
    [self setupUI];
    [TIOChat.shareSDK.teamManager addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)dealloc
{
    [TIOChat.shareSDK.teamManager removeDelegate:self];
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.conversationManager findSession:[NSString stringWithFormat:@"-%@",self.team.teamId] complete:^(TIORecentSession * _Nullable session) {
        CBStrongSelfElseReturn
        if (session) {
            self->_msgRemindCell.open = session.msgfreeflag==1;
        }
    }];
    
    [TIOChat.shareSDK.teamManager fetchTeamInfoWithTeamId:self.team.teamId completion:^(TIOTeam * _Nullable team, TIOTeamMember * _Nullable teamUser, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        self.team       = team; // 群信息
        self.teamUser   = teamUser; // 自己在群内的信息
        
        if (teamUser.role == TIOTeamUserRoleNotMember)
        {
            TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"您不是本群成员" preferredStyle:TAlertControllerStyleAlert];
            alert.maxActionCountOfOneLine = 1;
            [alert addAction:[TAlertAction actionWithTitle:@"知道了" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            if (teamUser.role == TIOTeamUserRoleOwner || teamUser.role == TIOTeamUserRoleManager) {
                self.cells = @[@[self.tNameCell,self.introCell, self.noticeCell, self.ownerCell,self.qrCell],@[self.manageCell],@[self.myNickCell, self.topCell, self.msgRemindCell], @[self.clearMsgCell, self.tipoffCell]];
            } else {
                self.cells = @[@[self.tNameCell,self.introCell, self.noticeCell, self.ownerCell, self.qrCell],@[self.myNickCell, self.topCell, self.msgRemindCell],@[self.clearMsgCell, self.tipoffCell]];
            }
            
            self.myNickCell.detailTextLabel.text = teamUser.groupNick;
            self.msgRemindCell.open = teamUser.msgfreeflag == 1;
            
            // 获取群成员 option：NO 只获取部分成员作展示
            [TIOChat.shareSDK.teamManager fetchMembersInTeam:self.team.teamId searchKey:nil pageNumber:1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last,NSInteger total, NSError * _Nullable error) {
                self.members = teamUsers.count > 13 ? [teamUsers subarrayWithRange:NSMakeRange(0, 13)] : teamUsers;
                [self setTableHeaderView];
                [self.tableView reloadData];
            }];
        }
        
        [self refreshData];
    }];
}

- (void)setupUI
{
    [self setupNavRightItem];
    
//
//    TCommonCell *msgNotifCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
//    msgNotifCell.textLabel.text = @"消息提醒";
//    msgNotifCell.detailTextLabel.text = @"提醒所有消息";
//    msgNotifCell.hasIndiractor = YES;
//    self.msgNotifCell = msgNotifCell;
//
//    TCommonCell *msgNoDisturbingCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    msgNoDisturbingCell.textLabel.text = @"消息免打扰";
//    [msgNoDisturbingCell setAccessoryView:({
//        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 100, 60)];
//        UISwitch *switchControl = [UISwitch.alloc initWithFrame:CGRectMake(0, 0, 2, 2)];
//        switchControl.centerY = view.middleY;
//        switchControl.right = view.width - 16;
//        [view addSubview:switchControl];
//
//        view;
//    })];
//    self.msgNoDisturbingCell = msgNoDisturbingCell;
//
    TCommonCell *clearMsgCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    clearMsgCell.textLabel.text = @"清除聊天记录";
    clearMsgCell.detailTextLabel.text = @"";
    clearMsgCell.hasIndiractor = YES;
    self.clearMsgCell = clearMsgCell;
    
    TCommonCell *tipoffCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    tipoffCell.textLabel.text = @"投诉";
    tipoffCell.detailTextLabel.text = @"";
    tipoffCell.hasIndiractor = YES;
    self.tipoffCell = tipoffCell;
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.rowHeight = 60;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorInset = UIEdgeInsetsMake(0, 17, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)setupNavRightItem
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithImage:[[UIImage imageNamed:@"more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(toMore:)];
}

- (void)setTableHeaderView
{
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.tableView.width, 12)];
    view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];

    UIView *contentView = [UIView.alloc initWithFrame:CGRectMake(0, 12, self.tableView.width, 0)];
    contentView.backgroundColor = UIColor.whiteColor;
    [view addSubview:contentView];
    
    NSInteger columCount = 5; // 每行的数量
    
    NSInteger extCount = (self.teamUser.role == TIOTeamUserRoleOwner || self.teamUser.role == TIOTeamUserRoleManager) ? 2 : 1;
    
    NSInteger row = (self.members.count-1+extCount) / columCount + 1;
    CGFloat memberWidth = 50; // (cardView.width - 20 * (columCount+1)) / columCount;
    CGFloat memberHeight = memberWidth + 23;
    CGFloat memberSpacing = (view.width-32-columCount*memberWidth) / (columCount-1);
    
    contentView.height = 12 + memberHeight * row + (row-1) * 23 + 60;
    view.height += contentView.height;
    
    for (int i = 0; i < self.members.count+extCount; i++) {
        
        // 成员与添加按钮的布局规则一样
        CGRect frame = CGRectMake(17 + (i%columCount) * (memberWidth+memberSpacing), 12 + (i / columCount) * (memberHeight + 14), memberWidth, memberWidth);
        
        if (i == self.members.count) {
            // 倒数第二张添加成员按钮
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
            addButton.frame = frame;
            addButton.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
            addButton.layer.cornerRadius = 4;
            addButton.layer.masksToBounds = YES;
            [addButton setImage:[UIImage imageNamed:@"moreMembers"] forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(inviteFriendToTeam:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:addButton];
            
            UILabel *memberNickLabel = [UILabel.alloc initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame) + 6, memberWidth, 20)];
            memberNickLabel.text = @"添加";
            memberNickLabel.textAlignment = NSTextAlignmentCenter;
            memberNickLabel.font = [UIFont systemFontOfSize:12];
            memberNickLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
            [contentView addSubview:memberNickLabel];
            
            // 非群主时 根据群的邀请开关控制显隐邀请按钮
            if (self.team.applyFlag) {
                addButton.hidden = NO;
                memberNickLabel.hidden = NO;
            } else {
                if (self.teamUser.role == TIOTeamUserRoleOwner || self.teamUser.role == TIOTeamUserRoleManager) {
                    addButton.hidden = NO;
                    memberNickLabel.hidden = NO;
                } else {
                    addButton.hidden = YES;
                    memberNickLabel.hidden = YES;
                }
            }
            
            continue;
        }
        
        if (i == self.members.count+1) {
            // 倒数第一张删除成员按钮
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
            addButton.frame = frame;
            addButton.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
            addButton.layer.cornerRadius = 4;
            addButton.layer.masksToBounds = YES;
            [addButton setImage:[UIImage imageNamed:@"removeMembers"] forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(removeMember:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:addButton];
            
            UILabel *memberNickLabel = [UILabel.alloc initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame) + 6, memberWidth, 17)];
            memberNickLabel.text = @"删除";
            memberNickLabel.textAlignment = NSTextAlignmentCenter;
            memberNickLabel.font = [UIFont systemFontOfSize:12];
            memberNickLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
            [contentView addSubview:memberNickLabel];
            
            continue;
        }
        
        TIOTeamMember *member = self.members[i];
        
        UIImageView *memberAvatar = [UIImageView.alloc initWithFrame:frame];
        memberAvatar.uid = member.uid;
        memberAvatar.userInteractionEnabled = YES;
        [memberAvatar tio_imageUrl:member.avatar placeHolderImageName:@"avatar_placeholder" radius:4];
        [memberAvatar addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(tapMemberAvatr:)]];
        [contentView addSubview:memberAvatar];
        
        UILabel *memberNickLabel = [UILabel.alloc initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame) + 6, memberWidth, 17)];
        memberNickLabel.text = member.groupNick?:member.nick;
        memberNickLabel.textAlignment = NSTextAlignmentCenter;
        memberNickLabel.font = [UIFont systemFontOfSize:12];
        memberNickLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
        [contentView addSubview:memberNickLabel];
        
        if (i == 0) {
            // 第0个是群主 将群主在群内的昵称显示到群主cell上
            self.ownerCell.detailTextLabel.text = member.groupNick?:member.nick;
        }
    }
    
    // 更多成员button
    UIButton *moreMembersBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreMembersBtn.viewSize = CGSizeMake(contentView.width - 32, 36);
    moreMembersBtn.centerX = contentView.middleX;
    moreMembersBtn.bottom = contentView.height - 12;
    moreMembersBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [moreMembersBtn setTitleColor:[UIColor colorWithHex:0x909090] forState:UIControlStateNormal];
    [moreMembersBtn setTitle:[NSString stringWithFormat:@"查看全部成员(%zd)",self.team.memberNumber] forState:UIControlStateNormal];
    [moreMembersBtn setImage:[UIImage imageNamed:@"see_more_icon"] forState:UIControlStateNormal];
    [moreMembersBtn verticalLayoutWithInsetsStyle:ButtonStyleRight Spacing:0];
    [moreMembersBtn setBackgroundColor:[UIColor colorWithHex:0xF8F8F8]];
    [moreMembersBtn addTarget:self action:@selector(toAllMembersVC) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:moreMembersBtn];
    
    self.tableView.tableHeaderView = view;
}

- (TCommonCell *)tNameCell
{
    if (!_tNameCell) {
        _tNameCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _tNameCell.textLabel.text = @"群名称";
        _tNameCell.detailTextLabel.text = self.team.name;
        _tNameCell.hasIndiractor = YES;
    }
    return _tNameCell;
}

- (TCommonCell *)introCell
{
    if (!_introCell) {
        _introCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _introCell.textLabel.text = @"群简介";
        _introCell.detailTextLabel.text = self.team.intro;
        _introCell.hasIndiractor = YES;
    }
    return _introCell;
}

- (TCommonCell *)noticeCell
{
    if (!_noticeCell) {
        _noticeCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _noticeCell.textLabel.text = @"群公告";
        _noticeCell.detailTextLabel.text = self.team.notice;
        _noticeCell.hasIndiractor = YES;
    }
    return _noticeCell;
}

- (TCommonCell *)ownerCell
{
    if (!_ownerCell) {
        _ownerCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _ownerCell.textLabel.text = @"群主";
        _ownerCell.detailTextLabel.text = @"群主";
        _ownerCell.hasIndiractor = YES;
    }
    return _ownerCell;
}

- (TCommonCell *)myNickCell
{
    if (!_myNickCell) {
        _myNickCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _myNickCell.textLabel.text = @"我的群昵称";
        _myNickCell.detailTextLabel.text = @"群昵称";
        _myNickCell.hasIndiractor = YES;
    }
    return _myNickCell;
}

- (TCommonCell *)qrCell
{
    if (!_qrCell) {
        _qrCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _qrCell.hasIndiractor = YES;
        _qrCell.textLabel.text = @"群二维码";
        _qrCell.detailView = ({
            UIImageView *icon = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"team_qr"]];
            [icon sizeToFit];
            icon;
        });
    }
    return _qrCell;
}

- (TCommonCell *)manageCell
{
    if (!_manageCell) {
        _manageCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _manageCell.hasIndiractor = YES;
        _manageCell.textLabel.text = @"群管理";
    }
    return _manageCell;
}

- (TSettingCell *)topCell
{
    if (!_topCell) {
        _topCell = [TSettingCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _topCell.textLabel.text = @"聊天置顶";
        _topCell.open = self.topflag;
        CBWeakSelf
        _topCell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
            CBStrongSelfElseReturn
            TIOSession *session = [TIOSession session:[NSString stringWithFormat:@"-%@",self.team.teamId] toUId:self.team.teamId type:TIOSessionTypeTeam];
            [TIOChat.shareSDK.conversationManager topSession:session isTop:open completon:^(NSError * _Nullable error) {
                if (error) {
                    cell.open = !open;
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                }
            }];
        };
    }
    return _topCell;
}

- (TSettingCell *)msgRemindCell
{
    if (!_msgRemindCell) {
        _msgRemindCell = [TSettingCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _msgRemindCell.textLabel.text = @"消息免打扰";
        _msgRemindCell.open = NO;
        CBWeakSelf
        _msgRemindCell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
            CBStrongSelfElseReturn
            [TIOChat.shareSDK.conversationManager answerMessageNotificationForUid:nil orTeamid:self.team.teamId flag:open?1:2 completion:^(NSError * _Nullable error, id  _Nonnull data) {
                if (error) {
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                    cell.open = !open;
                } else {
                    
                }
            }];
        };
    }
    return _msgRemindCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = self.cells.count;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc init];
    view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.section][indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (selectedCell == _tNameCell) {
        // 群名称
        if (self.teamUser.role == TIOTeamUserRoleOwner || self.teamUser.role == TIOTeamUserRoleManager) {
            TInputAlertController *alert = [TInputAlertController alertWithTitle:@"修改群名称：" placeholder:@"" inputHeight:40 inputStyle:TAlertInputStyleTextField];
            [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                
            }]];
            [alert addAction:[TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                [TIOChat.shareSDK.teamManager updateTeamName:alert.text inTeam:self.team.teamId completion:^(NSError * _Nullable error) {
                    if (!error) {
                        [MBProgressHUD showSuccess:@"修改成功" toView:self.view];
                    }
                }];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else if (selectedCell == _introCell)
    {
        // 简介
        if (self.teamUser.role == TIOTeamUserRoleOwner || self.teamUser.role == TIOTeamUserRoleManager)
        {
            // 群主进入简介编辑页
            TTeamModifyIntroViewController *vc = [TTeamModifyIntroViewController.alloc initWithTitle:@"编辑群简介" team:self.team type:TTeamModifyIntroTypeIntro];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
//            TAlertController *alert = [TAlertController alertControllerWithTitle:@"群简介" message:self.team.intro preferredStyle:TAlertControllerStyleAlert];
//            alert.maxActionCountOfOneLine = 1;
//            [alert addAction:[TAlertAction actionWithTitle:@"确认" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
//
//            }]];
//
//            [self presentViewController:alert animated:YES completion:nil];
            TTeamModifyIntroViewController *vc = [TTeamModifyIntroViewController.alloc initWithTitle:@"群简介" team:self.team type:TTeamSeeIntroTypeIntro];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (selectedCell == _noticeCell)
    {
        // 公告
        if (self.teamUser.role == TIOTeamUserRoleOwner || self.teamUser.role == TIOTeamUserRoleManager)
        {
            // 群主进入公告编辑页
            TTeamModifyIntroViewController *vc = [TTeamModifyIntroViewController.alloc initWithTitle:@"编辑群公告" team:self.team type:TTeamModifyIntroTypeNotice];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
//            TAlertController *alert = [TAlertController alertControllerWithTitle:@"群公告" message:self.team.notice preferredStyle:TAlertControllerStyleAlert];
//            alert.maxActionCountOfOneLine = 1;
//            [alert addAction:[TAlertAction actionWithTitle:@"确认" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
//
//            }]];
//
//            [self presentViewController:alert animated:YES completion:nil];
            
            TTeamModifyIntroViewController *vc = [TTeamModifyIntroViewController.alloc initWithTitle:@"群公告" team:self.team type:TTeamSeeIntroTypeNotice];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (selectedCell == _ownerCell)
    {
        // 群主
    }
    else if (selectedCell == _myNickCell)
    {
        // 群昵称
        TTeamModifyNickViewController *vc = [TTeamModifyNickViewController.alloc initWithTitle:@"我的群昵称" member:self.teamUser];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (selectedCell == _msgNotifCell)
    {
        // 消息通知
    }
    else if (selectedCell == _msgRemindCell)
    {
        // 免打扰
    }
    else if (selectedCell == _clearMsgCell)
    {
        // 清除聊天
        CBWeakSelf
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"确定要删除本群的聊天记录吗？" preferredStyle:TAlertControllerStyleAlert];
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
    } else if (selectedCell == _tipoffCell) {
        // 投诉
        [TIOChat.shareSDK.conversationManager tipoffSession:self.sessionId complrtion:^(NSError * _Nullable error, id  _Nonnull data) {
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                [MBProgressHUD showInfo:@"投诉成功，等待后台审核" toView:self.view];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    } else if (selectedCell == _qrCell) {
        // 跳转二维码
        QRCodeViewController *vc = [QRCodeViewController.alloc init];
        vc.leftBarButtonText = @"群二维码";
        vc.isP2P = NO;
        vc.iconUrl = self.team.avatar;
        vc.name = self.team.name;
        vc.qr_data = [QR_SERVER stringByAppendingFormat:@"&g=%@&applyuid=%@",self.team.teamId,TIOChat.shareSDK.loginManager.userInfo.userId];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (selectedCell == _manageCell) {
        TeamManageViewController *vc = [TeamManageViewController.alloc init];
        vc.team = self.team;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)toAllMembersVC
{
    TTeamMembersViewController *vc = [TTeamMembersViewController.alloc initWithTeamUser:self.teamUser];
    vc.isRemoveMember = NO;
    vc.isOnlySee = YES;
    vc.isForbiddenAddOther = self.team.friendflag == 2;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inviteFriendToTeam:(id)sender
{
    TTeamInviteViewController *vc = [TTeamInviteViewController.alloc initWithTitle:@"邀请入群" type:TTeamSearchTypeInvite];
    vc.teamId = self.team.teamId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)removeMember:(id)sender
{
    TTeamMembersViewController *vc = [TTeamMembersViewController.alloc initWithTeamUser:self.teamUser];
    vc.isRemoveMember = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tapMemberAvatr:(UITapGestureRecognizer *)gesture
{
    UIImageView *memberAvatar = (UIImageView *)gesture.view;
    NSString *uid = [memberAvatar isKindOfClass:UIImageView.class] ? memberAvatar.uid : nil;
    
    if (self.team.friendflag == 1) {
        // 允许查看群成员信息
        [self jumpToUserhome:uid userInfo:nil];
    } else {
        if (self.team.grouprole == TIOTeamUserRoleOwner || self.team.grouprole == TIOTeamUserRoleManager) {
            // 群主 管理员 不受开关限制，可以查看群成员信息
            [self jumpToUserhome:uid userInfo:nil];
        } else {
            // 非群管/普通成员 只能查看和自己好友关系的群成员信息
            [TIOChat.shareSDK.friendManager isMyFriend:uid completion:^(BOOL isFriend, NSError * _Nullable error) {
                if (isFriend) {
                    [self jumpToUserhome:uid userInfo:nil];
                }
            }];
        }
    }
}

- (void)refreshData
{
    self.tNameCell.detailTextLabel.text = self.team.name;
    self.introCell.detailTextLabel.text = self.team.intro;
    self.noticeCell.detailTextLabel.text = self.team.notice;
    self.myNickCell.detailTextLabel.text = self.teamUser.groupNick;
}

- (void)toMore:(id)sender
{
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:TAlertControllerStyleActionSheet];
    [alert addAction:[TAlertAction actionWithTitle:@"退出群聊" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
        [self exitFromTeam];
    }]];
    
    if (self.teamUser.role == TIOTeamUserRoleOwner)
    {
        [alert addAction:[TAlertAction actionWithTitle:@"解散" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            [self deleteTeam];
        }]];
        
        [alert addAction:[TAlertAction actionWithTitle:@"转让该群" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            [self transferTeam];
        }]];
    }
    
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 退群
- (void)exitFromTeam
{
    [self presentViewController:({
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"确定退出当前群聊？\n退出后将不再接受此群消息" preferredStyle:TAlertControllerStyleAlert];
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"退出" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            // SDK API
            [TIOChat.shareSDK.teamManager exitFromTeam:self.team.teamId completion:^(NSError * _Nullable error) {
                if (error)
                {
                    DDLogError(@"%@",error);
                }
                else
                {
                    [MBProgressHUD showInfo:[NSString stringWithFormat:@"已经退出群\"%@\"",self.team.name] toView:self.view];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                }
            }];
        }]];
        
        alert;
    }) animated:YES completion:nil];
}

/// 解散群
- (void)deleteTeam
{
    [self presentViewController:({
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"解散后，所有与此群有关的记录都将被删除！确认解散本群吗？" preferredStyle:TAlertControllerStyleAlert];
        
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"确认解散" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            // SDK API
            [TIOChat.shareSDK.teamManager deleteTeam:self.team.teamId completion:^(NSError * _Nullable error) {
                if (error)
                {
                    DDLogError(@"%@",error);
                }
                else
                {
                    [MBProgressHUD showInfo:[NSString stringWithFormat:@"已经解散群\"%@\"",self.team.name] toView:self.view];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                }
            }];
        }]];
        
        alert;
    }) animated:YES completion:nil];
}

/// 转让群
- (void)transferTeam
{
    TTeamTransferViewController *vc = [TTeamTransferViewController.alloc init];
    vc.teamId = self.team.teamId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openInviteSwitch:(BOOL)open cell:(TSettingCell *)cell
{
    [TIOChat.shareSDK.teamManager updateJoiningPermissionForTeam:self.team.teamId isAllowJoin:open completion:^(NSError * _Nullable error) {
        if (error) {
            cell.open = !open;
        }
    }];
}

#pragma mark - 跳转到用户主页

/// 跳转指定用户的主页
/// @param targetUserId 目标用户ID
/// @param preUserInfo 有值直接传到下一页，不用获取用户信息
- (void)jumpToUserhome:(NSString *)targetUserId userInfo:(TIOUser *)preUserInfo
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
                
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
                    
                params[@"user"] = userInfo;
                params[@"type"] = @(type); // 好友
                    
                UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
                [self.navigationController pushViewController:homePageVC animated:YES];
            };
            

            // 获取用户信息，再执行block跳转
            [TIOChat.shareSDK.friendManager fetchUserInfo:targetUserId completion:^(TIOUser * _Nullable user, NSError * _Nullable error) {
                if (error)
                {
                    DDLogError(@"%@",error);
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                }
                else
                {
                    jumpToUserInfoVCBlock(user, isFriend?1:3);
                }
            }];
        }
    }];
}


#pragma mark - TTeamModifyNickViewControllerDelegate,TTeamModifyIntroViewControllerDelegate

- (void)shouldUpdateText:(NSString *)text
{
    // TODO: 更新成员群昵称显示
    [self requestData];
}

- (void)didUpdateIntro:(NSString *)text
{
    // TODO: 更新简介显示
    [self requestData];
}

- (void)didUpdateIntro:(nonnull NSString *)text type:(TTeamModifyIntroType)type
{
    // TODO: 更新简介显示
    [self requestData];
}

#pragma mark - TIOTeamDelegate

- (void)didUpdateTeamInfo:(TIOTeam * _Nullable )team
{
    [self requestData];
}

- (void)didUpdateMemebersCount:(NSInteger)count
{
    [self requestData];
}

@end
