//
//  TInvitedUserCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/2/8.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 被邀请入群的用户
@interface TInvitedUserCell : UICollectionViewCell

@property (strong,  nonatomic) TIOUser *model;
@property (copy,    nonatomic) void(^onClick)(TIOUser *model);

@end

NS_ASSUME_NONNULL_END
