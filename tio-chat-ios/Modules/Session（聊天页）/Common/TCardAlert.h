//
//  TCardAlert.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/4/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TAlertController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCardAlert : TAlertController

+ (TCardAlert *)alertWithAvatar:(NSString *)imageUrl nick:(NSString *)nick title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
