//
//  TAlertLayout.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAlertLayout : NSObject

@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, assign) CGFloat actionsHorizontalSpace;

@property (nonatomic, assign) CGFloat actionsVerticalSpace;

@property (nonatomic, assign) CGFloat actionHeight; // ActionSheet 有效

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) NSTextAlignment titleAligment;
@property (nonatomic, assign) NSTextAlignment messageAligment;

@end

NS_ASSUME_NONNULL_END
