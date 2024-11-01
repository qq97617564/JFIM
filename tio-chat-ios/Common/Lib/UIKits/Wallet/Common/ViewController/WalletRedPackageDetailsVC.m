//
//  WalletRedDetailsVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletRedPackageDetailsVC.h"
#import "WalletRedPackageGetDetailCell.h"
#import "TMineWalletViewController.h"
#import "WalletRedPackageRecordVC.h"

#import "UIButton+Enlarge.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"
#import "ImportSDK.h"
#import "NSString+T_Time.h"

#import "WalletManager.h"

@interface WalletRedPackageDetailsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) UIView *senderTableHeader;
@property (strong,  nonatomic) UIView *receiverTableHeader;

@property (weak,    nonatomic) UIImageView *avatar;// 红包发送者的头像
@property (weak,    nonatomic) UILabel *fromLabel;  // 红包发送者的昵称
@property (weak,    nonatomic) UIImageView *pinIcon;  // 拼人品红包的icon标志
@property (weak,    nonatomic) UILabel *wishLabel;  // 祝福语
@property (weak,    nonatomic) UILabel *receiveMoneyLabel;    // 红包金额备注
@property (weak,    nonatomic) UILabel *receiveStatusLabel;// 领取状态显示

@property (strong,  nonatomic) NSArray <TIOGrabRedPackage *> *grabDataArray;
@property (assign,  nonatomic) WalletStatus redPackageStatus;
@property (assign,  nonatomic) WalletGrabStatus grabStatus;

/// 默认是-1，意味着没有
@property (assign,  nonatomic) NSInteger luckyIndex;

/// 自己抢了这个红包 对应的数据model
/// 属性为空，说明没抢这个红包；不为空，说明自己已经抢了这个红包
@property (strong,  nonatomic) TIOGrabRedPackage *selfGrabModel;

@end

@implementation WalletRedPackageDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.luckyIndex = -1;
    
    [self setupUI];
    [self requestData];
}

- (void)requestData
{
    if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
        [self requestYiPayData];
    } else if (WalletManager.shareInstance.vendor == WalletVendorNewPay) {
        [self requestNewPayData];
    }
    
}

- (void)requestYiPayData
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchRedDetailsWithSerialNumber:self.serialNumber completion:^(TIORedPackage * _Nullable redInfor, NSArray<TIOGrabRedPackage *> * _Nullable grabList, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        /// 更新领取的列表数据
        self.grabDataArray = grabList;
        
        
        
        if (grabList.count == 0) {
            /// 红包未被领取
            /// 言外之意，只有发红包的人能进入这一步，不显示领取金额
            self.tableView.tableHeaderView = self.senderTableHeader;
            
            /// 更新页面数据
            [self updateModel:redInfor selfGrab:self.selfGrabModel unReceived:YES];
        } else {
            NSString *uid = TIOChat.shareSDK.loginManager.userInfo.userId;
            
            TIOGrabRedPackage *luckModel = nil;
            if (redInfor.mode == 2 && redInfor.packetcount == grabList.count) {
                luckModel = grabList.lastObject;
            }
            
            for (int i = 0; i < grabList.count; i++) {
                TIOGrabRedPackage *grab = grabList[i];
                if ([grab.uid isEqualToString:uid]) {
                    /// 当前抢红包列表中有自己
                    self.selfGrabModel = grab;
                }
                
                if (luckModel) {
                    if (luckModel.amount < grab.amount) {
                        luckModel = grab;
                    }
                }
            }
            
            if (luckModel) luckModel.isLucky = YES;
            
            if (self.selfGrabModel) {
                /// 即使自己领了红包，不管是不是自己发的，也显示领取金额
                self.tableView.tableHeaderView = self.receiverTableHeader;
            } else {
                /// 自己没有领，又有列表显示，说明，自己是发红包的人
                self.tableView.tableHeaderView = self.senderTableHeader;
            }
            
            /// 更新页面数据
            [self updateModel:redInfor selfGrab:self.selfGrabModel unReceived:NO];
        }
        
        /// 刷新页面
        [self.tableView reloadData];
    }];
}

- (void)requestNewPayData
{
    CBWeakSelf
    [TIOChat.shareSDK.walletManager queryRedInformationForRed:self.serialNumber completion:^(TIORedPackage * _Nullable redInfor, NSArray<TIOGrabRedPackage *> * _Nullable grabList, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        /// 更新领取的列表数据
        self.grabDataArray = grabList;
        
        
        
        if (grabList.count == 0) {
            /// 红包未被领取
            /// 言外之意，只有发红包的人能进入这一步，不显示领取金额
            self.tableView.tableHeaderView = self.senderTableHeader;
            
            /// 更新页面数据
            [self updateModel:redInfor selfGrab:self.selfGrabModel unReceived:YES];
        } else {
            NSString *uid = TIOChat.shareSDK.loginManager.userInfo.userId;
            
            TIOGrabRedPackage *luckModel = nil;
            if (redInfor.mode == 2 && redInfor.num == grabList.count) {
                luckModel = grabList.lastObject;
            }
            
            for (int i = 0; i < grabList.count; i++) {
                TIOGrabRedPackage *grab = grabList[i];
                if ([grab.uid isEqualToString:uid]) {
                    /// 当前抢红包列表中有自己
                    self.selfGrabModel = grab;
                }
                
                if (luckModel) {
                    if (luckModel.cny < grab.cny) {
                        luckModel = grab;
                    }
                }
            }
            
            if (luckModel) luckModel.isLucky = YES;
            
            if (self.selfGrabModel) {
                /// 即使自己领了红包，不管是不是自己发的，也显示领取金额
                self.tableView.tableHeaderView = self.receiverTableHeader;
            } else {
                /// 自己没有领，又有列表显示，说明，自己是发红包的人
                self.tableView.tableHeaderView = self.senderTableHeader;
            }
            
            /// 更新页面数据
            [self updateModel:redInfor selfGrab:self.selfGrabModel unReceived:NO];
        }
        
        /// 刷新页面
        [self.tableView reloadData];
    }];
}

/// 自定义导航
- (void)loadNaivigatonBar
{
    self.navigationBar.backgroundColor = [UIColor colorWithHex:0xFF5E5E];
    [self.view bringSubviewToFront:self.navigationBar];
     
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back2"] style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"红包记录" style:UIBarButtonItemStylePlain target:self action:@selector(toRedRecordVC:)];
}

/// UI启动入口
- (void)setupUI
{
    [self loadNaivigatonBar];
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height-Height_NavBar) style:UITableViewStylePlain];
    tableView.backgroundColor = UIColor.whiteColor;
    [tableView addSubview:({
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, -tableView.height, tableView.width, tableView.height)];
        view.backgroundColor = [UIColor colorWithHex:0xFF5E5E];
        [tableView sendSubviewToBack:view];
        
        view;
    })];
    tableView.rowHeight = 60;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorInset = UIEdgeInsetsMake(0, 71, 0, 0);
    tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [tableView registerClass:WalletRedPackageGetDetailCell.class forCellReuseIdentifier:NSStringFromClass(WalletRedPackageGetDetailCell.class)];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

/// 红包发送人看到的样式
- (UIView *)senderTableHeader
{
    if (!_senderTableHeader) {
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, 140)];
        view.backgroundColor = UIColor.whiteColor;
        
        UIImageView *bg = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, view.width, 102)];
        bg.image = [UIImage imageNamed:@"red_detail_bg"];
        [view addSubview:bg];
        
        UILabel *wishLabel = [UILabel.alloc initWithFrame:CGRectMake(16, 48, view.width-32, 21)];
        wishLabel.textColor = [UIColor colorWithHex:0xFFBCA7];
        wishLabel.font = [UIFont systemFontOfSize:14];
        wishLabel.textAlignment = NSTextAlignmentCenter;
        wishLabel.text = @"恭喜发财，吉祥如意";
        [view addSubview:wishLabel];
        self.wishLabel = wishLabel;
        
        UILabel *remarkLabel = [UILabel.alloc initWithFrame:CGRectMake(16, bg.bottom, view.width-32, view.height-bg.bottom)];
        remarkLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
        remarkLabel.font = [UIFont systemFontOfSize:12];
        remarkLabel.textAlignment = NSTextAlignmentCenter;
        [bg addSubview:remarkLabel];
        self.receiveStatusLabel = remarkLabel;
        
        UIImageView *avatar = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 30, 30)];
        avatar.image = [UIImage imageNamed:@"avatar_placeholder"];
        [view addSubview:avatar];
        self.avatar = avatar;
        
        UILabel *fromLabel = [UILabel.alloc initWithFrame:CGRectZero];
        fromLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        fromLabel.textColor = UIColor.whiteColor;
        fromLabel.text = @"努力显示这个土豪的名字";
        [view addSubview:fromLabel];
        self.fromLabel = fromLabel;
        
        UIImageView *pinView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 19, 19)];
        pinView.image = [UIImage imageNamed:@"red_pin1"];
        pinView.hidden = YES;
        [view addSubview:pinView];
        self.pinIcon = pinView;
        
        _senderTableHeader = view;
    }
    
    
    return _senderTableHeader;
}

- (UIView *)receiverTableHeader
{
    if (!_receiverTableHeader) {
        _receiverTableHeader = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, 250)];
        _receiverTableHeader.backgroundColor = UIColor.whiteColor;
        
        UIImageView *bg = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, _receiverTableHeader.width, 102)];
        bg.image = [UIImage imageNamed:@"red_detail_bg"];
        [_receiverTableHeader addSubview:bg];
        
        UILabel *wishLabel = [UILabel.alloc initWithFrame:CGRectMake(16, 48, _receiverTableHeader.width-32, 21)];
        wishLabel.textColor = [UIColor colorWithHex:0xFFBCA7];
        wishLabel.font = [UIFont systemFontOfSize:14];
        wishLabel.textAlignment = NSTextAlignmentCenter;
        wishLabel.text = @"恭喜发财，吉祥如意";
        [_receiverTableHeader addSubview:wishLabel];
        self.wishLabel = wishLabel;
        
        UILabel *remarkLabel = [UILabel.alloc initWithFrame:CGRectMake(16, bg.bottom, _receiverTableHeader.width-32, 62)];
        remarkLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
        remarkLabel.font = [UIFont systemFontOfSize:12];
        remarkLabel.textAlignment = NSTextAlignmentCenter;
        [bg addSubview:remarkLabel];
        self.receiveMoneyLabel = remarkLabel;
        
        UIImageView *avatar = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_receiverTableHeader addSubview:avatar];
        self.avatar = avatar;
        
        UILabel *fromLabel = [UILabel.alloc initWithFrame:CGRectZero];
        fromLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        fromLabel.textColor = UIColor.whiteColor;
        [_receiverTableHeader addSubview:fromLabel];
        self.fromLabel = fromLabel;
        
        UIImageView *pinView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 19, 19)];
        pinView.image = [UIImage imageNamed:@"red_pin1"];
        pinView.hidden = YES;
        [_receiverTableHeader addSubview:pinView];
        self.pinIcon = pinView;
        
        // 已转入钱包余额
        UIButton *walletButton = [UIButton buttonWithType:UIButtonTypeCustom];
        walletButton.frame = CGRectMake(16, remarkLabel.bottom, _receiverTableHeader.width-32, 37);
        [walletButton setTitle:@"已转入钱包余额" forState:UIControlStateNormal];
        [walletButton setTitleColor:[UIColor colorWithHex:0x9C9C9C] forState:UIControlStateNormal];
        walletButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [walletButton addTarget:self action:@selector(toWalletHomeVC:) forControlEvents:UIControlEventTouchUpInside];
        [_receiverTableHeader addSubview:walletButton];
        
        UIView *line = [UIView.alloc initWithFrame:CGRectMake(0, walletButton.bottom, _receiverTableHeader.width, 12)];
        line.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
        [_receiverTableHeader addSubview:line];
        
        UILabel *statusLabel = [UILabel.alloc initWithFrame:CGRectMake(0, line.bottom, _receiverTableHeader.width, 37)];
        statusLabel.font = [UIFont systemFontOfSize:12];
        statusLabel.textColor = [UIColor colorWithHex:0x9C9C9C];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        [_receiverTableHeader addSubview:statusLabel];
        self.receiveStatusLabel = statusLabel;
    }
    
    return _receiverTableHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WalletRedPackageGetDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WalletRedPackageGetDetailCell.class)];
    
    NSString *time = @"";
    NSInteger grabAmount = 0;
    
    if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
        time    = self.grabDataArray[indexPath.row].bizcompletetime;
        grabAmount  = self.grabDataArray[indexPath.row].amount;
    } else {
        time    = self.grabDataArray[indexPath.row].grabtime;
        grabAmount  = self.grabDataArray[indexPath.row].cny;
    }
    
    [cell.imageView tio_imageUrl:self.grabDataArray[indexPath.row].avatar placeHolderImageName:@"avatar_placeholder" radius:4];
    cell.textLabel.text = self.grabDataArray[indexPath.row].nick;
    cell.detailTextLabel.text = time;
    cell.moneyLabel.text = [NSString stringWithFormat:@"%.2f元",grabAmount/100.f];
    cell.isLucky = self.grabDataArray[indexPath.row].isLucky;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.grabDataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - private

/// 易支付 刷新数据
/// @param redInfo 红包信息
/// @param selfGrab 自己的抢红包信息
/// @param unReceived 是否收到
- (void)updateModel:(TIORedPackage *)redInfo selfGrab:(TIOGrabRedPackage *)selfGrab unReceived:(BOOL)unReceived;
{
    BOOL pin = redInfo.mode == 2;
    
    
    NSString *remark    = nil;
    NSInteger selfGrabAmount = 0;
    NSInteger redAmount = 0; // 红包总金额
    NSInteger redCount  = 0; // 红包数量
    
    NSString *startTime, *endTime;
    
    if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
        if (selfGrab) {
            selfGrabAmount = selfGrab.amount;
        }
        
        redAmount   = redInfo.amount;
        redCount    = redInfo.packetcount;
        
        startTime   = redInfo.bizcreattime;
        endTime     = redInfo.bizcompletetime;
    } else {
        if (selfGrab) {
            selfGrabAmount = selfGrab.cny;
        }
        
        redAmount   = redInfo.cny;
        redCount    = redInfo.num;
        
        startTime   = redInfo.starttime;
        endTime     = redInfo.endtime;
    }
    
    
    [self.avatar tio_imageUrl:redInfo.avatar placeHolderImageName:@"placeholder_avatar" radius:2];
    self.fromLabel.text = redInfo.nick.length<10?redInfo.nick:[redInfo.nick substringToIndex:10];
    self.pinIcon.hidden = !pin;
    self.wishLabel.text = remark;
    
    [self.fromLabel sizeToFit];
    
    /// 拼人品的布局
    if (pin) {
        self.avatar.left = (self.view.width-8-self.avatar.width-self.fromLabel.width-self.pinIcon.width)*0.5;
        self.avatar.top = 14;
        self.fromLabel.left = self.avatar.right+5;
        self.fromLabel.centerY = self.avatar.centerY;
        self.pinIcon.left = self.fromLabel.right + 3;
        self.pinIcon.centerY = self.avatar.centerY;
    } else {
        self.avatar.left = (self.view.width-5-self.avatar.width-self.fromLabel.width)*0.5;
        self.avatar.top = 14;
        self.fromLabel.left = self.avatar.right+5;
        self.fromLabel.centerY = self.avatar.centerY;
    }
    
    /// 判断自己是否已领取，显示自己领取的金额
    if (selfGrab) {
        /// 显示领取金额
        [self setMoney:[NSString stringWithFormat:@"%.2f",selfGrabAmount/100.f]];
    }
    
    /// 显示红包领取的状态：多少个红包被领取、还剩多少未被领取等等
    
    NSInteger recievedCount = self.grabDataArray.count;
    CGFloat recievedAmount = 0;
    CGFloat totalAmount = redAmount/100.f;
    NSInteger totalCount = redCount;
    
    for (TIOGrabRedPackage *grab in self.grabDataArray) {
        if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
            recievedAmount += grab.amount;
        } else {
            recievedAmount += grab.cny;
        }
    }
    
    recievedAmount = recievedAmount / 100.f;
    
    if (unReceived)
    {   /// 红包无人领取
        if ([redInfo.status isEqualToString:@"TIMEOUT"] || [redInfo.status isEqualToString:@"6"]) {
            /// 过期无人领
            self.receiveStatusLabel.text = [NSString stringWithFormat:@"该红包已过期。已领取0/%zd个，共0.00/%.2f元",totalCount,totalAmount];
        } else {
            /// 没有过期，无人领
            if (redInfo.mode == 1) {
                /// 私聊+没有过期+无人领
                self.receiveStatusLabel.text = [NSString stringWithFormat:@"红包金额%.2f元，等待对方领取",totalAmount];
            } else {
                /// 群聊+没有过期+无人领
                self.receiveStatusLabel.text = [NSString stringWithFormat:@"已领取0/%zd个，共0.00/%.2f元",totalCount,totalAmount];
            }
        }
    }
    else
    {   /// 已经有人领取
        /// 是不是自己发的
        BOOL isSelfSend = [redInfo.uid isEqualToString:TIOChat.shareSDK.loginManager.userInfo.userId];
        
        if ([redInfo.status isEqualToString:@"SUCCESS"] || [redInfo.status isEqualToString:@"5"]) {
            /// 已被领完
            /// 普通红包 && 私聊
            if (redInfo.mode == 1 && redInfo.chatmode==1) {
                /// 私聊 （发送人）
                if (isSelfSend) {
                    self.receiveStatusLabel.text = [NSString stringWithFormat:@"红包金额%.2f元，该红包已领取",totalAmount];
                } else {
                    self.receiveStatusLabel.text = @"";
                    self.receiverTableHeader.height = self.receiverTableHeader.height - self.receiveStatusLabel.height;
                }
            } else {
                /// 群聊（发送人+领取人） + 私聊（领取人）
                /// 4个红包共8.00元，15分钟被领完
                NSString *time = [NSString calculateSpendTimeFromDate:startTime toDate:endTime];
                self.receiveStatusLabel.text = [NSString stringWithFormat:@"%zd个红包共%.2f元，%@被领完",totalCount,totalAmount,time];
            }
        } else if ([redInfo.status isEqualToString:@"SEND"] || [redInfo.status isEqualToString:@"1"]) {
            /// 未被领完 (一定是群聊)
            self.receiveStatusLabel.text = [NSString stringWithFormat:@"已领取%zd/%zd个，共%.2f/%.2f元",recievedCount,totalCount,recievedAmount,totalAmount];
        } else if ([redInfo.status isEqualToString:@"TIMEOUT"] || [redInfo.status isEqualToString:@"6"]) {
            /// 过期
            if (redInfo.chatmode == 1) {
                // 私聊过期
                self.receiveStatusLabel.text = [NSString stringWithFormat:@"红包金额%.2f元，该红包已过期",totalAmount];
            } else {
                // 群聊过期
                self.receiveStatusLabel.text = [NSString stringWithFormat:@"该红包已过期。已领取%zd/%zd个，共%.2f/%.2f元",recievedCount,totalCount,recievedAmount,totalAmount];
            }
        }
    }
}

- (void)setMoney:(NSString *)money
{
    NSDictionary *attr1 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont systemFontOfSize:20 weight:UIFontWeightSemibold]};
    NSDictionary *attr2 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont fontWithName:@"DINAlternate-Bold" size:42]};//DINAlternate-Bold //DINCondensed-Bold
    self.receiveMoneyLabel.attributedText = ({
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:money attributes:attr2]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"元" attributes:attr1]];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle.alloc init];
        style.alignment = NSTextAlignmentCenter;
        [aString addAttributes:@{NSParagraphStyleAttributeName:style} range:NSMakeRange(0, aString.length)];
        
//        [aString addAttribute:NSBaselineOffsetAttributeName value:@(0.08*(42-20)) range:NSMakeRange(0, money.length)];
//        [aString addAttribute:NSBaselineOffsetAttributeName value:@(0.08*(42-20)) range:NSMakeRange(aString.length-money.length, 1)];
        
        aString;
    });
}

#pragma mark - actions

- (void)toRedRecordVC:(id)sender
{
    WalletRedPackageRecordVC *vc = [WalletRedPackageRecordVC.alloc init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toWalletHomeVC:(id)sender
{
    TMineWalletViewController *vc = [TMineWalletViewController.alloc init];
    vc.uid = TIOChat.shareSDK.loginManager.userInfo.userId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
