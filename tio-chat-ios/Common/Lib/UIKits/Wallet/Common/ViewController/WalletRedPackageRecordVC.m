//
//  WalletRedRecordViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletRedPackageRecordVC.h"
#import "WalletReceiceRedCell.h"
#import "WalletSendRedCell.h"
#import "WalletYearPicker.h"

#import "WalletManager.h"

#import "FrameAccessor.h"
#import "UIImageView+Web.h"
#import "ImportSDK.h"
#import "UIButton+Enlarge.h"
#import "UIImageView+Web.h"
#import <MJRefresh/MJRefresh.h>
#import <UIScrollView+EmptyDataSet.h>

@interface WalletRedPackageRecordVC () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (strong,  nonatomic) UIImageView *avatar;
@property (strong,  nonatomic) UILabel *nickLable;
@property (strong,  nonatomic) NSArray<UIButton *> *tabButtons;
@property (strong,  nonatomic) UIView *tabIndiractor;
@property (strong,  nonatomic) UILabel *moneyLabel;
@property (strong,  nonatomic) UITableView *tableView;
@property (assign,  nonatomic) NSInteger indexOfTab;
@property (assign,  nonatomic) NSInteger indexOfQuest;
@property (strong,  nonatomic) NSArray<TIOGrabRedPackage *> *grabListData;
@property (strong,  nonatomic) NSArray<TIORedPackage *> *sendListData;

@property (assign,  nonatomic) NSInteger pageNumber;
@property (assign,  nonatomic) NSInteger lastYearIndex;
@property (strong,  nonatomic) NSArray *years;

@end

@implementation WalletRedPackageRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self resetData];
    self.title = @"红包记录";
    [self setupUI];
    [self beginLoadingMore:nil];
}

- (void)setupUI
{
    UIView *topBg = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_NavBar)];
    topBg.backgroundColor = [UIColor colorWithHex:0xF94335];
    [self.view addSubview:topBg];
 
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.view bringSubviewToFront:self.navigationBar];
     
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.titleLabel.font = [UIFont systemFontOfSize:18];
//        [button setImage:[UIImage imageNamed:@"back2"] forState:UIControlStateNormal];
//        [button setTitle:@"红包记录" forState:UIControlStateNormal];
//        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//        [button verticalLayoutWithInsetsStyle:ButtonStyleLeft Spacing:-40];
//        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
//        
//        button;
//    })];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(barItemClick:)];
//    self.years.firstObject
    

    
//    // tab
//    UIView *tabView = [UIView.alloc initWithFrame:CGRectMake((self.view.width - 232)*0.5, Height_NavBar, 232, 32)];
//    tabView.backgroundColor = [UIColor colorWithHex:0xFC5050];
//    tabView.layer.cornerRadius = 16;
//    tabView.layer.masksToBounds = YES;
//    [self.view addSubview:tabView];
//    

//
//    UIButton *sendButton = [UIButton buttonWithType: UIButtonTypeCustom];
//    sendButton.frame = CGRectMake(tabView.width * 0.55, 0, tabView.width * 0.45, tabView.height-2);
//    sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    [sendButton setTitleColor:[UIColor colorWithHex:0xFFBEBE] forState:UIControlStateNormal];
//    [sendButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
//    [sendButton setTitle:@"我发出的" forState:UIControlStateNormal];
//    [sendButton addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [tabView addSubview:sendButton];
//    
//    self.tabButtons = @[receiveButton, sendButton];
    
//    self.tabIndiractor = [UIView.alloc initWithFrame:CGRectMake(0, 0, 52, 1)];
//    self.tabIndiractor.backgroundColor = UIColor.whiteColor;
//    self.tabIndiractor.bottom = tabView.height - 4;
//    self.tabIndiractor.centerX = receiveButton.centerX;
//    [tabView addSubview:self.tabIndiractor];
    
    
    // tableview
    self.tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    self.tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [[UIColor.alloc init] colorWithAlphaComponent:0];
    [self.tableView registerClass:WalletReceiceRedCell.class forCellReuseIdentifier:NSStringFromClass(WalletReceiceRedCell.class)];
    [self.tableView registerClass:WalletSendRedCell.class forCellReuseIdentifier:NSStringFromClass(WalletSendRedCell.class)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.rowHeight = 70;
    self.tableView.separatorColor = [UIColor colorWithHex:0xF5F5F5];
    self.tableView.mj_footer = ({
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter.alloc init];
        footer.stateLabel.textColor = UIColor.grayColor;
        footer.stateLabel.font = [UIFont systemFontOfSize:12];
        [footer setTitle:@"— 已显示全部 —" forState:MJRefreshStateNoMoreData];
        [footer setRefreshingTarget:self refreshingAction:@selector(beginLoadingMore:)];
        footer.hidden = YES;
        
        footer;
    });
    [self.view addSubview:self.tableView];
    UIImageView *topBg1 = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, 270)];
    topBg1.backgroundColor = [UIColor colorWithHex:0xF1F2F6];
    [self.tableView addSubview:topBg1];
    
    // 头像和昵称
    self.avatar = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 80, 80)];
    [self.avatar tio_imageUrl:TIOChat.shareSDK.loginManager.userInfo.avatar placeHolderImageName:@"avatar_placeholder" radius:1];
//    self.avatar.layer.borderColor = UIColor.whiteColor.CGColor;
//    self.avatar.layer.borderWidth = 4;
    self.avatar.layer.cornerRadius = 6;
    self.avatar.layer.masksToBounds = YES;
    UIView *shadowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    shadowView.top = 35;
    shadowView.centerX = self.tableView.middleX;
    [self.tableView addSubview:shadowView];
//    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
//    shadowView.layer.shadowOffset = CGSizeMake(5, 5);
//    shadowView.layer.shadowOpacity = 0.3;
//    shadowView.layer.shadowRadius = 8.0;
    shadowView.layer.cornerRadius = 6.0;
    shadowView.clipsToBounds = NO;
    [shadowView addSubview:self.avatar];
    
    self.nickLable = [UILabel.alloc initWithFrame:CGRectZero];
    self.nickLable.text = [TIOChat.shareSDK.loginManager.userInfo.nick stringByAppendingString:@"共收到"];
    self.nickLable.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.nickLable.textColor = [UIColor colorWithHex:0x333333];
    [self.nickLable sizeToFit];
    self.nickLable.centerX = self.tableView.middleX;
    self.nickLable.top = shadowView.bottom + 12;
    [self.tableView addSubview:self.nickLable];
    
    self.moneyLabel = [UILabel.alloc initWithFrame:CGRectMake(20, 149, self.tableView.width - 40, 67)];
    [self.tableView addSubview:self.moneyLabel];
    [self setMoney:@"0.00"];
    
    [self.tabButtons[0] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    UIButton *receiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    receiveButton.frame = CGRectMake(self.view.width-55, Height_NavBar+10, 40, 15);
    receiveButton.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    [receiveButton setTitleColor:[UIColor colorWithHex:0xD9A64F] forState:UIControlStateNormal];
//    [receiveButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [receiveButton setTitle:self.years.firstObject forState:UIControlStateNormal];
    [receiveButton addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    receiveButton.selected = YES;
    [self.view addSubview:receiveButton];
}
-(void)barItemClick:(id)btn{

    [self resetData];
    
    self.indexOfQuest = self.indexOfQuest == 0? 1 : 0;
    
    NSString *nick = TIOChat.shareSDK.loginManager.userInfo.nick;
    
    self.nickLable.text = self.indexOfQuest==0?[nick stringByAppendingString:@"共收到"]:[nick stringByAppendingString:@"共发出"];

    
    [self beginLoadingMore:nil];
    
  
}

- (void)tabButtonClicked:(UIButton *)button
{
    [self filterYearClicked:button];
}

- (void)filterYearClicked:(UIButton *)sender
{
    CBWeakSelf
    [WalletYearPicker showItems:[self years] currentIndex:self.lastYearIndex block:^(NSInteger currentIndex) {
        CBStrongSelfElseReturn
        self.lastYearIndex = currentIndex;
        self.pageNumber = 1;
        [self beginLoadingMore:nil];
        [sender setTitle:self.years[currentIndex] forState:UIControlStateNormal];

    } onView:self.view];
}

- (void)receiveDetailView:(NSString *)packagecount
{
    self.tableView.tableHeaderView = ({
        UIView *view  = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.tableView.width, 270)];
        UIView *menu = [UIView.alloc initWithFrame:CGRectMake(0, view.height - 55, view.width, 45)];
        menu.backgroundColor = UIColor.clearColor;
        
        UILabel *labelA = [UILabel.alloc initWithFrame:CGRectMake(0, 0, view.width, 25)];
        labelA.text = [NSString stringWithFormat:@"%@",packagecount];
        labelA.textColor = [UIColor colorWithHex:0xBCBCBC];
        labelA.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        UILabel *labelB = [UILabel.alloc initWithFrame:CGRectMake(0, 25, view.width, 20)];
        labelB.text = [NSString stringWithFormat:@"收到的红包数"];
        labelB.textColor = [UIColor colorWithHex:0xBCBCBC];
        labelB.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        labelA.textAlignment = NSTextAlignmentCenter;
        labelB.textAlignment = NSTextAlignmentCenter;
        [menu addSubview:labelA];
        [menu addSubview:labelB];
        [view addSubview:menu];
        
        view;
    });
}

- (void)sendDetailView:(NSString *)count
{
    self.tableView.tableHeaderView = ({
        UIView *view  = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.tableView.width, 270)];
        UIView *menu = [UIView.alloc initWithFrame:CGRectMake(0, view.height - 55, view.width, 45)];
        menu.backgroundColor = UIColor.clearColor;
        
        UILabel *labelA = [UILabel.alloc initWithFrame:CGRectMake(0, 0, view.width, 25)];
        labelA.text = [NSString stringWithFormat:@"%@",count];
        labelA.textColor = [UIColor colorWithHex:0xBCBCBC];
        labelA.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        UILabel *labelB = [UILabel.alloc initWithFrame:CGRectMake(0, 25, view.width, 20)];
        labelB.text = [NSString stringWithFormat:@"发出的红包数"];
        labelB.textColor = [UIColor colorWithHex:0xBCBCBC];
        labelB.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        labelA.textAlignment = NSTextAlignmentCenter;
        labelB.textAlignment = NSTextAlignmentCenter;
        [menu addSubview:labelA];
        [menu addSubview:labelB];
        [view addSubview:menu];
        
        view;
    });
}

- (void)setMoney:(NSString *)money
{
    NSDictionary *attr1 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold]};
    NSDictionary *attr2 = @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x333333], NSFontAttributeName:[UIFont fontWithName:@"DINAlternate-Bold" size:48]};//DINAlternate-Bold //DINCondensed-Bold
    self.moneyLabel.attributedText = ({
        NSMutableAttributedString *aString = [NSMutableAttributedString.alloc init];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:money attributes:attr2]];
        [aString appendAttributedString:[NSAttributedString.alloc initWithString:@"元" attributes:attr1]];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle.alloc init];
        style.alignment = NSTextAlignmentCenter;
        [aString addAttributes:@{NSParagraphStyleAttributeName:style} range:NSMakeRange(0, aString.length)];
        
        aString;
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *avatar = nil;
    NSString *nick = nil;
    NSString *time = nil;
    NSString *amount = nil;
    BOOL pin = NO;
    
    UITableViewCell *commonCell = nil;
    
    if (self.indexOfTab == 0) {
        avatar = self.grabListData[indexPath.row].avatar;
        nick = self.grabListData[indexPath.row].nick;
        
        if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
            time = self.grabListData[indexPath.row].bizcompletetime;
            amount = [NSString stringWithFormat:@"%.2f元",self.grabListData[indexPath.row].amount/100.f];
        } else {
            time = self.grabListData[indexPath.row].grabtime;
            amount = [NSString stringWithFormat:@"%.2f元",self.grabListData[indexPath.row].cny/100.f];
        }
        
        pin = self.grabListData[indexPath.row].mode==2;
        
        WalletReceiceRedCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WalletReceiceRedCell.class)];
        
        [cell.imageView tio_imageUrl:avatar placeHolderImageName:@"avatar_placeholder" radius:4];
        cell.textLabel.text = nick;
        cell.detailTextLabel.text = time;
        cell.moneyLabel.text = amount;
        cell.pinImageView.hidden = !pin;
        
        commonCell = cell;
    } else {
        TIORedPackage *model = self.sendListData[indexPath.row];
        avatar  = model.avatar;
        nick    = model.nick;
        time    = model.bizcreattime;
        pin     = model.mode==2;
        
        NSInteger receivedcount, packetcount;
        
        if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
            amount          = [NSString stringWithFormat:@"%.2f元",model.amount/100.f];
            receivedcount   = model.receivedcount;
            packetcount     = model.packetcount;
        } else {
            amount          = [NSString stringWithFormat:@"%.2f元",model.cny/100.f];
            receivedcount   = model.acceptnum;
            packetcount     = model.num;
            time            = model.starttime;
        }
        
        WalletSendRedCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WalletSendRedCell.class)];
        
        cell.textLabel.text = pin?@"拼人品红包":@"普通红包";
        cell.detailTextLabel.text = time;
        cell.moneyLabel.text = amount;
        cell.recievedLabel.text = [NSString stringWithFormat:@"%zd/%zd个",receivedcount,packetcount];
        
        if ([model.status isEqualToString:@"TIMEOUT"] || [model.status isEqualToString:@"6"]) {
            cell.statusLabel.text = @"已过期";
        } else {
            cell.statusLabel.text = @"";
        }
        
        commonCell = cell;
    }
    
    return commonCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.indexOfTab == 0) {
        return self.grabListData.count;
    }
    return self.sendListData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
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
}

#pragma mark - data

- (void)beginLoadingMore:(id)sender
{
    if (self.indexOfQuest == 0) {
        CBWeakSelf
        [TIOChat.shareSDK.walletManager fetchOwnGradRedListWithFilterYear:self.years[self.lastYearIndex] pageNumber:self.pageNumber completion:^(NSArray<TIOGrabRedPackage *> * _Nullable grabList, BOOL first, BOOL last, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            [self.tableView.mj_footer resetNoMoreData];
            
            self.tableView.mj_footer.hidden = grabList.count==0;
            
            if (self.pageNumber == 1) {
                self.grabListData = grabList;
            } else {
                self.grabListData = [self.grabListData arrayByAddingObjectsFromArray:grabList];
            }
            
            if (last) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.tableView.mj_footer endRefreshing];
                self.pageNumber++; // 下一次查询的页码
            }
            self.indexOfTab = self.indexOfQuest;
            [self.tableView reloadData];
        }];
        
        [TIOChat.shareSDK.walletManager fetchGrabDataWithFilterYear:self.years[self.lastYearIndex] completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            NSInteger amount;
            NSInteger num = [result[@"num"] integerValue];
            if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
                amount = [result[@"amount"] integerValue];
            } else {
                amount = [result[@"cny"] integerValue];
            }
            [self sendDetailView:[NSString stringWithFormat:@"%ld",(long)num]];
            [self setMoney:[NSString stringWithFormat:@"%.2f",amount/100.f]];
        }];
    } else {
        CBWeakSelf
        [TIOChat.shareSDK.walletManager fetchOwnSendRedListWithFilterYear:self.years[self.lastYearIndex] pageNumber:self.pageNumber completion:^(NSArray<TIORedPackage *> * _Nullable sendList, BOOL first, BOOL last, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            [self.tableView.mj_footer resetNoMoreData];
            
            self.tableView.mj_footer.hidden = sendList.count==0;
            
            if (self.pageNumber == 1) {
                self.sendListData = sendList;
            } else {
                self.sendListData = [self.sendListData arrayByAddingObjectsFromArray:sendList];
            }
            
            if (last) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.tableView.mj_footer endRefreshing];
                self.pageNumber++; // 下一次查询的页码
            }
            
            self.indexOfTab = self.indexOfQuest;
            [self.tableView reloadData];
        }];
        
        [TIOChat.shareSDK.walletManager fetchSendDataWithFilterYear:self.years[self.lastYearIndex] completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            NSInteger amount;
            NSInteger num = [result[@"num"] integerValue];
            if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
                amount = [result[@"amount"] integerValue];
            } else {
                amount = [result[@"cny"] integerValue];
            }
            [self receiveDetailView:[NSString stringWithFormat:@"%ld",(long)num]];
            [self setMoney:[NSString stringWithFormat:@"%.2f",amount/100.f]];
        }];
    }
    
}

- (NSInteger)getCurrentYear
{
    NSDate *date = [NSDate date];
        //下面是单独获取每项的值
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |NSMonthCalendarUnit |NSDayCalendarUnit |NSWeekdayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    
    return [comps year];
}

- (void)resetData
{
    self.pageNumber = 1;
    [self.tableView scrollsToTop];
}

- (NSArray *)years
{
    if (!_years) {
        NSInteger currentYear = [self getCurrentYear];
        NSMutableArray *years = [NSMutableArray array];
        
        /// 从2020年开始,
        /// 2020年也算，故+1
        NSInteger count = currentYear - 2020 + 1;
        
        for (int i = 0; i < count; i++) {
            NSInteger year = currentYear - i;
            [years addObject:[NSString stringWithFormat:@"%zd",year]];
        }
        
        _years = years;
    }
    return _years;
}

#pragma mark - DZNEmptyDataSetSource

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"w_empty"];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *attrString = @"暂无红包记录";
    return [[NSAttributedString alloc] initWithString:attrString attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHex:0xAAAAAA], NSFontAttributeName : [UIFont systemFontOfSize:12]}];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return UIColor.clearColor;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return 50;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}


@end
