//
//  TTeamSearchMemberViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/16.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamSearchMemberViewController.h"
#import "FrameAccessor.h"

@interface TTeamSearchMemberViewController () 
@property (nonatomic,   weak) UITableView *tableView;
@end

@implementation TTeamSearchMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupTable
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.width, self.view.height - Height_NavBar) style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

@end
