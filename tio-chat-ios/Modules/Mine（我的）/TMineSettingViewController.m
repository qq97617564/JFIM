//
//  TMineSettingViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TMineSettingViewController.h"
#import "TSettingCell.h"
#import "TCommonCell.h"
#import "FrameAccessor.h"
#import "TAlertController.h"

@interface TMineSettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray<NSArray *> *cells;
@end

@implementation TMineSettingViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.leftBarButtonText = @"设置";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [TIOChat.shareSDK.loginManager updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
        [self setupUI];
    }];
}

- (void)requestUserData
{
    
}

- (void)setupUI
{
    TSettingCell *allowApplyCell = [self cellWithTitle:@"加我好友时需要验证"];
    allowApplyCell.open = self.user.fdvalidtype == 1;
    allowApplyCell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
        
        [TIOChat.shareSDK.loginManager updatePermissionForVerifyingApply:open completion:^(NSError * _Nullable error) {
            if (error)
            {
                DDLogError(@"%@",error);
                cell.open = !open;
            }
        }];
        
    };
    
    TSettingCell *allowSearchedCell = [self cellWithTitle:@"允许别人搜索到我"];
    allowSearchedCell.open = self.user.searchflag == 1;
    allowSearchedCell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
        
        [TIOChat.shareSDK.loginManager updatePermissionForSearchedByOther:open completion:^(NSError * _Nullable error) {
            if (error)
            {
                DDLogError(@"%@",error);
                cell.open = !open;
            }
        }];
        
    };
    
    
    TSettingCell *allowMessageRemindCell = [self cellWithTitle:@"消息提醒"];
    allowMessageRemindCell.open = self.user.msgremindflag == 1;
    allowMessageRemindCell.switchCallback = ^(TSettingCell * _Nonnull cell, BOOL open) {
        
        [TIOChat.shareSDK.loginManager updatePermissionForReceivingMsgRemind:open completion:^(NSError * _Nullable error) {
            if (error)
            {
                DDLogError(@"%@",error);
                cell.open = !open;
                if (cell.open) {
                    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"global_mutx"];
                } else {
                    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"global_mutx"];
                }
                [NSUserDefaults.standardUserDefaults synchronize];
            }
        }];
        
    };

//    TCommonCell *clearCell = ({
//        TCommonCell *cell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//        cell.textLabel.text = @"清除消息";
//        cell.hasIndiractor = YES;
//
//        cell;
//    });\\\\\\\\\
    
    TSettingCell *versionCell = [self cellWithTitle:@"当前版本"];
    versionCell.detailText = [NSString stringWithFormat:@"v %@（公测版）",NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];
    
    self.cells = @[@[allowApplyCell, allowSearchedCell, allowMessageRemindCell, versionCell]];
    
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorInset = UIEdgeInsetsMake(0, 81, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xE6E6E6];
    tableView.sectionFooterHeight = CGFLOAT_MIN;
    tableView.tableHeaderView = ({
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 40)];
        view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
        UILabel *label = [UILabel.alloc initWithFrame:CGRectZero];
        label.text = [NSString stringWithFormat:@"账号：%@",self.user.phone];
        label.textColor = [UIColor colorWithHex:0xB6B9BC];
        label.font = [UIFont systemFontOfSize:14];
        [label sizeToFit];
        label.left = 16;
        label.centerY = view.middleY;
        [view addSubview:label];
        
        view;
    });
    tableView.tableFooterView = ({
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 80)];
        view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 20, view.width, 60);
        button.backgroundColor = UIColor.whiteColor;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"退出登录" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        view;
    });
    [self.view addSubview:tableView];
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
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -  工厂

- (TSettingCell *)cellWithTitle:(NSString *)title
{
    TSettingCell *cell = [TSettingCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = title;
    
    return cell;
}

#pragma mark - actions

- (void)logout:(id)sneder
{
    
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"确定退出当前帐号？" preferredStyle:TAlertControllerStyleAlert];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"退出" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        [TIOChat.shareSDK.loginManager logout:^(NSError * _Nullable error) {
            
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
