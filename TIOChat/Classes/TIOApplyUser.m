//
//  TIOApplyUser.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOApplyUser.h"
#import "NSString+tio.h"
#import "NSObject+CBJSONSerialization.h"

@implementation TIOApplyUser

@synthesize avatar = _avatar;

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    // TODO: 老接口
//    return @{
//        @"friendId" : @"touid",
//        @"userId" : @"fromuid",
//    };
    
    return @{
        @"applyId" : @"id",
        @"userId" : @"uid"
    };
}

- (NSString *)avatar
{
    return _avatar.tio_resourceURLString;
}

@end
