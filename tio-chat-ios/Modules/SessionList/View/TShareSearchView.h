//
//  TShareSearchView.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchAllResult.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TShareSearchViewDelegate <NSObject>

- (void)tshare_didSelectedUserOrTeam:(id)data isTeam:(BOOL)team;

@end

@interface TShareSearchView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) id<TShareSearchViewDelegate> delegate;

@property (nonatomic, weak)  UITableView *tableView;
@property (copy, nonatomic) NSString *searchKey;
@property (strong, nonatomic) NSArray<SearchAllResult *> *dataArray;

- (void)refreshData:(NSArray *)data;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
