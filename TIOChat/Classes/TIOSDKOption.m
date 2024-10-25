//
//  TIOSDKOption.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/6.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOSDKOption.h"

@implementation TIOSDKOption

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.isOpenSSL = YES;
    }
    
    return self;
}

@end
