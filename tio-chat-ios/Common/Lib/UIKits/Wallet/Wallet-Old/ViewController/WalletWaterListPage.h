//
//  WalletDetailPage.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "JXCategoryListContainerView.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 钱包流水分页
@interface WalletWaterListPage : TCBaseViewController <JXCategoryListContentViewDelegate>

@property (assign,  nonatomic) TIOWalletWaterRequestType waterRequestType;

@end

NS_ASSUME_NONNULL_END
