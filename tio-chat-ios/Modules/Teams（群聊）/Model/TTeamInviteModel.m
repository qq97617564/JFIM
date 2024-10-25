//
//  TTeamInviteModel.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamInviteModel.h"

@implementation TTeamInviteModel

+ (instancetype)modelWithUser:(TIOUser *)user
{
    TTeamInviteModel *model = [TTeamInviteModel.alloc init];
    model.status = TCellSelectedStatusNone;
    model.user = user;
    model.group = user.chatindex;
    
    return model;
}

@end
