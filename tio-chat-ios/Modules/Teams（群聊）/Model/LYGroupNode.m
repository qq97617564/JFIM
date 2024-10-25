//
//  LYGroupNode.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "LYGroupNode.h"

@implementation LYGroupNode

+ (instancetype)createNodeWithGroup:(NSString *)group
{
    LYGroupNode *node = [LYGroupNode.alloc init];
    node.group = group;
    node.list = [NSMutableArray array];
    return node;
}

@end
