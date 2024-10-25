//
//  IMMessageCellFactory.m
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import "IMKitMessageCellFactory.h"
#import "TIOChatKit.h"
#import "IMCellConfig.h"

@implementation IMKitMessageCellFactory

- (IMKitMesssageCell *)cellInTable:(UITableView *)tableView forMessageMode:(IMKitMessageModel *)model
{
    id<IMCellLayoutConfig> layoutConfig = [TIOChatKit.shareSDK cellConfig];
    NSString *identity = [layoutConfig cellContent:model];
    IMKitMesssageCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        NSString *clz = TIOChatKit.shareSDK.config.messageCellClass;
        [tableView registerClass:NSClassFromString(clz) forCellReuseIdentifier:identity];
        cell = [tableView dequeueReusableCellWithIdentifier:identity];
    }
    [cell refreshData:model];
    return (IMKitMesssageCell *)cell;
}

- (IMKitSessionTimeCell *)cellInTable:(UITableView *)tableView forTimeMode:(IMKitTimeModel *)model
{
    NSString *identity = @"time";
    IMKitSessionTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        NSString *clz = @"IMKitSessionTimeCell";
        [tableView registerClass:NSClassFromString(clz) forCellReuseIdentifier:identity];
        cell = [tableView dequeueReusableCellWithIdentifier:identity];
    }
    [cell refreshData:model];
    return cell;
}

- (IMKitSystemMessageCell *)cellInTable:(UITableView *)tableView forSystemModel:(IMKitSystemMessageModel *)model
{
    NSString *identity = @"system";
    IMKitSystemMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        NSString *clz = @"IMKitSystemMessageCell";
        [tableView registerClass:NSClassFromString(clz) forCellReuseIdentifier:identity];
        cell = [tableView dequeueReusableCellWithIdentifier:identity];
    }
    [cell refreshData:model];
    return cell;
}

@end
