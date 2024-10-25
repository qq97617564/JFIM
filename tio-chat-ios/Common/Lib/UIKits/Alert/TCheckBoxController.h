//
//  TCheckBoxController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TAlertController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCheckBoxController : TAlertController

@property (assign,  nonatomic) NSInteger index;
@property (assign,  nonatomic) BOOL t_selected;

+ (TCheckBoxController *)alertWithTitle:(NSString *)title items:(NSArray *)items;

@end

NS_ASSUME_NONNULL_END
