//
//  TIOWxSDP.m
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOWxSDP.h"

@implementation TIOWxSDP

- (NSString *)description
{
    return [NSString stringWithFormat:@"type:%@\nsdp:%@",self.type,self.sdp];
}

@end
