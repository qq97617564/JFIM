//
//  TSearchResultViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSearchResultViewController.h"

@interface TSearchResultViewController ()

@end

@implementation TSearchResultViewController

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"CBClearSearchResult" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchKey = [NSUserDefaults.standardUserDefaults objectForKey:@"searchText"];
    [self beginRefreshing:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(observerClearResultData:) name:@"CBClearSearchResult" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.searchKey || ![self.searchKey isEqualToString:[NSUserDefaults.standardUserDefaults objectForKey:@"searchText"]]) {
        self.searchKey = [NSUserDefaults.standardUserDefaults objectForKey:@"searchText"];
        [self beginRefreshing:nil];
    }
}

- (void)observerClearResultData:(NSNotification *)notification
{
    [self clearSearchResult];
}

- (void)clearSearchResult
{
    
}

- (void)refreshWithData:(NSArray *)dataArray
{
    
}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIViewController *)listViewController
{
    return self;
}

@end
