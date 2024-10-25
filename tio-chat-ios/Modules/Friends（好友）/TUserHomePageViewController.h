//
//  TUserInfoViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class TIOUser;

typedef NS_ENUM(NSUInteger, TUserHomePageType) {
    TUserInfoVCTypeSelf     =   0,  ///< 自己
    TUserInfoVCTypeFriend   =   1,  ///< 自己的好友
    TUserInfoVCTypeVerfiy   =   2,  ///< 审核好友申请
    TUserInfoVCTypeAdd      =   3,  ///< 自己主动搜索要添加的
};


/// 用户信息页
@interface TUserHomePageViewController : TCBaseViewController

- (instancetype)initWithUser:(TIOUser *)user type:(TUserHomePageType)type;

@property (copy, nonatomic) ModuleCallback chatClicked;

@end

NS_ASSUME_NONNULL_END
