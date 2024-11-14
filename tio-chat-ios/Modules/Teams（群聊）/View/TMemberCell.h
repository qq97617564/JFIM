//
//  TMemberCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTeamDefines.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMemberCell : UITableViewCell

- (void)refreshData:(TIOTeamMember *)teamUser isSelf:(BOOL)isSelf status:(TCellSelectedStatus)status;

@property (copy, nonatomic) void(^selectedCallback)(BOOL selected);
@property(nonatomic, strong)UIImageView *flag;
@end

NS_ASSUME_NONNULL_END
