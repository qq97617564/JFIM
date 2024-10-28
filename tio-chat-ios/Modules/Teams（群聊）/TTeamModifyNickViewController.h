//
//  TTeamModifyNickViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTeamModifyNickViewControllerDelegate <NSObject>
- (void)shouldUpdateText:(NSString *)text;
@end

/// 修改昵称页面
@interface TTeamModifyNickViewController : TCBaseViewController

- (instancetype)initWithTitle:(NSString *)title member:(TIOTeamMember *)member;
/// 1群名称 默认群昵称
@property (assign, nonatomic)NSInteger type;
@property (assign, nonatomic) id<TTeamModifyNickViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
