//
//  IMInputAtCache.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/22.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMInputAtObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMInputAtCache : NSObject

- (NSArray<IMInputAtObject *> *)allAtObject;

- (void)clean;

- (void)addItem:(IMInputAtObject *)item;

- (IMInputAtObject *)item:(NSString *)name;

- (void)removeName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
