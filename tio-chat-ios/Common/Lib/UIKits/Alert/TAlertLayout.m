//
//  TAlertLayout.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TAlertLayout.h"

@implementation TAlertLayout

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.actionHeight = 40;
        self.actionsHorizontalSpace = 24;
        self.actionsVerticalSpace = 16;
        self.cornerRadius = 4;
        self.contentInset = UIEdgeInsetsMake(33, 24, 20, 24);
        self.titleAligment = NSTextAlignmentCenter;
        self.messageAligment = NSTextAlignmentCenter;//NSTextAlignmentJustified;
    }
    
    return self;
}

@end
