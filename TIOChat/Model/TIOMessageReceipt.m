//
//  TIOMessageReceipt.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/25.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOMessageReceipt.h"
#import "TIOMessage.h"

@implementation TIOMessageReceipt

- (instancetype)initWithMessage:(TIOMessage *)message
{
    self = [super init];
    
    if (self) {
        _messageId = message.messageId;
    }
    
    return self;
}

@end
