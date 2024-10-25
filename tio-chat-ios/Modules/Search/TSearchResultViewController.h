//
//  TSearchResultViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "JXCategoryListContainerView.h"

/// pods
#import <MJRefresh/MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSearchResultViewController : TCBaseViewController <JXCategoryListContentViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (copy, nonatomic) NSString *searchKey;
- (void)clearSearchResult;
- (void)refreshWithData:(NSArray *)dataArray;

@end

NS_ASSUME_NONNULL_END
