//
//  TeamManageViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TeamManageViewController.h"
#import "TNoTalkingListViewController.h"
#import "FrameAccessor.h"
#import "TSettingCell.h"
#import "TCommonCell.h"
#import "ImportSDK.h"
#import "MBProgressHUD+NJ.h"

@interface TeamManageViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) TSettingCell *inviteControlCell;
/// 成员互加
@property (nonatomic, strong) TSettingCell *memeberAddMemberCell;
/// 审核邀请
@property (nonatomic, strong) TSettingCell *reviewInvitationCell;
@property (strong,  nonatomic) TSettingCell *noTalkingCell;
@property (strong,  nonatomic) TCommonCell *noTalkingListCell;
@property (strong,  nonatomic) NSArray<NSArray *> *cells;
@end

@implementation TeamManageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"群管理";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestData];
}

- (void)setupUI
{
    CBWeakSelf
    self.memeberAddMemberCell = [TSettingCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.memeberAddMemberCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.memeberAddMemberCell.textLabel.text = @"群内互加好友";
    self.memeberAddMemberCell.open = self.team.friendflag==1;
    self.memeberAddMemberCell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
        CBStrongSelfElseReturn
        [TIOChat.shareSDK.teamManager updateAddingFriendPermissionInTeam:self.team.teamId flag:open?1:2 completion:^(NSError * _Nullable error) {
            if (error) {
                cell.open = !open;
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
        }];
    };
    
    self.inviteControlCell = [TSettingCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.inviteControlCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.inviteControlCell.textLabel.text = @"开启成员邀请";
    self.inviteControlCell.open = self.team.applyFlag;
    self.inviteControlCell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
        CBStrongSelfElseReturn
        [TIOChat.shareSDK.teamManager updateJoiningPermissionForTeam:self.team.teamId isAllowJoin:open completion:^(NSError * _Nullable error) {
            if (error) {
                cell.open = !open;
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
        }];
    };
    
    self.reviewInvitationCell = [TSettingCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.reviewInvitationCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.reviewInvitationCell.textLabel.text = @"邀请审核";
    self.reviewInvitationCell.open = self.team.joinType == TIOTeamJoinTypeReview;
    self.reviewInvitationCell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
        CBStrongSelfElseReturn
        [TIOChat.shareSDK.teamManager updateReviewingPermissionForTeam:self.team.teamId isReview:open completion:^(NSError * _Nullable error) {
            if (error) {
                cell.open = !open;
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
        }];
    };
    
    self.noTalkingCell = [TSettingCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    self.noTalkingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.noTalkingCell.textLabel.text = @"全体禁言";
    [self.noTalkingCell setSwitchCallback:^(TSettingCell * _Nonnull cell, BOOL open) {
        CBStrongSelfElseReturn
        [TIOChat.shareSDK.teamManager forbiddenSpeakInTeam:self.team.teamId oper:open?1:2 mode:4 duration:0 uid:nil completion:^(NSError * _Nullable error) {
            if (!error) {
                [MBProgressHUD showInfo:@"操作成功" toView:self.view];
            } else {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
                cell.open = !open;
            }
        }];
    }];
    
    self.noTalkingListCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    self.noTalkingListCell.textLabel.text = @"禁言名单";
    self.noTalkingListCell.detailTextLabel.text = @"0人";
    self.noTalkingListCell.hasIndiractor = YES;
    
    self.cells = @[@[self.memeberAddMemberCell,self.inviteControlCell,self.reviewInvitationCell], @[self.noTalkingCell, self.noTalkingListCell]];
    
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor colorWithHex:0xF9F9F9];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorInset = UIEdgeInsetsMake(0, 81, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xE6E6E6];
    tableView.rowHeight = 60;
    tableView.sectionHeaderHeight = 15;
    [self.view addSubview:tableView];
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.teamManager fetchForbiddenUserListInTeamId:self.team.teamId searchKey:nil pageNumber:1 completion:^(NSArray<TIOTeamMember *> * _Nullable teamUsers, BOOL first, BOOL last, NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        self.noTalkingListCell.detailTextLabel.text = [NSString stringWithFormat:@"%zd人",total];
    }];
    
    [TIOChat.shareSDK.teamManager fetchTeamInfoWithTeamId:self.team.teamId completion:^(TIOTeam * _Nullable team, TIOTeamMember * _Nullable teamUser, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        self.noTalkingCell.open = team.forbiddenflag==1;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == _noTalkingListCell) {
        // 点击禁言名单
        TNoTalkingListViewController *vc = [TNoTalkingListViewController.alloc init];
        vc.teamid = self.team.teamId;
        [self.navigationController pushViewController:vc animated:YES];
    } 
}

@end
