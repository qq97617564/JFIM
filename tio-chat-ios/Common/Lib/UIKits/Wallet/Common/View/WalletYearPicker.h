//
//  WalletYearPicker.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/6.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WalletYearPicker : UIView

/// 当前选中的index
@property (assign,  nonatomic) NSInteger currentIndex;

@property (copy,    nonatomic) NSString *title;

@property (copy,    nonatomic) void(^ClickBlock)(NSInteger currentIndex);

+ (instancetype)showItems:(NSArray *)items currentIndex:(NSInteger)currentIndex block:(void(^)(NSInteger currentIndex))block onView:(UIView *)onView;

@end

NS_ASSUME_NONNULL_END
