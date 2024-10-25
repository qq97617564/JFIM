//
//  TInputAlertController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TInputAlertController.h"
#import "FrameAccessor.h"

@interface TInputAlertController ()<UITextFieldDelegate>
@property (nonatomic, assign) TAlertInputStyle inputStyle;
@property (strong, nonatomic) UITextField *textfield;
@property (strong, nonatomic) UITextView *textview;
@end

@implementation TInputAlertController

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

+ (TInputAlertController *)alertWithTitle:(NSString *)title placeholder:(NSString *)placeholder inputHeight:(CGFloat)inputHeight inputStyle:(TAlertInputStyle)inputStyle
{
    UIView *contentView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 222, inputHeight+60)];
    
    UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(0, 0, 222, 60)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    [contentView addSubview:label];
    
    TInputAlertController *alert = [[self alloc] initWithTitle:@"" contentView:contentView];
    alert.inputStyle = inputStyle;
    alert.titleLabel = label;
    
    if (inputStyle == TAlertInputStyleTextField) {
        UITextField *textfield = [UITextField.alloc initWithFrame:CGRectMake(0, 60, 222, inputHeight)];
        textfield.layer.cornerRadius = 2;
        textfield.placeholder = placeholder;
        textfield.font = [UIFont systemFontOfSize:16];
        textfield.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 14, inputHeight)];
        textfield.leftViewMode = UITextFieldViewModeAlways;
        textfield.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        textfield.delegate = alert;
        [contentView addSubview:textfield];
        
        alert.textfield = textfield;
    } else {
        UITextView *textview = [UITextView.alloc initWithFrame:CGRectMake(0, 60, 222, inputHeight)];
        textview.font = [UIFont systemFontOfSize:16];
        textview.layer.cornerRadius = 2;
        textview.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        [contentView addSubview:textview];
        
        alert.textview = textview;
    }
    
    return alert;
}

- (instancetype)initWithTitle:(NSString *)title contentView:(UIView *)contentView
{
    self = [super initWithTitle:title contentView:contentView];
    
    if (self) {
        if ([contentView isKindOfClass:UITextField.class]) {
            self.textfield = (UITextField *)contentView;
        } else {
            self.textview = (UITextView *)contentView;
        }
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

/// 重写内容布局方法
- (void)setupAlertContentView
{
    [super setupAlertContentView];
    self.contentView.y = 0;
    self.contentView.centerX = self.containerView.width * 0.5;
}

/// 重写弹窗尺寸
- (CGSize)preferredContentSize
{
    return CGSizeMake([super preferredContentSize].width, CGRectGetHeight(self.contentView.frame) + 78);
}

#pragma mark - 键盘

- (void)keyboardShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGFloat toY = CGRectGetMaxY(self.view.frame);
    if (CGRectGetMinY(keyboardFrame) - CGRectGetMaxY(self.view.frame) != 10) {
        toY = CGRectGetMinY(keyboardFrame) - 10;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    self.view.bottom = toY;
    [UIView commitAnimations];
}

- (void)keyboardHide:(NSNotification *)notification
{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.view.center = window.middlePoint;
    [UIView commitAnimations];
}

- (NSString *)text
{
    if (self.inputStyle == TAlertInputStyleTextField) {
        return self.textfield.text;
    } else {
        return self.textview.text;
    }
}

- (void)setText:(NSString *)text
{
    if (self.inputStyle == TAlertInputStyleTextField) {
        self.textfield.text = text;
    } else {
        self.textview.text = text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByAppendingString:string];
    if (self.maxCharCount) {
        return str.length <= self.maxCharCount;
    }
    return YES;
}

@end
