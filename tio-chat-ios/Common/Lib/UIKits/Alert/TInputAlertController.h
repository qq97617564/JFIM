//
//  TInputAlertController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TAlertController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TAlertInputStyle) {
    TAlertInputStyleTextField = 0,
    TAlertControllerTextView,
};

@interface TInputAlertController : TAlertController

@property (assign,  nonatomic) NSInteger maxCharCount;
@property (copy, nonatomic) NSString *text;
@property (weak,    nonatomic) UILabel *titleLabel;

+ (TInputAlertController *)alertWithTitle:(NSString *)title placeholder:(NSString *)placeholder inputHeight:(CGFloat)inputHeight inputStyle:(TAlertInputStyle)inputStyle;

@end

NS_ASSUME_NONNULL_END
