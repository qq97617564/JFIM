//
//  TCContentBaseViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "JXCategoryView.h"
#import "JXCategoryListContainerView.h"

NS_ASSUME_NONNULL_BEGIN

#define WindowsSize [UIScreen mainScreen].bounds.size

@interface TCContentBaseViewController : TCBaseViewController <JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) JXCategoryBaseView *categoryView;

@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, assign) BOOL isNeedIndicatorPositionChangeItem;

- (JXCategoryBaseView *)preferredCategoryView;

- (CGFloat)preferredCategoryViewHeight;

@end

NS_ASSUME_NONNULL_END
