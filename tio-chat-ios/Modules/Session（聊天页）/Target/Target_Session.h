//
//  Target_Session.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_Session : NSObject

- (UIViewController *)Action_P2PViewController:(NSDictionary *)params;
- (UIViewController *)Action_TeamViewController:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
