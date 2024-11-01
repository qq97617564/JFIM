//
//  TCSearchViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSearchViewController.h"
#import "TSearchAllViewController.h"
#import "TSearchTeamsViewController.h"
#import "TSearchFriendListViewController.h"
#import "SearchAllResult.h"
/// common
#import "JXCategoryTitleView.h"
#import "MBProgressHUD+NJ.h"
#import "FrameAccessor.h"
/// SDK
#import "ImportSDK.h"


@interface TSearchViewController ()
@property (nonatomic, strong) JXCategoryTitleView *myCategoryView;
@property (nonatomic, strong) NSArray *allResults;
@property (nonatomic, copy) NSString *searchKey;
@end

@implementation TSearchViewController

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"SearchToSelectedVC" object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titles = @[@"全部",@"好友",@"群组"];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.myCategoryView.titles = self.titles;
    
    [self setupUI];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(toScrollToCategoryVC:) name:@"SearchToSelectedVC" object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)setupUI
{
    [self addNaivigationBar];
    
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorWidth = 17;
    lineView.indicatorHeight = 2;
    lineView.indicatorColor = [UIColor colorWithHex:0x0087FC];
    self.myCategoryView.indicators = @[lineView];
    self.myCategoryView.titleColorGradientEnabled = YES;
    self.myCategoryView.cellWidthZoomEnabled = YES;
    self.myCategoryView.cellWidthZoomScale = 1;
    self.myCategoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleBottom;
    self.myCategoryView.selectedAnimationEnabled = YES;
    self.myCategoryView.titleLabelZoomSelectedVerticalOffset = 0;
    self.myCategoryView.titleSelectedFont = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.myCategoryView.titleSelectedColor = [UIColor colorWithHex:0x0087FC];
    self.myCategoryView.titleFont = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.myCategoryView.titleColor = [UIColor colorWithHex:0x888888];
    self.myCategoryView.titles = self.titles;
    // 默认隐藏结果
//    [self hideResultView];
}

- (void)addNaivigationBar
{
    UITextField *searchField = [UITextField.alloc initWithFrame:CGRectMake(16, Height_StatusBar + 4, self.view.width - 16 - 60, 36)];
    searchField.leftViewMode = UITextFieldViewModeAlways;
    searchField.leftView = ({
        UIView *leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 38, searchField.height)];
        
        UIImageView *icon = [UIImageView.alloc initWithFrame:CGRectZero];
        icon.image = [UIImage imageNamed:@"searchbar"];
        [icon sizeToFit];
        icon.right = leftView.width;
        icon.centerY = leftView.middleY;
        [leftView addSubview:icon];
        
        leftView;
    });
    searchField.rightViewMode = UITextFieldViewModeWhileEditing;
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
    searchField.layer.cornerRadius = 4;
    searchField.layer.masksToBounds = YES;
    searchField.textColor = [UIColor blackColor];
    searchField.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    searchField.returnKeyType = UIReturnKeySearch;
    [searchField addTarget:self action:@selector(toSearch:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.navigationBar addSubview:searchField];
    [searchField becomeFirstResponder];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(searchField.right, Height_StatusBar, 60, 44);
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithHex:0x0087FC] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(toCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:cancelButton];
}

#pragma mark - 控制搜索结果分页显示隐藏

- (void)showResultView
{
    self.categoryView.hidden = NO;
    self.listContainerView.hidden = NO;
}

- (void)hideResultView
{
    self.categoryView.hidden = YES;
    self.listContainerView.hidden = YES;
}

#pragma mark -

/// 收到“全部分页”发来的通知 滚动到指定分页
- (void)toScrollToCategoryVC:(NSNotification *)notification
{
    NSNumber *index = notification.userInfo[@"index"];
    
    [self.categoryView selectItemAtIndex:index.integerValue];
}

#pragma mark - SearchField

- (void)textFieldEditing:(UITextField *)textField {}

- (void)toSearch:(UITextField *)textfield
{
    // 重复搜索
    if (![textfield.text isEqualToString:[NSUserDefaults.standardUserDefaults objectForKey:@"searchText"]]) {
        // 清空上一次搜索
        [NSNotificationCenter.defaultCenter postNotificationName:@"CBClearSearchResult" object:nil];
    }
    
    __block SearchAllResult* friendResults   = nil;
    __block SearchAllResult* teamResults     = nil;
    
    CBWeakSelf
    
    dispatch_group_t group = dispatch_group_create();
    // 搜索好友
    dispatch_group_enter(group);
    
    TIOSearchOption *option = [TIOSearchOption.alloc init];
    option.searchText = textfield.text; // 搜索内容
    option.scope = TIOSearchContentScopeFriend;
    
    [TIOChat.shareSDK.friendManager searchFrinedsWithOption:option completion:^(NSArray<TIOUser *> * _Nullable users, BOOL firstPage, BOOL lastPage, NSInteger total, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (!error) {
            
            if (users.count == 0) {
                // 隐藏结果分页
                [self hideResultView];
            } else {
                // 显示结果分页
                [self showResultView];
                // 记录当前的searchKey
                self.searchKey = textfield.text;
                
                // 构造好友分类的数据源
                SearchAllResult *result = [SearchAllResult resultWithChildList:users showNumber:3 index:1 title:@"好友" moreTitle:@"更多好友" identifier:@"TSearchFriendCell"];
                
                friendResults = result;
            }
            
        }
        
        dispatch_group_leave(group);
        
    }];
    // 搜索群聊
    dispatch_group_enter(group);
    
    [TIOChat.shareSDK.teamManager searchMyTeamsWithKey:textfield.text
                                            completion:^(NSArray<TIOTeam *> * _Nullable teams, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (!error)
        {
            
            if (teams.count == 0) {
                // 隐藏结果分页
                [self hideResultView];
            } else {
                // 显示结果分页
                [self showResultView];
                // 记录当前的searchKey
                self.searchKey = textfield.text;
                
                // 构造群聊分类的数据源
                
                SearchAllResult *result = [SearchAllResult resultWithChildList:teams showNumber:3 index:2 title:@"群聊" moreTitle:@"更多群聊" identifier:@"TSearchFriendCell"];
                
                teamResults = result;
            }
            
        }
        dispatch_group_leave(group);
        
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSMutableArray *array = [NSMutableArray array];
        if (friendResults) {
            [array addObject:friendResults];
        }
        if (teamResults) {
            [array addObject:teamResults];
        }
        
        self.allResults = array;
        
        if (!friendResults && !teamResults) {
            [self hideResultView];
        } else {
            // 显示
            [self resultIsNotEmpty];
                           
            [NSUserDefaults.standardUserDefaults setObject:textfield.text forKey:@"searchText"];
        }
        
    });
}

- (void)resultIsNotEmpty
{
    [self.myCategoryView selectItemAtIndex:0];
    TSearchResultViewController *vc = (TSearchResultViewController *)self.listContainerView.validListDict[@(0)].listViewController;
    [vc refreshWithData:self.allResults];
    vc.searchKey = self.searchKey;
}

- (void)toCancel:(id)sender
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"searchText"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - overwrite

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index
{
    TSearchResultViewController *vc = nil;
    if (index == 0) {
        vc = [TSearchAllViewController.alloc init];
    } else if (index == 1) {
        vc = [TSearchFriendListViewController.alloc init];
    } else {
        vc = [TSearchTeamsViewController.alloc init];
    }
    [vc refreshWithData:self.allResults];
    
    return vc;
}

- (JXCategoryTitleView *)myCategoryView {
    return (JXCategoryTitleView *)self.categoryView;
}

- (JXCategoryBaseView *)preferredCategoryView {
    return [[JXCategoryTitleView alloc] init];
}

@end
