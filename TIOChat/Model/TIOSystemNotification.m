//
//  TIOSystemNotification.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/15.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOSystemNotification.h"

@implementation TIOSystemNotification

- (TIOSystemNotificationType)type
{
    if (self.code) {
        return self.code;
    }
    return _type;
}

@end
