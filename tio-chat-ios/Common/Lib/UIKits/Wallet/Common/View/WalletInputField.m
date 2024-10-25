//
//  WalletInputField.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletInputField.h"

@implementation WalletInputField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.delegate = self;
        self.maxNumberOfChar = 12;
        self.numberOfDecimal = 2;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.delegate = self;
        self.maxNumberOfChar = 12;
        self.numberOfDecimal = 2;
    }
    return self;
}

- (void)deleteBackward
{
    // 务必调用父类的删除，否则系统原删除方法被完全重写
    [super deleteBackward];
    
    if (self.w_deleteBlock) {
        if (self.text.length > 0) {
            NSString *firstStr = [self.text substringToIndex:1];
            if ([firstStr isEqualToString:@"."]) {
                /// 如果删除后第一个字符是"."
                /// 先补0，保证是正确的小数格式
                self.text = [self removeZeroPrefix:[NSString stringWithFormat:@"0%@",self.text]];
                self.w_deleteBlock(self.text);
                return;
            }
            // 剔除前面无效的0
            self.text = [self removeZeroPrefix:self.text];
            self.w_deleteBlock(self.text);
        }
    }
}

- (NSString *)removeZeroPrefix:(NSString *)text
{
    NSString *result = text;
    // 从头遍历，index是第i个连续为0的位置，就是i
    NSInteger index = -1;
    
    for (int i = 0; i < text.length; i++) {
        NSString *str = [text substringWithRange:NSMakeRange(i, 1)];
        if (i == 0) {
            if (str.integerValue == 0) {
                index = i;
            }
        } else {
            if (index == (i-1)) {
                if (str.integerValue == 0) {
                    index = i;
                }
            }
        }
        
        if ([str isEqualToString:@"."]) {
            /// 如果当前是小数点，保留前面的0，
            index -= 2;
        }
    }
    
    if (index >-1 ) {
        // 说明从头开始，到第index全为0，删除这一段
        result = [text substringFromIndex:index+1];
    }
    
    return result;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
 
    NSLog(@"%@",NSStringFromSelector(action));
    
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"---%@",gestureRecognizer);
    
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIVariableDelayLoupeGesture")]) {
        // 长按手势
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length==0) {
        return YES;
    }else if (textField.text.length>=self.maxNumberOfChar) {
        return NO;
    }
//    NSString *str = [textField.text stringByAppendingString:string];
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString    *firstStr = [str substringToIndex:1];
    if ([firstStr integerValue]==0) {
        
        if ([string isEqualToString:@"."])
        {   // 第一个字符输入 “.”时， 意味着输入“0.XX”的金额
            if (str.length>1)
            {   // 原有字符串是否已包含小数点
                NSInteger hadDecical = 0;
                for (int i = 0; i < str.length; i++) {
                    if ([str characterAtIndex:i] == '.') {
                        hadDecical++;
                    }
                }
                if (hadDecical > 1) {// 1表示刚输入的‘.’
                    textField.text = @"0";
                } else { // 只有刚刚输入的小数点，只要再在小数点前补0就OK
                    textField.text = [NSString stringWithFormat:@"0%@",str];
                    return NO;
                }
                return YES;
            }
            else
            {
                textField.text = @"0";
                return YES;
            }
        }
        else if ([string isEqualToString:@"0"])
        {   /// 第一个输入的是0，自动生成 "0."
            if ([str isEqualToString:@"0.0"]) {
                textField.text = @"0.0";
            } else if ([str isEqualToString:@"0.00"]) {
                textField.text = @"0.00";
            } else {
                textField.text = @"0.";
            }
            return NO;
        }
        else
        {
            if (str.length > 1) {
                // 判断是不是是 “0.” 开头
                NSString *secondStr = [str substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."]) {
                    // 不是禁止输入，
                    return NO;
                }
                // 是的话，继续从 Line：154执行
            } else {
                return NO;
            }
        }
    }
    
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i < string.length)
    {
        NSString * stringSet = [string substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [stringSet rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0)
        {
            return NO;
            break;
        }
        i++;
    }
    if([textField.text rangeOfString:@"."].location !=NSNotFound)//_roaldSearchText
    {
        if ([string isEqualToString:@"."]) {
            return NO;
        }
    }
    else
    {
    }
    NSMutableString * futureString = [NSMutableString stringWithString:textField.text];
    [futureString  insertString:string atIndex:range.location];
    NSInteger flag=0;
    const NSInteger limited = self.numberOfDecimal;//小数点后需要限制的个数
    for (int i =(int) futureString.length-1; i>=0; i--) {
        if ([futureString characterAtIndex:i] == '.') {
            if (flag > limited) {
                
                return NO;
            }
            break;
        }
        flag++;
    }
    
    return YES;
}

@end
