//
//  TShareSearchView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TShareSearchView.h"
#import "TSearchFriendCell.h"
#import "FrameAccessor.h"
#import <objc/message.h>

@implementation TShareSearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addTableView];
    }
    
    return self;
}

- (void)addTableView
{
    UITableView *tableView = [UITableView.alloc initWithFrame:self.bounds];
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 12)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:TSearchFriendCell.class forCellReuseIdentifier:NSStringFromClass(TSearchFriendCell.class)];
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self addSubview:tableView];
    self.tableView = tableView;
}

- (void)refreshData:(NSArray *)data
{
    self.dataArray = data;
    [self.tableView reloadData];
}

- (void)clear
{
    self.dataArray = @[];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    SearchAllResult *result = self.dataArray[indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.dataArray[indexPath.section].identifier];
    NSString *methodString = @"refreshAvatar:nick:remark:key:";
    SEL refreshSelector = NSSelectorFromString(methodString);
    
    if ([result.childList.firstObject isKindOfClass:NSClassFromString(@"TIOUser")]) {
        TIOUser *model = result.childList[indexPath.row];
        ((void(*)(id,SEL,id,id,id,id))objc_msgSend)(cell, refreshSelector, model.avatar, model.nick, model.remarkname, self.searchKey);
    } else {
        TIOTeam *model = result.childList[indexPath.row];
        ((void(*)(id,SEL,id,id,id,id))objc_msgSend)(cell, refreshSelector, model.avatar, model.name, [NSString stringWithFormat:@"%zd",model.memberNumber], self.searchKey);
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SearchAllResult *result = self.dataArray[section];
    if (result.childList.count < result.showNumber) {
        return result.childList.count;
    } else {
        if (result.controlState == UIControlStateSelected) { // 如果此section的更多已点击，就展开显示所有的行
            return result.childList.count;
        }
        return result.showNumber;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.width, 35)];
    view.backgroundColor = UIColor.whiteColor;
    UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(16, 12, 60, 20)];
    label.text = self.dataArray[section].title;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithHex:0x999999];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.viewSize = CGSizeMake(70, 20);
    moreButton.centerY = label.centerY;
    moreButton.right = view.width - 16;
    moreButton.tag = section + 1000;
    moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [moreButton setTitle:self.dataArray[section].moreTitle forState:UIControlStateNormal];
    [moreButton setTitle:self.dataArray[section].stateMoreTitle[@(UIControlStateSelected)] forState:UIControlStateSelected];
    [moreButton setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    // 如果该header继承UITableViewReuseHeaderView，即重用header，不需要下面一行代码，仅仅因为header重新出现，需要重新创建
    moreButton.selected = self.dataArray[section].controlState == UIControlStateSelected;
    [view addSubview:moreButton];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc init];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (@protocol(TShareSearchViewDelegate) && [_delegate respondsToSelector:@selector(tshare_didSelectedUserOrTeam:isTeam:)]) {
        
        id data = self.dataArray[indexPath.section].childList[indexPath.row];
        
        BOOL isTeam = [data isKindOfClass:NSClassFromString(@"TIOTeam")];
        [_delegate tshare_didSelectedUserOrTeam:data isTeam:isTeam];
    }
}

#pragma mark - moreButtonClicked

- (void)moreButtonClicked:(UIButton *)button
{
    NSInteger index = button.tag - 1000;
    SearchAllResult *result = self.dataArray[index];
    
    if (result.childList.count < result.showNumber) {
        // 如果已经小雨默认收起时的展示条数，就让按钮点击无效果
        return;
    }
    
    button.selected = !button.selected;
    
    result.controlState = button.selected?UIControlStateSelected:UIControlStateNormal;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
}

@end
