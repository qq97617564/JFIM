//
//  TSearchUserCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSearchUserCell : UITableViewCell

@property (copy, nonatomic) void (^addCallback)(void);

/// 刷新数据
/// @param avatar 头像URL
/// @param sex 性别
/// @param nick 昵称
/// @param relation 好友关系  0:不是好友 1:好友
- (void)refreshAvatar:(NSString *)avatar sex:(NSInteger)sex nick:(NSString *)nick relation:(NSInteger)relation key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
