//
//  TIOWxCallItem.m
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOWxCallItem.h"
#import "NSObject+CBJSONSerialization.h"

@implementation TIOWxCallItem

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"callId" : @"id"
    };
}

@end
