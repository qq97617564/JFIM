//
//  NWWaterListPage.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/2.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "JXCategoryListContainerView.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface NWWaterListPage : TCBaseViewController <JXCategoryListContentViewDelegate>
@property (assign,  nonatomic) TIOWalletWaterRequestType waterRequestType;
@end

NS_ASSUME_NONNULL_END
