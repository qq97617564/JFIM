//
//  IMInputAtCache.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/22.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMInputAtCache.h"

@interface IMInputAtCache()
@property (nonatomic,strong) NSMutableArray *items;
@end

@implementation IMInputAtCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray<IMInputAtObject *> *)allAtObject
{
    return self.items;
}

- (void)clean
{
    [self.items removeAllObjects];
}

- (void)addItem:(IMInputAtObject *)item
{
    [self.items addObject:item];
}

- (IMInputAtObject *)item:(NSString *)name
{
    __block IMInputAtObject *item;
    [_items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        IMInputAtObject *object = obj;
        if ([object.nick isEqualToString:name])
        {
            item = object;
            *stop = YES;
        }
    }];
    return item;
}

- (void)removeName:(NSString *)name
{
    __block IMInputAtObject *item;
    [_items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        IMInputAtObject *object = obj;
        if ([object.nick isEqualToString:name]) {
            item = object;
            *stop = YES;
        }
    }];
    if (item) {
        [_items removeObject:item];
    }
}

@end
