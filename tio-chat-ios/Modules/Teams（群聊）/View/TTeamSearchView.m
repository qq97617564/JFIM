//
//  TTeamSearchView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTeamSearchView.h"

@implementation TTeamSearchView

- (instancetype)initWithType:(TTeamSearchType)type
{
    self = [super init];
    
    if (self) {
        self.type = type;
    }
    
    return self;
}
@end
