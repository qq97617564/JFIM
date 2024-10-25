//
//  Target_Search.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_Search : NSObject

- (UIViewController *)Action_searchFriendViewController:(NSDictionary *)params;

- (UIViewController *)Action_searchUserViewController:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
