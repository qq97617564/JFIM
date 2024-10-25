//
//  TTeamModifyIntroViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TTeamModifyIntroType) {
    TTeamModifyIntroTypeIntro,  ///< 修改群简介
    TTeamModifyIntroTypeNotice, ///< 修改群公告
    TTeamSeeIntroTypeIntro,     ///< 查看群简介
    TTeamSeeIntroTypeNotice,     ///< 查看群公告
};

@protocol TTeamModifyIntroViewControllerDelegate <NSObject>
- (void)didUpdateIntro:(NSString *)text type:(TTeamModifyIntroType)type;
@end

/// 修改群简介群公告页
@interface TTeamModifyIntroViewController : TCBaseViewController

- (instancetype)initWithTitle:(NSString *)title
                         team:(TIOTeam *)team
                         type:(TTeamModifyIntroType)type;

@property (assign, nonatomic) id<TTeamModifyIntroViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
