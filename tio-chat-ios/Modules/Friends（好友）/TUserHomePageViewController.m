//
//  TUserInfoViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TUserHomePageViewController.h"
#import "TModifyRemarkViewController.h"
#import "ImportSDK.h"
#import "CTMediator+ModuleActions.h"
/// common
#import "MBProgressHUD+NJ.h"
#import "TInputAlertController.h"
#import "TEdittingViewController.h"
#import "UIButton+Enlarge.h"
#import "UIControl+T_LimitClickCount.h"
#import "TIOKitTool.h"

#import "FrameAccessor.h"
#import <M80AttributedLabel.h>
#import <UIImageView+WebCache.h>

@interface TUserHomePageViewController () <TEdittingViewControllerDelegate>
@property (assign, nonatomic) TUserHomePageType type;
@property (strong, nonatomic) TIOUser *user;
@property (assign, nonatomic) BOOL addedBlackList;
/// 用户信息卡片
@property (strong, nonatomic) UIImageView *userInfoCard;
/// 头像
@property (strong, nonatomic) UIImageView *avatarView;
/// 昵称
@property (strong, nonatomic) UILabel *nickLabel;
@property (strong, nonatomic) UILabel *niLabel;
@property (strong, nonatomic) UIButton *remarkLabel;
@property (strong, nonatomic) UILabel *reLabel;
/// 地址
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UILabel *addrLabel;
/// 座右铭
@property (strong, nonatomic) UILabel *signLabel;
@property (strong, nonatomic) UILabel *sLabel;

@property (strong, nonatomic) UIView *friendContentView;
@property (strong, nonatomic) UIView *verifyContentView;
@property (strong, nonatomic) UIView *addContentView;
@property (strong, nonatomic) UIView *ownContentView;

@property (strong, nonatomic) UIView *preview;

@end

@implementation TUserHomePageViewController

- (instancetype)initWithUser:(TIOUser *)user type:(TUserHomePageType)type
{
    self = [super init];
    
    if (self) {
        self.user = user;
        self.type = type;
        self.title = @"个人信息";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCommonUI];
    [self requestUserInfoData];
}

- (void)layout
{
    if (self.type == TUserInfoVCTypeFriend) {
        self.remarkLabel.left = 94;
        self.remarkLabel.centerY = self.reLabel.centerY;
        if (self.remarkLabel.width > (self.view.width - 94 - 16)) {
            self.remarkLabel.width = self.view.width - 94 - 16;
        }
        self.addrLabel.top = self.niLabel.bottom;
        self.addressLabel.centerY = self.addrLabel.centerY;
        self.sLabel.top = self.addrLabel.bottom;
        self.signLabel.top = self.sLabel.top + 10;
        self.signLabel.left = 94;
    } else if (self.type == TUserInfoVCTypeAdd) {
        self.sLabel.top = self.addrLabel.bottom;
        self.signLabel.top = self.sLabel.top + 10;
        self.signLabel.left = 94;
    } else if (self.type == TUserInfoVCTypeVerfiy) {
        self.sLabel.top = self.addrLabel.bottom;
        self.signLabel.top = self.sLabel.top + 10;
        self.signLabel.left = 94;
        
        self.verifyContentView.frame = CGRectMake(0, self.signLabel.bottom + 20, self.view.width, self.view.height - self.signLabel.bottom);
    } else if (self.type == TUserInfoVCTypeSelf) {
        self.sLabel.top = self.addrLabel.bottom;
        self.signLabel.top = self.sLabel.top + 10;
        self.signLabel.left = 94;
    } else {
        
    }
}

/// 绘制通用部分UI
- (void)setupCommonUI
{   
    UIView *statusView = [UIView.alloc initWithFrame:CGRectMake(0, 0, self.view.width, Height_StatusBar)];
    statusView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    [self.view addSubview:statusView];
    
    self.userInfoCard = [UIImageView.alloc initWithFrame:CGRectMake(0, Height_StatusBar, self.view.width, 232)];
    self.userInfoCard.image = [UIImage imageNamed:@"user_bg"];
    self.userInfoCard.userInteractionEnabled = YES;
    [self.view addSubview:self.userInfoCard];
    
    UIImageView *avatarView = [UIImageView.alloc initWithFrame:CGRectMake(0, 60, 80, 80)];
    avatarView.centerX = self.userInfoCard.middleX;
    avatarView.contentMode = UIViewContentModeScaleAspectFill;
    avatarView.layer.cornerRadius = 8;
    avatarView.layer.masksToBounds = YES;
    avatarView.layer.borderColor = UIColor.whiteColor.CGColor;
    avatarView.layer.borderWidth = 4.f;
    avatarView.userInteractionEnabled = YES;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:self.user.avatar] placeholderImage:nil];
    [self.userInfoCard addSubview:avatarView];
    
    UITapGestureRecognizer *avatarGesture = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(avatarGesture:)];
    [avatarView addGestureRecognizer:avatarGesture];
    
    // 头像下方的昵称 显示备注优先
    self.nickLabel = [UILabel.alloc initWithFrame:CGRectMake(30, avatarView.bottom + 16, self.userInfoCard.width - 60, 25)];
    self.nickLabel.font = [UIFont systemFontOfSize:20];
    self.nickLabel.textColor = [UIColor colorWithHex:0x333333];
    self.nickLabel.textAlignment = NSTextAlignmentCenter;
    [self.nickLabel setText:self.user.remarkname?:self.user.nick];
    [self.userInfoCard addSubview:self.nickLabel];
    
    
    // 定位
    UILabel *addrLabel = [UILabel.alloc initWithFrame:CGRectMake(16, self.userInfoCard.bottom, 94-16, 44)];
    addrLabel.textColor = [UIColor colorWithHex:0x666666];
    addrLabel.text = @"地区";
    addrLabel.font = [UIFont systemFontOfSize:16];
    addrLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:addrLabel];
    self.addrLabel = addrLabel;
    self.addressLabel = [UILabel.alloc initWithFrame:CGRectMake(addrLabel.right, 0, self.view.width*0.6, 20)];
    self.addressLabel.centerY = addrLabel.centerY;
    self.addressLabel.font = [UIFont systemFontOfSize:16];
    self.addressLabel.textColor = [UIColor colorWithHex:0x333333];
    self.addressLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.addressLabel];
    // 个性签名
    UILabel *sLabel = [UILabel.alloc initWithFrame:CGRectMake(16, addrLabel.bottom, 94-16, 44)];
    sLabel.textColor = [UIColor colorWithHex:0x666666];
    sLabel.text = @"个性签名";
    sLabel.font = [UIFont systemFontOfSize:16];
    sLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:sLabel];
    self.sLabel = sLabel;
    self.signLabel = [UILabel.alloc initWithFrame:CGRectZero];
    self.signLabel.font = [UIFont systemFontOfSize:16];
    self.signLabel.textColor = [UIColor colorWithHex:0x333333];
    self.signLabel.numberOfLines = 0;
    self.signLabel.top = sLabel.top;
    
    [self.view addSubview:self.signLabel];
    
    if (self.type == TUserInfoVCTypeFriend) {
        [self setupFrinedUI];
        [self setupNavRightItem];
        // 多了个备注
        UILabel *reLabel = [UILabel.alloc initWithFrame:CGRectMake(16, self.userInfoCard.bottom, 94-16, 44)];
        reLabel.textColor = [UIColor colorWithHex:0x666666];
        reLabel.text = @"备注";
        reLabel.font = [UIFont systemFontOfSize:16];
        reLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:reLabel];
        self.reLabel = reLabel;
        
        self.remarkLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.remarkLabel.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.remarkLabel setTitle:self.user.remarkname forState:UIControlStateNormal];
        [self.remarkLabel setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        [self.remarkLabel setImage:[UIImage imageNamed:@"edit_remark"] forState:UIControlStateNormal];
        [self.remarkLabel verticalLayoutWithInsetsStyle:ButtonStyleRight Spacing:2];
        [self.remarkLabel sizeToFit];
        [self.remarkLabel setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
        self.remarkLabel.left = 94;
        self.remarkLabel.height = 44;
        self.remarkLabel.centerY = reLabel.centerY;
        [self.remarkLabel addTarget:self action:@selector(toModifyRemarkname) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.remarkLabel];
        // 昵称
        UILabel *niLabel = [UILabel.alloc initWithFrame:CGRectMake(16, reLabel.bottom, 94-16, 44)];
        niLabel.textColor = [UIColor colorWithHex:0x666666];
        niLabel.text = @"昵称";
        niLabel.font = [UIFont systemFontOfSize:16];
        niLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:niLabel];
        self.niLabel = niLabel;
        UILabel *nickLabel = [UILabel.alloc initWithFrame:CGRectMake(94, niLabel.top, self.view.width - 94 - 17, 44)];
        nickLabel.textColor = [UIColor colorWithHex:0x333333];
        nickLabel.font = [UIFont systemFontOfSize:16];
        nickLabel.textAlignment = NSTextAlignmentLeft;
        nickLabel.text = self.user.nick;
        [self.view addSubview:nickLabel];
    } else if (self.type == TUserInfoVCTypeAdd) {
        [self setupAddUI];
    } else if (self.type == TUserInfoVCTypeVerfiy) {
        [self setupVerfiyUI];
    } else if (self.type == TUserInfoVCTypeSelf) {
        [self setupOwnUI];
    } else {
        
    }
    
    // 刷新布局
    [self layout];
    
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.view bringSubviewToFront:self.navigationBar];
}

/// 剩余部分     好友
- (void)setupFrinedUI
{
    self.friendContentView = [UIView.alloc initWithFrame:CGRectMake(0, self.userInfoCard.bottom+121, self.view.width, self.view.height - self.userInfoCard.bottom - 121)];
    [self.view addSubview:self.friendContentView];
    
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chatButton.frame = CGRectMake(30, 0, FlexWidth(256), FlexWidth(50));
    chatButton.bottom = self.friendContentView.height - 86;
    chatButton.centerX = self.friendContentView.middleX;
    chatButton.acceptEventInterval = 0.5;
    [chatButton setBackgroundColor:[UIColor colorWithHex:0x0087FC]];
    chatButton.layer.cornerRadius = FlexWidth(50)*0.5;
    chatButton.layer.masksToBounds = YES;
    [chatButton setTitle:@"聊天" forState:UIControlStateNormal];
    [chatButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    chatButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [chatButton addTarget:self action:@selector(chatButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.friendContentView addSubview:chatButton];
    
//    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    deleteButton.viewSize = chatButton.viewSize;
//    deleteButton.top = chatButton.top;
//    deleteButton.left = FlexWidth(32);
//    deleteButton.acceptEventInterval = 0.5;
//    deleteButton.layer.cornerRadius = FlexWidth(50)*0.5;
//    deleteButton.layer.masksToBounds = YES;
//    deleteButton.backgroundColor = [UIColor colorWithHex:0xECEBEB];
//    [deleteButton setTitle:@"删除好友" forState:UIControlStateNormal];
//    [deleteButton setTitleColor:[UIColor colorWithHex:0x949494] forState:UIControlStateNormal];
//    deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
//    [deleteButton addTarget:self action:@selector(deleteButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.friendContentView addSubview:deleteButton];
}

/// 自己
- (void)setupOwnUI
{
    self.ownContentView = [UIView.alloc initWithFrame:CGRectMake(0, self.userInfoCard.bottom+121, self.view.width, self.view.height - self.userInfoCard.bottom - 121)];
    [self.view addSubview:self.ownContentView];
    
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chatButton.frame = CGRectMake(30, 0, FlexWidth(256), FlexWidth(50));
    chatButton.bottom = self.ownContentView.height - 86;
    chatButton.centerX = self.ownContentView.middleX;
    chatButton.acceptEventInterval = 0.5;
    [chatButton setBackgroundColor:[UIColor colorWithHex:0x0087FC]];
    chatButton.layer.cornerRadius = FlexWidth(50)*0.5;
    chatButton.layer.masksToBounds = YES;
    [chatButton setTitle:@"聊天" forState:UIControlStateNormal];
    [chatButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    chatButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [chatButton addTarget:self action:@selector(chatButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.ownContentView addSubview:chatButton];
}

/// 剩余部分     加好友
- (void)setupAddUI
{
    self.addContentView = [UIView.alloc initWithFrame:CGRectMake(0, self.userInfoCard.bottom+121, self.view.width, self.view.height - self.userInfoCard.bottom - 121)];
    [self.view addSubview:self.addContentView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(30, 80, FlexWidth(256), FlexWidth(50));
    button.centerX = self.addContentView.middleX;
    button.bottom = self.addContentView.height - 86;
    button.acceptEventInterval = 0.5;
    [button setBackgroundColor:[UIColor colorWithHex:0x0087FC]];
    button.layer.cornerRadius = FlexWidth(50)*0.5;
    button.layer.masksToBounds = YES;
    [button setTitle:@"添加好友" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(onAddFriend:) forControlEvents:UIControlEventTouchUpInside];
    [self.addContentView addSubview:button];
}

- (void)setupVerfiyUI
{
    self.verifyContentView = [UIView.alloc initWithFrame:CGRectMake(0, self.signLabel.bottom + 20, self.view.width, self.view.height - self.signLabel.bottom)];
    self.verifyContentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.verifyContentView];
    
    UILabel *tipLabel = [UILabel.alloc init];
    tipLabel.text = @"附加信息";
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textColor = [UIColor colorWithHex:0x888888];
    [tipLabel sizeToFit];
    tipLabel.left = 16;
    tipLabel.top = 10;
    [self.verifyContentView addSubview:tipLabel];
    
    UIView *greetBg = [UIView.alloc initWithFrame:CGRectMake(16, tipLabel.bottom+7, ScreenWidth()-32, 60)];
    greetBg.layer.cornerRadius = 4;
    greetBg.layer.masksToBounds = YES;
    greetBg.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    [self.verifyContentView addSubview:greetBg];
    
    TIOApplyUser *apply = (TIOApplyUser *)self.user;
    
//    CGSize greetLabelSize = [apply.greet boundingRectWithSize:CGSizeMake(greetBg.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    
    UILabel *greetLabel = [UILabel.alloc init];
    greetLabel.frame = CGRectMake(10, 10, greetBg.width-20, greetBg.height-20);
    greetLabel.text = apply.greet;
    greetLabel.font = [UIFont systemFontOfSize:14];
    greetLabel.textColor = [UIColor colorWithHex:0x666666];
    greetLabel.numberOfLines = 0;
    greetLabel.textAlignment = NSTextAlignmentLeft;
    [greetBg addSubview:greetLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(30, 80, FlexWidth(256), FlexWidth(50));
    button.centerX = self.verifyContentView.middleX;
    button.bottom = self.verifyContentView.height - 86;
    button.acceptEventInterval = 0.5;
    [button setBackgroundColor:[UIColor colorWithHex:0x0087FC]];
    button.layer.cornerRadius = FlexWidth(50)*0.5;
    button.layer.masksToBounds = YES;
    [button setTitle:@"同意加为好友" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(onAllowUserToBeFriend:) forControlEvents:UIControlEventTouchUpInside];
    [self.verifyContentView addSubview:button];
}

- (void)setupNavRightItem
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithImage:[[UIImage imageNamed:@"more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(toMore:)];
}

- (void)onAddFriend:(id)sender
{
    [self addUser:self.user];
}

- (void)onAllowUserToBeFriend:(id)sender
{
    TIOApplyUser *user = (TIOApplyUser *)self.user;
       
    NSString *title = [user.nick stringByAppendingString:@"\n\n设置备注"];
   
    TInputAlertController *alert = [TInputAlertController alertWithTitle:title placeholder:@"" inputHeight:44
                                                              inputStyle:TAlertInputStyleTextField];
    alert.text = user.nick;
   
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }];
        
        action;
    })];
   
    [alert addAction:({
        TAlertAction *action = [TAlertAction actionWithTitle:@"同意" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
           [self allowApply:[NSString stringWithFormat:@"%zd",user.applyId] remarkname:alert.text];
        }];
       
        action;
    })];
   
   [self presentViewController:alert animated:YES completion:nil];
}

- (void)allowApply:(NSString *)uid remarkname:(NSString *)remarkname
{
    TIOFriendRequest *request = [TIOFriendRequest.alloc init];
    request.userId = uid;
    request.operation = TIOFriendOperationAdopt;
    request.message = remarkname;
    
    [TIOChat.shareSDK.friendManager handleApply:request completion:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        } else {
            [MBProgressHUD showInfo:@"添加成功" toView:self.view];
            // 刷新数据
            [self setupFrinedUI];
            self.verifyContentView.hidden = YES;
        }
    }];
}

- (void)toModifyRemarkname
{
    TEdittingViewController *vc = [TEdittingViewController.alloc initWithTitle:@"修改备注" text:self.user.remarkname inputType:TEdittingInputTypeField];
    vc.maxNumber = 30;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)chatButtonDidClicked:(id)sender
{
    if (self.chatClicked) {
        self.chatClicked(self, nil);
        return;
    }
    
    // 获取会话ID
    [TIOChat.shareSDK.conversationManager fetchSessionId:TIOSessionTypeP2P
                                              friendId:self.user.userId
                                            completion:^(NSError * _Nullable error, TIORecentSession * _Nullable recentSession) {
        if (error) {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            // 跳转聊天
            TIOSession *session = recentSession.session;
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:session forKey:@"session"];
//            [CTMediator.sharedInstance T_remoteToP2PSessionVC:params fromVC:self];
            UIViewController *vc = [CTMediator.sharedInstance T_P2PViewController:params];
            [self.navigationController pushViewController:vc animated:YES];
            
            // 从群聊页返回一级页面
            UIViewController *firstVC = self.navigationController.viewControllers.firstObject;
            [vc.navigationController setViewControllers:@[firstVC,vc]];
        }
    }];
}

- (void)deleteButtonDidClicked:(id)sender
{
    // 删除好友
    
    [self presentViewController:({
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"确认删除该好友？" message:@"同时删除与TA的所有聊天记录" preferredStyle:TAlertControllerStyleAlert];
        
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        
        [alert addAction:[TAlertAction actionWithTitle:@"删除" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            // SDK API
            [TIOChat.shareSDK.friendManager deleteFriend:self.user.userId
                                              completion:^(NSError * _Nullable error) {
                if (error) {
                    DDLogError(@"%@",error);
                } else {
                    [self.navigationController popToRootViewControllerAnimated:false];
                }
            }];
        }]];
        
        alert;
    }) animated:YES completion:nil];
}

- (void)requestUserInfoData
{
    [TIOChat.shareSDK.friendManager fetchUserInfo:self.user.userId
                                       completion:^(TIOUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            if (user.province) {
                self.addressLabel.text = user.province;
                if (user.city) {
                    [self.addressLabel.text stringByAppendingFormat:@" %@",user.city];
                }
            } else {
                self.addressLabel.text = @"中国";
            }
            [self refreshSign:user.sign.length?user.sign:@"ta还没有个性签名"];
            if (self.type == TUserInfoVCTypeFriend) {
                [self refreshRemarkname:user.remarkname];
                // 获取拉黑状态
                [TIOChat.shareSDK.friendManager fetchBlackStatusToUserId:self.user.userId completion:^(BOOL black) {
                    self.addedBlackList = black;
                }];
            }
        }
    }];
}

- (void)refreshRemarkname:(NSString *)remarkname
{
    [self.nickLabel setText:remarkname.length?remarkname:self.user.nick];
    [self.remarkLabel setTitle:remarkname forState:UIControlStateNormal];
    [self.remarkLabel verticalLayoutWithInsetsStyle:ButtonStyleRight Spacing:2];
    [self.remarkLabel sizeToFit];
    [self layout];
//    self.remarkLabel.centerX = self.userInfoCard.middleX;
}

- (void)refreshSign:(NSString *)sign
{
    self.signLabel.text = sign;
    [self.signLabel sizeToFit];
    if (self.signLabel.width > (ScreenWidth() - 94 - 17)) {
        CGSize size = [sign boundingRectWithSize:CGSizeMake(ScreenWidth() - 94 - 17, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName: self.signLabel.font} context:nil].size;
        self.signLabel.viewSize = size;
    }
    [self layout];
}

- (void)toMore:(id)sender
{
    TAlertController *alert = [TAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:TAlertControllerStyleActionSheet];
    
    NSString *string = self.addedBlackList ? @"移除黑名单" : @"加入黑名单";
    
    [alert addAction:[TAlertAction actionWithTitle:string style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
        if (self.addedBlackList) {
            [self removeFromBlackList];
        } else {
            [self addToBlckList];
        }
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"删除好友" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
        [self deleteButtonDidClicked:nil];
        
    }]];
    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleWhite handler:^(TAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addToBlckList
{
    [self presentViewController:({
        TAlertController *alert = [TAlertController alertControllerWithTitle:@"确认将对方加入黑名单？" message:@"加入黑名单后，您将不会收到对方消息" preferredStyle:TAlertControllerStyleAlert];
        
        [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
            
        }]];
        
        [alert addAction:[TAlertAction actionWithTitle:@"拉黑" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
            // SDK API
            [TIOChat.shareSDK.friendManager addToBlackList:self.user.userId completion:^(NSError * _Nullable error) {
                if (error) {
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                } else {
                    [MBProgressHUD showInfo:@"已添加至黑名单，您将不再接受对方消息" toView:self.view];
                    self.addedBlackList = YES;
                }
            }];
        }]];
        
        alert;
    }) animated:YES completion:nil];
}

- (void)removeFromBlackList
{
    [TIOChat.shareSDK.friendManager removeFromBlackList:self.user.userId completion:^(NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            [MBProgressHUD showInfo:@"已经移除黑名单" toView:self.view];
            self.addedBlackList = NO;
        }
    }];
}

#pragma mark - 手势

- (void)avatarGesture:(id)sender
{
    self.preview = [UIView.alloc initWithFrame:self.view.bounds];
    self.preview.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.preview];
    
    UIImageView *imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, (self.preview.height - self.preview.width)*0.5, self.preview.width, self.preview.width)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatar]];
    [self.preview addSubview:imageView];
    
    self.preview.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.preview.alpha = 0.1;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.preview.transform = CGAffineTransformIdentity;
        self.preview.alpha = 1;
    }];
    
    [self.preview addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(previewGesture:)]];
}

- (void)previewGesture:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.preview.transform = CGAffineTransformMakeScale(0.01, 0.01);
        self.preview.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self.preview removeFromSuperview];
    }];
}

#pragma mark - TEdittingViewControllerDelegate

- (void)t_edittingViewController:(TEdittingViewController *)edittingViewController didFinishedText:(NSString *)text handler:(TEdittingHandler)handler
{
    [TIOChat.shareSDK.friendManager updateRemark:text uid:self.user.userId completion:^(NSError * _Nullable error) {
        if (error)
        {
            handler(NO, error.localizedDescription);
        }
        else
        {
            handler(YES, @"备注已更新");
            [self refreshRemarkname:text];
            self.user.remarkname = text;
            [edittingViewController.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - 工厂

- (UIView *)viewWithFrame:(CGRect)frame title:(NSString *)title subTitle:(NSString *)subTitle hasIndiractor:(BOOL)hasIndiractor selector:(nullable SEL)selector subLabel:( UILabel * _Nullable *)subTitleLabel;
{
    UIView *view = [UIView.alloc initWithFrame:frame];
    view.backgroundColor = UIColor.whiteColor;
    view.layer.cornerRadius = 14;
    view.layer.masksToBounds = YES;
    
    UILabel *titleLabel = [UILabel.alloc init];
    titleLabel.text = title;
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel sizeToFit];
    titleLabel.left = 30;
    titleLabel.centerY = view.middleY;
    [view addSubview:titleLabel];
    
    UILabel *subLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, view.width*0.5, 22)];
    subLabel.text = subTitle;
    subLabel.textColor = [UIColor colorWithHex:0x909090];
    subLabel.font = [UIFont systemFontOfSize:14];
    subLabel.textAlignment = NSTextAlignmentRight;
    subLabel.centerY = view.middleY;
    subLabel.right = view.width - 24;
    [view addSubview:subLabel];
    
    if (subTitleLabel) {
        *subTitleLabel = subLabel;
    }
    
    if (hasIndiractor) {
        UIImageView *indiractor = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"forward"]];
        [indiractor sizeToFit];
        indiractor.centerY = view.middleY;
        indiractor.right = view.width - 24;
        [view addSubview:indiractor];
        
        subLabel.right = indiractor.left - 8;
    }
    
    if (selector) {
        UITapGestureRecognizer *tap = [UITapGestureRecognizer.alloc initWithTarget:self action:selector];
        [view addGestureRecognizer:tap];
    }
    
    return view;
}

#pragma mark - 添加好友的步骤和流程

#pragma mark - 第一步 ： 先判断检测对方是不是已经是好友
/// 检测是否可以添加
/// @param user 对方
- (void)addUser:(TIOUser *)user
{
    [TIOChat.shareSDK.friendManager isMyFriend:user.userId
                                    completion:^(BOOL isFriend, NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        } else {
            if (isFriend) {
                [MBProgressHUD showInfo:@"对方已经是你的好友了" toView:self.view];
            } else {
                [self checkUserCondition:user.userId];
            }
        }
    }];
}

#pragma mark - 第二步 : 检查对方的加好友权限：无条件加好友还是需要验证信息

/// 检查对方设置的添加条件
/// @param uid 对方UID
- (void)checkUserCondition:(NSString *)uid
{
    [TIOChat.shareSDK.friendManager checkAddConditionWithUid:uid
                                                  completion:^(NSInteger condition, NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@",error);
        } else {
            [self requestToAddUser:condition uid:uid];
        }
    }];
}

#pragma mark - 第三步 : 发起加好友的操作

/// SDK添加API
/// @param condition 添加条件
- (void)requestToAddUser:(NSInteger)condition uid:(NSString *)uid
{
    if (condition == 1) {
        // 需申请
        
        NSString *nick = [TIOChat.shareSDK.loginManager userInfo].nick;
        
        NSString *text = [NSString stringWithFormat:@"我是 %@",nick];
        
        TInputAlertController *alert = [TInputAlertController alertWithTitle:@"添加好友" placeholder:@"请输入验证信息" inputHeight:84 inputStyle:TAlertControllerTextView];
        alert.text = text; // 默认文本
        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {

            }];

            action;
        })];

        [alert addAction:({
            TAlertAction *action = [TAlertAction actionWithTitle:@"申请" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                // SDK API
                TIOFriendRequest *request = [TIOFriendRequest.alloc init];
                request.message = alert.text;
                request.operation = TIOFriendOperationRequest;
                request.userId = uid;
                
                [TIOChat.shareSDK.friendManager addFrinend:request
                                                completion:^(NSError * _Nullable error) {
                    if (error) {
                        DDLogError(@"%@",error);
                    } else {
                        [MBProgressHUD showInfo:@"已发送申请，等待对方同意" toView:self.view];
                    }
                }];
            }];

            action;
        })];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        // 无条件添加
        TIOFriendRequest *request = [TIOFriendRequest.alloc init];
        request.operation = TIOFriendOperationAdd;
        request.userId = uid;
        
        [TIOChat.shareSDK.friendManager addFrinend:request
                                        completion:^(NSError * _Nullable error) {
            if (error) {
                DDLogError(@"%@",error);
            } else {
                [MBProgressHUD showInfo:@"成功添加好友" toView:self.view];
                [self setupFrinedUI];
                self.addContentView.hidden = YES;
            }
        }];
    }
}


@end
