//
//  IMMessageCellFactory.h
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import <Foundation/Foundation.h>
#import "IMKitMesssageCell.h"
#import "IMKitMessageModel.h"
#import "IMKitSessionTimeCell.h"
#import "IMKitTimeModel.h"
#import "IMKitSystemMessageModel.h"
#import "IMKitSystemMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMKitMessageCellFactory : NSObject

- (IMKitMesssageCell *)cellInTable:(UITableView *)tableView forMessageMode:(IMKitMessageModel *)model;

- (IMKitSessionTimeCell *)cellInTable:(UITableView *)tableView forTimeMode:(IMKitTimeModel *)model;

- (IMKitSystemMessageCell *)cellInTable:(UITableView *)tableView forSystemModel:(IMKitSystemMessageModel *)model;

@end

NS_ASSUME_NONNULL_END
