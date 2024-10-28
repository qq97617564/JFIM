//
//  TTeamModifyIntroViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamModifyIntroViewController.h"
#import "FrameAccessor.h"
#import "MBProgressHUD+NJ.h"

@interface TTeamModifyIntroViewController ()
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, strong) TIOTeam *team;
@property (nonatomic, assign) TTeamModifyIntroType type;

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation TTeamModifyIntroViewController

- (instancetype)initWithTitle:(NSString *)title team:(nonnull TIOTeam *)team type:(TTeamModifyIntroType)type
{
    self = [super init];
    if (self) {
        self.title = title;
        self.team = team;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self setupUI];
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    [self setupSeeUI];
    
    if (self.type == TTeamModifyIntroTypeIntro || self.type == TTeamModifyIntroTypeNotice) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithImage:[[UIImage imageNamed:@"edit_team_notice"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(editContent:)];
    }
}

- (void)setupUI
{
    [self setupNav];
    
    UITextView *textView = [UITextView.alloc initWithFrame:CGRectMake(0, Height_NavBar + 20, self.view.width, 300)];
    textView.backgroundColor = UIColor.whiteColor;
    textView.text = self.type==TTeamModifyIntroTypeIntro?self.team.intro:self.team.notice;
    textView.textContainerInset = UIEdgeInsetsMake(12, 16, 12, 16);
    textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:textView];
    self.textView = textView;
    
    [self.textView becomeFirstResponder];
}

/// 只能看
- (void)setupSeeUI
{
    
    UIScrollView *scrollView = [UIScrollView.alloc initWithFrame:CGRectMake(0, Height_NavBar + 20, self.view.width, self.view.height - Height_NavBar - 20)];
    scrollView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    NSLog(@"\nintro = %@\nnotice = %@", self.team.intro, self.team.notice);
    NSString *text = (self.type==TTeamModifyIntroTypeIntro || self.type == TTeamSeeIntroTypeIntro)?self.team.intro:self.team.notice;
//    CGSize size = [text boundingRectWithSize:CGSizeMake(self.view.width-32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
    
    UITextView *textView = [UITextView.alloc initWithFrame:CGRectMake(16, 12, scrollView.width - 32, 0)];
    textView.text = text;
    textView.font = [UIFont systemFontOfSize:16];
    textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [textView sizeToFit];
    textView.height += 2;
    [scrollView addSubview:textView];
    
    UILabel *bottomLabel = [UILabel.alloc initWithFrame:CGRectMake(0, textView.bottom+16, 200, 17)];
    bottomLabel.text = @"-仅群主和管理员可以修改-";
    bottomLabel.textColor = [UIColor colorWithHex:0xCDD0D3];
    bottomLabel.font = [UIFont systemFontOfSize:12];
    [bottomLabel sizeToFit];
    bottomLabel.centerX = scrollView.middleX;
    bottomLabel.top = textView.bottom+16;
    [scrollView addSubview:bottomLabel];
    
    scrollView.contentSizeHeight = bottomLabel.bottom;
}

/// 编辑页面
- (void)setupEditUI
{
    
}

- (void)setupNav
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor colorWithHex:0x4C94FF]];
        [button setTitle:@"提交" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.viewSize = CGSizeMake(60, 30);
        
        [button addTarget:self action:@selector(didClickDone:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
}

- (void)didClickDone:(id)sender
{
    if (!self.textView.text.length) {
        self.textView.text = @"";
    }
    
    [MBProgressHUD showMessage:@"正在提交..." toView:self.view];
    
    if (self.type == TTeamModifyIntroTypeIntro) {
        
        [TIOChat.shareSDK.teamManager updateTeamIntro:self.textView.text
                                               inTeam:self.team.teamId
                                           completion:^(NSError * _Nullable error) {
           
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (error)
            {
                DDLogError(@"%@",error);
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
            else
            {
                [MBProgressHUD showSuccess:@"修改完成" toView:self.view];
                if (@protocol(TTeamModifyIntroViewControllerDelegate) && [self.delegate respondsToSelector:@selector(didUpdateIntro:type:)]) {
                    [self.delegate didUpdateIntro:self.textView.text type:self.type];
                }
            }
        }];
    }
    else
    {
        [TIOChat.shareSDK.teamManager updateTeamNotice:self.textView.text
                                                inTeam:self.team.teamId
                                            completion:^(NSError * _Nullable error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (error)
            {
                DDLogError(@"%@",error);
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            }
            else
            {
                [MBProgressHUD showSuccess:@"修改完成" toView:self.view];
                if (@protocol(TTeamModifyIntroViewControllerDelegate) && [self.delegate respondsToSelector:@selector(didUpdateIntro:type:)]) {
                    [self.delegate didUpdateIntro:self.textView.text type:self.type];
                }
            }
        }];
    }
}

- (void)editContent:(UIBarButtonItem *)barButtonItem
{
    [self.scrollView removeFromSuperview];
    [self setupUI];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textView resignFirstResponder];
}

@end
