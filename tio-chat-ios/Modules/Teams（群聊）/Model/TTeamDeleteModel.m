//
//  TTeamDeleteModel.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/20.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamDeleteModel.h"

@implementation TTeamDeleteModel

+ (instancetype)modelWithUser:(TIOTeamMember *)user
{
    TTeamDeleteModel *model = [TTeamDeleteModel.alloc init];
    model.status = TCellSelectedStatusNone;
    model.user = user;
    
    return model;
}

@end
