//
//  WalletAccountInfoVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/10/30.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletAccountInfoVC.h"
#import "ImportSDK.h"

#import "FrameAccessor.h"
#import "TCommonCell.h"

@interface WalletAccountHeader : UITableViewHeaderFooterView
@property (nonatomic,   strong) UIImageView *imageView;
@property (nonatomic,   strong) UILabel *label;
@end
@implementation WalletAccountHeader
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
        
        self.imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 24, 24)];
        [self.contentView addSubview:self.imageView];
        
        self.label = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.label.textColor = [UIColor colorWithHex:0x999999];
        self.label.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.label];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.left = 16;
    self.imageView.centerY = self.contentView.middleY;
    [self.label sizeToFit];
    self.label.left = self.imageView.right + 4;
    self.label.centerY = self.imageView.centerY;
}

@end

@interface WalletAccountInfoVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,   weak) UITableView *tableView;
@property (nonatomic,   strong) NSArray *cells;
@property (nonatomic,   weak) TCommonCell *nameCell;
@property (nonatomic,   weak) TCommonCell *idcardCell;
@property (nonatomic,   weak) TCommonCell *phoneCell;
@property (nonatomic,   strong) NSArray<WalletAccountHeader *> *sectionHeaders;
@end

@implementation WalletAccountInfoVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"账户信息";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self requestData];
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchWalletDetailWithUid:TIOChat.shareSDK.loginManager.userInfo.userId
                                                    walletid:@""
                                                  completion:^(TIOWallet * _Nullable wallet, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        self.nameCell.detailTextLabel.text = wallet.nameDesc;
        self.idcardCell.detailTextLabel.text = wallet.idCardNoDesc;
        self.phoneCell.detailTextLabel.text = wallet.mobileDesc;
        
        if ([wallet.idCardRzStatus isEqualToString:@"SUCCESS"]) {
            self.sectionHeaders[0].imageView.image = [UIImage imageNamed:@"wallet_pass"];
            self.sectionHeaders[0].label.text = @"实名认证通过";
        } else {
            self.sectionHeaders[0].imageView.image = [UIImage imageNamed:@"wallet_fail"];
            self.sectionHeaders[0].label.text = @"实名认证失败";
        }
        
        if ([wallet.operatorRzStatus isEqualToString:@"SUCCESS"]) {
            self.sectionHeaders[1].imageView.image = [UIImage imageNamed:@"wallet_pass"];
            self.sectionHeaders[1].label.text = @"注册手机号认证成功";
        } else {
            self.sectionHeaders[1].imageView.image = [UIImage imageNamed:@"wallet_fail"];
            self.sectionHeaders[1].label.text = @"注册手机号认证失败";
        }
        
        [self.sectionHeaders[0] setNeedsLayout];
        [self.sectionHeaders[1] setNeedsLayout];
    }];
}

- (void)setupUI
{
    TCommonCell *nameCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    nameCell.hasIndiractor = NO;
    nameCell.textLabel.text = @"姓名";
    nameCell.detailTextLabel.text = @"";
    self.nameCell = nameCell;
    
    TCommonCell *idcardCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    idcardCell.hasIndiractor = NO;
    idcardCell.textLabel.text = @"身份证号";
    idcardCell.detailTextLabel.text = @"";
    self.idcardCell = idcardCell;
    
    TCommonCell *phoneCell = [TCommonCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    phoneCell.hasIndiractor = NO;
    phoneCell.textLabel.text = @"手机号";
    phoneCell.detailTextLabel.text = @"";
    self.phoneCell = phoneCell;
    
    self.cells = @[@[nameCell, idcardCell],@[phoneCell]];
    
    WalletAccountHeader *header1 = [WalletAccountHeader.alloc initWithReuseIdentifier:nil];
    WalletAccountHeader *header2 = [WalletAccountHeader.alloc initWithReuseIdentifier:nil];
    self.sectionHeaders = @[header1,header2];
    
    UITableView *tableview = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    tableview.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    tableview.rowHeight = 60;
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    tableview.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    [self.view addSubview:tableview];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.section][indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rows = self.cells[section];
    return rows.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.sectionHeaders[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
