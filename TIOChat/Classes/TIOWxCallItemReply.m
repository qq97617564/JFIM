//
//  TIOWxCallItemReply.m
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOWxCallItemReply.h"
#import "NSObject+CBJSONSerialization.h"

@implementation TIOWxCallItemReply

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"callId" : @"id"
    };
}

@end
