//
//  TIOWxCallItemAnswerCandidate.m
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOWxCallItemAnswerCandidate.h"
#import "NSObject+CBJSONSerialization.h"

@implementation TIOWxCallItemAnswerCandidate

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"callId" : @"id"
    };
}

+ (NSDictionary<NSString *,Class> *)JSONArrayClassMapping
{
    return @{
        @"candidate" : TIOICECandidate.class,
    };
}

@end
