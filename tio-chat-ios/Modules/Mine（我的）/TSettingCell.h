//
//  TSettingCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSettingCell : UITableViewCell
@property (nonatomic,   copy) void (^switchCallback)(TSettingCell *cell, BOOL open);
@property (nonatomic, assign) BOOL open;

@property (nonatomic,   copy) NSString *detailText;

@end

NS_ASSUME_NONNULL_END
