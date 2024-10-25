//
//  TIOSessionActiveCenter.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOSessionActiveCenter.h"

@interface TIOSessionActiveCenter ()

@end

@implementation TIOSessionActiveCenter

+ (instancetype)shareInstance
{
    static TIOSessionActiveCenter *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (BOOL)isActive:(NSString *)sessionId
{
    if (!_focusMap) {
        return NO;
    }
    return [self.focusMap.allKeys containsObject:sessionId];
}

- (void)setFocusMap:(NSDictionary *)focusMap
{
    _focusMap = focusMap;
    
    // 需要去清空该会话的红点
    NSArray *availbleKeys = [_focusMap allKeysForObject:@(1)];
    if (availbleKeys.count) {
        [_focusMap.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.clearSession) {
                self.clearSession(obj);
            }
        }];
    }
}

@end
