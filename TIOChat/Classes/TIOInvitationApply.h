//
//  TIOInvitation.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/2/8.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOInvitationApply : NSObject
/// 头像
@property (copy,    nonatomic) NSString *groupavator;
/// 群昵称
@property (copy,    nonatomic) NSString *groupnick;
/// 申请信息
@property (copy,    nonatomic) NSString *applymsg;
@end

NS_ASSUME_NONNULL_END
