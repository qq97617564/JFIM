//
//  MineInfoViewController.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/26.
//  Copyright © 2024 刘宇. All rights reserved.
//

#import "MineInfoViewController.h"
#import "TInfoCell.h"
#import "TMineUpdatePasswordViewController.h"
#import "UIImage+T_gzip.h"
#import "FrameAccessor.h"
#import "MBProgressHUD+NJ.h"
#import "TAlertController.h"
#import "TEdittingViewController.h"

#import "ImportSDK.h"

@interface MineInfoViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TIOLoginDelegate, TEdittingViewControllerDelegate>
@property (nonatomic, strong) NSArray<NSArray *> *cells;
@property (nonatomic, strong) TIOLoginUser *user;


@property (weak,    nonatomic) TInfoCell *avatarCell;
@property (weak,    nonatomic) TInfoCell *nickCell;
@property (weak,    nonatomic) TInfoCell *sexCell;
@property (weak,    nonatomic) TInfoCell *signCell;
@property (weak,    nonatomic) TInfoCell *addressCell;
//@property (weak,    nonatomic) TInfoCell *emailCell;
//@property (weak,    nonatomic) TInfoCell *phoneCell;

@end

@implementation MineInfoViewController

- (void)dealloc
{
    [TIOChat.shareSDK.loginManager removeDelegate:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"个人资料";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [TIOChat.shareSDK.loginManager addDelegate:self];
}

- (TIOLoginUser *)user
{
    if (!_user) {
        _user = [TIOChat.shareSDK.loginManager userInfo];
    }
    return _user;
}

- (void)requestUserData
{
}

- (void)setupUI
{
    TInfoCell *avatarCell = [self cellWithTitle:@"头像" subTitle:nil hasIndiractor:YES isSwitch:false];
    [avatarCell setAvatar:self.user.avatar];
    TInfoCell *nickCell = [self cellWithTitle:@"昵称" subTitle:self.user.nick hasIndiractor:YES isSwitch:false];
    
    NSString *sex = @"男";
    if (self.user.sex == TIOUserSexWomen) {
        sex = @"女";
    } else if (self.user.sex == TIOUserSexUnkown) {
        sex = @"保密";
    } else {
        sex = @"男";
    }
    
    TInfoCell *sexCell = [self cellWithTitle:@"性别" subTitle:sex hasIndiractor:YES isSwitch:false];
    TInfoCell *signCell = [self cellWithTitle:@"个性签名" subTitle:self.user.sign hasIndiractor:YES isSwitch:false];
    TInfoCell *addressCell = [self cellWithTitle:@"地区" subTitle:[NSString stringWithFormat:@"%@ %@",self.user.province?self.user.province:@"",self.user.city?self.user.city:@""] hasIndiractor:false isSwitch:true];
//    TInfoCell *emailCell = [self cellWithTitle:@"邮箱" subTitle:self.user.email hasIndiractor:NO];
//    TInfoCell *phoneCell = [self cellWithTitle:@"手机号" subTitle:self.user.phone?:@"还没有绑定手机" hasIndiractor:YES];
    
    self.avatarCell = avatarCell;
    self.nickCell = nickCell;
    self.sexCell = sexCell;
    self.signCell = signCell;
    self.addressCell = addressCell;
//    self.emailCell = emailCell;
//    self.phoneCell = phoneCell;
    if (self.user.areaviewflagGlobal == 1) {
        self.cells = @[@[avatarCell,nickCell,sexCell],@[signCell,addressCell]];
    }else{
        self.cells = @[@[avatarCell,nickCell,sexCell],@[signCell]];
    }

    
    
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionFooterHeight = CGFLOAT_MIN;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor colorWithHex:0xE6E6E6];
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
    return (indexPath.section == 0 && indexPath.row  == 0) ? 80 : 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc init];
    view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]])
    {
        // 头像
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:TAlertControllerStyleActionSheet];
        [alert addAction:[TAlertAction actionWithTitle:@"拍照" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置通过相册来选取照片
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else
            {
                [MBProgressHUD showInfo:@"无法使用设备的摄像头" toView:self.view];
            }
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"相册" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;//设置通过相册来选取照片
            imagePicker.allowsEditing = YES;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([indexPath isEqual:[NSIndexPath indexPathForRow:1 inSection:0]])
    {
        // 昵称
        TEdittingViewController *vc = [TEdittingViewController.alloc initWithTitle:@"昵称" text:self.user.nick inputType:TEdittingInputTypeField];
        vc.delegate = self;
        vc.maxNumber = 16;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([indexPath isEqual:[NSIndexPath indexPathForRow:2 inSection:0]])
    {
        // 性别
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:TAlertControllerStyleActionSheet];
        
        [alert addAction:[TAlertAction actionWithTitle:@"保密" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            
            /// SDK API
            [TIOChat.shareSDK.loginManager updateSex:TIOUserSexUnkown completion:^(NSError * _Nullable error) { }];
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"男" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            
            /// SDK API
            [TIOChat.shareSDK.loginManager updateSex:TIOUserSexMan completion:^(NSError * _Nullable error) { }];
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"女" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            
            /// SDK API
            [TIOChat.shareSDK.loginManager updateSex:TIOUserSexWomen completion:^(NSError * _Nullable error) { }];
            
        }]];
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:1]])
    {
        // 个性签名
        TEdittingViewController *vc = [TEdittingViewController.alloc initWithTitle:@"修改个性签名" text:self.user.sign inputType:TEdittingInputTypeView];
        vc.delegate = self;
        vc.maxNumber = 60; // 最多输入60个字
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([indexPath isEqual:[NSIndexPath indexPathForRow:1 inSection:1]])
    {
        
        // 地区
    }
    else if ([indexPath isEqual:[NSIndexPath indexPathForRow:1 inSection:2]])
    {
        // 邮箱
    }
    else
    {
        // 手机号
//        TEdittingViewController *vc = [TEdittingViewController.alloc initWithTitle:@"修改手机" text:self.user.phone inputType:TEdittingInputTypeField];
//        vc.delegate = self;
//        vc.maxNumber = 16;
//        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark -  工厂

- (TInfoCell *)cellWithTitle:(NSString *)title subTitle:(NSString *)subTitle hasIndiractor:(BOOL)hasIndiractor
                    isSwitch:(BOOL) isSwitch{
    TInfoCell *cell = [TInfoCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subTitle;
    cell.hasIndiractor = hasIndiractor;
    cell.isSwitch = isSwitch;
    cell.switchBtn.on = self.user.areaviewflag == 1;
    if ([title isEqualToString: @"地区"]) {
        [cell.switchBtn addTarget:self action:@selector(changewithSwitch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
-(void)changewithSwitch:(UISwitch *)sw{
    [MBProgressHUD showLoading:@"" toView:self.view];
    [TIOChat.shareSDK.loginManager updateShowAreaHandler:^(NSInteger status, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }else{
            self.user.areaviewflag = status;
            self.addressCell.switchBtn.on = self.user.areaviewflag == 1;
        }
    }];
}

#pragma mark - actions

- (void)updatePassword:(id)sender
{
    [self.navigationController pushViewController:[TMineUpdatePasswordViewController.alloc init] animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [MBProgressHUD showLoading:@"" toView:self.view];
    [TIOChat.shareSDK.loginManager updateAvatar:image completion:^(NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - SDK-delegate TIOLoginDelegate

/// 一定要实现此代理
/// 当自己的用户信息发生变更后，此代理有效，刷新UI
/// @param user 最新的用户信息
- (void)didUpdateCurrentUserInfo:(TIOLoginUser *)user
{
    /// 更新内存数据
    self.user = user;
    
    NSString *sex = nil;
    
    if (user.sex == TIOUserSexMan)
    {
        sex = @"男";
    }
    else if (user.sex == TIOUserSexWomen)
    {
        sex = @"女";
    }
    else
    {
        sex = @"保密";
    }
    
    [self.avatarCell setAvatar:user.avatar];
    self.nickCell.detailTextLabel.text = user.nick;
    self.sexCell.detailTextLabel.text = sex;
    self.signCell.detailTextLabel.text = user.sign?:@"还没写过个性签名";
    self.addressCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",self.user.province,self.user.city];
//    self.emailCell.detailTextLabel.text = user.email;
//    self.phoneCell.detailTextLabel.text = user.phone;
    
}


#pragma mark - TEdittingViewControllerDelegate

- (void)t_edittingViewController:(TEdittingViewController *)edittingViewController didFinishedText:(NSString *)text handler:(TEdittingHandler)handler
{
    // 通知编辑页处理结果
    void (^edittingHandler)(NSError *error, NSString *successMsg) = ^(NSError *error, NSString *successMsg) {
        if (error)
        {
            handler(NO, error.localizedDescription);
        }
        else
        {
            handler(YES, successMsg);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [edittingViewController.navigationController popViewControllerAnimated:YES];
            });
        }
    };
    
    
    if ([edittingViewController.leftBarButtonText isEqualToString:@"修改昵称"]) {
        
        [TIOChat.shareSDK.loginManager updateNick:text completion:^(NSError * _Nullable error) {
            // 通知编辑页处理结果
            edittingHandler(error, @"新的昵称已修改完成");
        }];
        
    } else if ([edittingViewController.leftBarButtonText isEqualToString:@"修改个性签名"]) {
        [TIOChat.shareSDK.loginManager updateSign:text completion:^(NSError * _Nullable error) {
            // 通知编辑页处理结果
            edittingHandler(error, @"新的个性签名已修改完成");
        }];
    } else {
        [TIOChat.shareSDK.loginManager updatePhone:text completion:^(NSError * _Nullable error) {
            // 通知编辑页处理结果
            edittingHandler(error, @"新的手机号已修改完成");
        }];
    }
}

@end
