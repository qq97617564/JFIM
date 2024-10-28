//
//  TTeamModifyNickViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamModifyNickViewController.h"
#import "FrameAccessor.h"
#import "MBProgressHUD+NJ.h"

@interface TTeamModifyNickViewController ()
@property (nonatomic, weak) UITextField *inputView;
@property (nonatomic, strong) TIOTeamMember *member;
@end

@implementation TTeamModifyNickViewController

- (instancetype)initWithTitle:(NSString *)title member:(nonnull TIOTeamMember *)member
{
    self = [super init];
    if (self) {
        self.title = title;
        self.member = member;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    [self setupNav];
    
    UITextField *inputView = [UITextField.alloc initWithFrame:CGRectMake(0, Height_NavBar + 16, self.view.width, 48)];
    inputView.backgroundColor = UIColor.whiteColor;
    inputView.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 16, inputView.height)];
    inputView.leftViewMode = UITextFieldViewModeAlways;
    inputView.rightViewMode = UITextFieldViewModeWhileEditing;
    inputView.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputView.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    inputView.textColor = UIColor.blackColor;
    inputView.text = self.member.groupNick;
    [self.view addSubview:inputView];
    self.inputView = inputView;
}

- (void)setupNav
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor colorWithHex:0x0087FC]];
        [button setTitle:@"提交" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        button.viewSize = CGSizeMake(55, 31);
        button.layer.cornerRadius = 6;
        button.layer.masksToBounds = YES;
        
        [button addTarget:self action:@selector(didClickDone:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
}

- (void)didClickDone:(id)sender
{
    if (!self.inputView.text.length) {
        return;
    }
    if (self.type == 1){
        [TIOChat.shareSDK.teamManager updateTeamName:self.inputView.text inTeam:self.member.groupId completion:^(NSError * _Nullable error) {
            if (!error) {
                [MBProgressHUD showSuccess:@"修改成功" toView:self.view];
                if ([self.delegate respondsToSelector:@selector(shouldUpdateText:)]) {
                    [self.delegate shouldUpdateText:self.inputView.text];
                }
            }
        }];
        return;
    }
    
    [TIOChat.shareSDK.teamManager updateUserNick:self.inputView.text inTeam:self.member.groupId completion:^(NSError * _Nullable error) {
        if (error)
        {
            DDLogError(@"%@",error);
        }
        else
        {
            [MBProgressHUD showInfo:@"修改成功" toView:self.view];
            if ([self.delegate respondsToSelector:@selector(shouldUpdateText:)]) {
                [self.delegate shouldUpdateText:self.inputView.text];
            }
        }
    }];
}

@end
