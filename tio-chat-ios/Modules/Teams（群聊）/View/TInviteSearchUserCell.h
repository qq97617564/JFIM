//
//  TInviteSearchUserCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTeamInviteModel.h"
#import "TTeamDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface TInviteSearchUserCell : UITableViewCell

- (void)refreshAvatar:(NSString *)avatar sex:(NSInteger)sex nick:(NSString *)nick relation:(NSInteger)relation key:(NSString *)key status:(TCellSelectedStatus)status;

@property (copy, nonatomic) void(^selectedCallback)(BOOL selected);

@end

NS_ASSUME_NONNULL_END
