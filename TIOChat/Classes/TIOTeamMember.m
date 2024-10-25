//
//  TIOUserInTeam.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOTeamMember.h"
#import "NSObject+CBJSONSerialization.h"
#import "NSString+tio.h"

@interface TIOTeamMember ()
@property (nonatomic, assign) NSInteger grouprole;
@end

@implementation TIOTeamMember

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"groupId" : @"groupid",
        @"groupNick" : @"groupnick",
        @"role" : @"grouprole"
    };
}

- (NSString *)avatar
{
    return _avatar.tio_resourceURLString;
}

@end
