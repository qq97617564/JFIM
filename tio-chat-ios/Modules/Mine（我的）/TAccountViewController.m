//
//  TAccountViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/4.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TAccountViewController.h"
#import "TCommonCell.h"
#import "FrameAccessor.h"
#import "ImportSDK.h"

#import "TThirdBindListViewController.h"
#import "TMineUpdatePasswordViewController.h"
#import "TModifyPhoneFirstViewController.h"

#import "GFLogOffVC.h"
#import "TModifyPhoneSecondViewController.h"

@interface TAccountViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong,  nonatomic) TCommonCell *accountCell;
@property (strong,  nonatomic) TCommonCell *emailCell;
@property (strong,  nonatomic) TCommonCell *phoneCell;
@property (strong,  nonatomic) TCommonCell *thirdCell;
@property (strong,  nonatomic) TCommonCell *cancelCell;
@property (strong,  nonatomic) UITableViewCell *updatePwdCell;
@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) NSArray<NSArray *> *cells;

@property (weak,    nonatomic) UILabel *phoneLabel;

@end

@implementation TAccountViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"账号";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    TIOLoginUser *userObject = TIOChat.shareSDK.loginManager.userInfo;
//    if (userObject.emailbindflag == 1) {
//        self.cells = @[@[self.emailCell, self.phoneCell],@[self.updatePwdCell]];
//    } else {
//        self.cells = @[@[self.phoneCell],@[self.updatePwdCell]];
//    }
    self.cells = @[@[self.accountCell,self.phoneCell,self.cancelCell],@[self.updatePwdCell]];
    
    [self setupUI];
}

- (void)setupUI
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (TCommonCell *)emailCell
{
    if (!_emailCell) {
        _emailCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _emailCell.textLabel.textColor = [UIColor colorWithHex:0x333333];
        _emailCell.textLabel.text = @"注册邮箱";
        _emailCell.detailTextLabel.text = TIOChat.shareSDK.loginManager.userInfo.email;
    }
    return _emailCell;
}
- (TCommonCell *)accountCell
{
    if (!_emailCell) {
        _emailCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _emailCell.textLabel.textColor = [UIColor colorWithHex:0x333333];
        _emailCell.textLabel.text = @"账号";
        _emailCell.detailTextLabel.text = TIOChat.shareSDK.loginManager.userInfo.loginname;
    }
    return _emailCell;
}

- (TCommonCell *)phoneCell
{
    if (!_phoneCell) {
        _phoneCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _phoneCell.textLabel.textColor = [UIColor colorWithHex:0x333333];
        _phoneCell.textLabel.text = @"注册手机";
        _phoneCell.detailView = ({
            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 150, 60)];
            UILabel *editBtn = [UILabel.alloc init];
            editBtn.text = @"修改";
            editBtn.textColor = [UIColor colorWithHex:0x4C94FF];
            editBtn.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
            [editBtn sizeToFit];
            editBtn.height = view.height;
            editBtn.centerY = view.middleY;
            editBtn.right = view.width - 16;
            [view addSubview:editBtn];
            if (TIOChat.shareSDK.loginManager.userInfo.phone.length == 0){
                editBtn.text = @"绑定";
            }
            UILabel *phoneLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, view.width-editBtn.width, view.height)];
            phoneLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
            phoneLabel.font = [UIFont systemFontOfSize:14];
            phoneLabel.textAlignment = NSTextAlignmentRight;
            phoneLabel.right = editBtn.left - 10;
            phoneLabel.text = TIOChat.shareSDK.loginManager.userInfo.phone;
            [view addSubview:phoneLabel];
            self.phoneLabel = phoneLabel;
            
            view;
        });
    }
    return _phoneCell;
}

- (TCommonCell *)thirdCell
{
    if (!_thirdCell) {
        _thirdCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _thirdCell.textLabel.textColor = [UIColor colorWithHex:0x333333];
        _thirdCell.textLabel.text = @"第三方登录";
        _thirdCell.hasIndiractor = YES;
    }
    return _thirdCell;
}

- (TCommonCell *)cancelCell
{
    if (!_cancelCell) {
        _cancelCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        _cancelCell.textLabel.textColor = [UIColor colorWithHex:0x333333];
        _cancelCell.textLabel.text = @"账号注销";
        _cancelCell.hasIndiractor = YES;
    }
    return _cancelCell;
}

- (UITableViewCell *)updatePwdCell
{
    if (!_updatePwdCell) {
        _updatePwdCell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        [_updatePwdCell.contentView addSubview:({
            UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
            label.text = @"修改密码";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithHex:0x0087FC];
            label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
            label.userInteractionEnabled = NO;
            label;
        })];
    }
    return _updatePwdCell;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.section][indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return ({
        UIView *view = [UIView.alloc init];
        view.backgroundColor = tableView.backgroundColor;
        view;
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (selectedCell == self.phoneCell) { // 修改手机
        if (TIOChat.shareSDK.loginManager.userInfo.phone.length  == 11) {
            TModifyPhoneFirstViewController *vc = [TModifyPhoneFirstViewController.alloc init];
            [self.navigationController pushViewController:vc animated:YES];
        }else{ //绑定手机
            TModifyPhoneSecondViewController *vc = [[TModifyPhoneSecondViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }

    } else if (selectedCell == self.thirdCell) { // 三方登录
        [self.navigationController pushViewController:TThirdBindListViewController.alloc.init animated:YES];
    } else if (selectedCell == self.cancelCell) { // 注销
        GFLogOffVC *vc = [[GFLogOffVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (selectedCell == self.updatePwdCell) { // 修改密码
        [self.navigationController pushViewController:[TMineUpdatePasswordViewController.alloc init] animated:YES];
    }
}

@end

