//
//  LYGroupNode.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYGroupNode<T> : NSObject

@property (copy,    nonatomic) NSString *group;

@property (strong,  nonatomic) NSMutableArray<T> *list;

+ (instancetype)createNodeWithGroup:(NSString *)group;

@end

NS_ASSUME_NONNULL_END
