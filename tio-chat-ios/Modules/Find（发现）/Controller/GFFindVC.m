//
//  GFFindVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/27.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFFindVC.h"
#import "GFAddressListCell.h"
#import <UIImageView+WebCache.h>
#import "WKWebViewController.h"

@interface GFFindVC ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *dataArray;
}
@property(nonatomic, strong)UITableView *tableView;

@end

@implementation GFFindVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发现";
//    titles = @[@"IM开源地址",@"chatArea",@"uniAPP",@"百度一下",@"演示系统",@"注意防骗"];
//    icons = @[@"Group 1321315495",@"Group 1321315496",@"Group 1321315497",@"Group 1321315498",@"Group 1321315499",@"Group 1321315500"];
    [self.view addSubview:self.tableView];
    [self loadData];
}
-(void)loadData{
    CBWeakSelf
    [MBProgressHUD showLoading:@"" toView:self.view];
    [TIOChat.shareSDK.gfHttpManager getFindDataCompletion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
            return;
        }else{
            NSArray *array = (NSArray *)responseObject[@"data"];
            self->dataArray = array;
            [self.tableView reloadData];
        }
        
        
    }];
}
-(UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, self.view.bounds.size.width, ScreenHeight() - Height_NavBar - Height_TabBar) style:UITableViewStyleGrouped];
        tableView.sectionIndexColor = [UIColor colorWithHex:0x909090];
        tableView.sectionIndexMinimumDisplayRowCount = 6;
        tableView.backgroundColor = [UIColor colorWithHex:0xF2F2F2];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.separatorInset = UIEdgeInsetsMake(0, 77, 0, 0);
        tableView.separatorColor = [UIColor colorWithHex:0xE9E9E9];
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];

        [tableView registerNib:[UINib nibWithNibName:@"GFAddressListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GFAddressListCell"];
        [self.view addSubview:tableView];
        tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectZero];
        _tableView = tableView;
    }
    return _tableView;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GFAddressListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GFAddressListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.icon sd_setImageWithURL:[NSURL URLWithString:dataArray[indexPath.row][@"image"]] placeholderImage:nil];
    cell.titleL.text = dataArray[indexPath.row][@"title"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *url = dataArray[indexPath.row][@"url"];
    if ([url containsString:@"http"]) {
        WKWebViewController *web = [WKWebViewController.alloc init];
        web.urlString = url;
        [self.navigationController pushViewController:web animated:YES];
    }

}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
