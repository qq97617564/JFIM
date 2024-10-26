//
//  TInviteReviewViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/2/8.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TReviewInvitationViewController.h"
#import "FrameAccessor.h"
#import "TInvitedUserCell.h"
#import "TReviewInvitationHeader.h"
#import "UIImageView+Web.h"
#import "NSString+tio.h"
#import "UIImage+TColor.h"
#import "MBProgressHUD+NJ.h"
#import "CTMediator+ModuleActions.h"

@interface TReviewInvitationViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak,    nonatomic) UICollectionView *collectionView;
@property (strong,  nonatomic) NSArray *dataArray;
@property (strong,  nonatomic) TIOInvitationApply *applyInfor;
@property (weak,    nonatomic) UIButton *ignoreButton;
@property (weak,    nonatomic) UIButton *agreeButton;
@property (weak,    nonatomic) UIView *bottomView;
@end

@implementation TReviewInvitationViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBarButtonText = @"群聊邀请";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self requestData];
}

- (void)setupUI
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout.alloc init];
    layout.sectionHeadersPinToVisibleBounds = NO;

    UICollectionView *collectionview = [[UICollectionView alloc]initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height-Height_NavBar-114) collectionViewLayout:layout];
    collectionview.backgroundColor = UIColor.whiteColor;
    collectionview.delegate = self;
    collectionview.dataSource = self;
    [collectionview registerClass:[TReviewInvitationHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TReviewInvitationHeader"];
    [collectionview registerClass:[TInvitedUserCell class] forCellWithReuseIdentifier:@"TInvitedUserCell"];
    [self.view addSubview:collectionview];
    self.collectionView = collectionview;
    
    
    /**
     * 忽略+同意邀请
     */
    UIView *bottomView = [UIView.alloc initWithFrame:CGRectMake(0, self.view.height-114, self.view.width, 114)];
    bottomView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    
    UIView *line = [UIView.alloc initWithFrame:CGRectMake(0, 0, bottomView.width, 1)];
    line.backgroundColor = [UIColor colorWithHex:0xF1F1F1];
    [bottomView addSubview:line];
    
    if ([self.message.apply[@"status"] isEqualToNumber:@(1)]) {
        UIButton *agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        agreeButton.viewSize = CGSizeMake(140, 50);
        agreeButton.center = bottomView.middlePoint;
        UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:agreeButton.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x0087FC]]];
        UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:agreeButton.bounds andColors:@[[UIColor colorWithHex:0xA3C6F9],[UIColor colorWithHex:0x84B5FF]]];
        [agreeButton setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:25 size:agreeButton.viewSize] forState:UIControlStateNormal];
        [agreeButton setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:25 size:agreeButton.viewSize] forState:UIControlStateHighlighted];
        [agreeButton setTitle:@"已同意" forState:UIControlStateNormal];
        [agreeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        agreeButton.enabled = NO;
        [agreeButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:agreeButton];
    } else {
        UIButton *ignoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        ignoreButton.viewSize = CGSizeMake(140, 50);
        ignoreButton.left = (bottomView.width-280)/3.f;
        ignoreButton.centerY = bottomView.middleY;
        [ignoreButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0xECEBEB]] imageWithCornerRadius:25 size:ignoreButton.viewSize] forState:UIControlStateNormal];
        [ignoreButton setTitle:@"忽略" forState:UIControlStateNormal];
        [ignoreButton setTitleColor:[UIColor colorWithHex:0x949494] forState:UIControlStateNormal];
        [ignoreButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [ignoreButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:ignoreButton];
        self.ignoreButton = ignoreButton;
        
        UIButton *agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        agreeButton.viewSize = CGSizeMake(140, 50);
        agreeButton.left = ignoreButton.right + (bottomView.width-280)/3.f;
        agreeButton.centerY = bottomView.middleY;
        UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:agreeButton.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x0087FC]]];
        UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:agreeButton.bounds andColors:@[[UIColor colorWithHex:0xA3C6F9],[UIColor colorWithHex:0x84B5FF]]];
        [agreeButton setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:25 size:agreeButton.viewSize] forState:UIControlStateNormal];
        [agreeButton setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:25 size:agreeButton.viewSize] forState:UIControlStateHighlighted];
        [agreeButton setTitle:@"同意邀请" forState:UIControlStateNormal];
        [agreeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [agreeButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:agreeButton];
        self.agreeButton = agreeButton;
    }
}

- (void)requestData
{
    CBWeakSelf
    [TIOChat.shareSDK.teamManager fetchApplyInfoForInviting:self.applyId.stringValue completion:^(TIOInvitationApply * _Nullable applyInfor, NSArray<TIOUser *> * _Nullable users, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        self.applyInfor = applyInfor;
        self.dataArray = users;
        [self.collectionView reloadData];
    }];
}

#pragma mark - actions

- (void)confirm:(id)sender
{
    [TIOChat.shareSDK.teamManager dealApplyForInviting:self.applyId.stringValue messageId:self.message.messageId completion:^(NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            self.ignoreButton.hidden = YES;
            self.agreeButton.centerX = self.bottomView.middleX;
            self.agreeButton.enabled = NO;
            [self.agreeButton setTitle:@"已同意" forState:UIControlStateNormal];
            
            if (self.onClick) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:self.message.apply];
                tempDict[@"status"] = @(1);
                self.message.apply = tempDict;
                self.onClick(self.message);
            }
        }
    }];
}

#pragma mark - 跳转到用户主页

/// 跳转指定用户的主页
/// @param targetUserId 目标用户ID
/// @param preUserInfo 有值直接传到下一页，不用获取用户信息
- (void)jumpToUserhome:(NSString *)targetUserId userInfo:(TIOUser *)preUserInfo
{
    // 可能已经解除好友关系 但是会话还在，查看的对方信息主页就会不一样
    // 所以 先验证是不是好友
    CBWeakSelf
    [TIOChat.shareSDK.friendManager isMyFriend:targetUserId
                                    completion:^(BOOL isFriend, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        if (error)
        {
            DDLogError(@"%@",error);
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        }
        else
        {
            // 预处理Block
            void (^jumpToUserInfoVCBlock)(TIOUser *userInfo, NSInteger type) = ^(TIOUser *userInfo, NSInteger type) {
                
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
                    
                params[@"user"] = userInfo;
                params[@"type"] = @(type); // 好友
                    
                UIViewController *homePageVC = [CTMediator.sharedInstance T_userHomePageViewController:params];
                [self.navigationController pushViewController:homePageVC animated:YES];
            };
            

            // 获取用户信息，再执行block跳转
            [TIOChat.shareSDK.friendManager fetchUserInfo:targetUserId completion:^(TIOUser * _Nullable user, NSError * _Nullable error) {
                if (error)
                {
                    DDLogError(@"%@",error);
                    [MBProgressHUD showError:error.localizedDescription toView:self.view];
                }
                else
                {
                    jumpToUserInfoVCBlock(user, isFriend?1:3);
                }
            }];
        }
    }];
}

#pragma mark - UICollectionView

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TIOUser *user = self.dataArray[indexPath.row];
    TInvitedUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TInvitedUserCell" forIndexPath:indexPath];
    cell.model = user;
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TIOUser *user = [self.dataArray objectAtIndex:indexPath.row];
    [self jumpToUserhome:user.userId userInfo:nil];
}

#pragma mark - UICollectionViewLayout

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        TReviewInvitationHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TReviewInvitationHeader" forIndexPath:indexPath];
        if (self.applyInfor) {
            [view.imageView tio_imageUrl:self.applyInfor.groupavator.tio_resourceURLString placeHolderImageName:@"avatar_placeholder" radius:4];
            view.nickLabel.text = self.applyInfor.groupnick;
            view.countLabel.text = [NSString stringWithFormat:@"邀请%zd位朋友进群",self.dataArray.count];
            view.applyMsgLabel.text = self.applyInfor.applymsg;
        }
        
        return view;
    } else {
        return nil;
    }
}

/// 头的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(CB_SCREEN_WIDTH, 218);
}
/// item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 80);
}
/// 最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 16;
}
/// 最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 16;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(12, 16, 0, 16);
}

@end
