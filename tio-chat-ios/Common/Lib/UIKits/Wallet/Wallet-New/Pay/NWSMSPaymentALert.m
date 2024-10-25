//
//  NWSMSPaymentALert.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/12.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWSMSPaymentALert.h"
#import "FrameAccessor.h"
#import "UIView+Popup.h"
#import "UIButton+Enlarge.h"
#import "UIControl+T_LimitClickCount.h"

@interface NWSMSPaymentALert ()
@property (strong,  nonatomic) UIView *maskView;
@property (weak,    nonatomic) UIView *onView;
@property (weak,    nonatomic) UIButton *otherBank;
@property (weak,    nonatomic) UITextField *tf;
/// 是否已经获取验证码
@property (assign,  nonatomic) BOOL wasFetchSMS;

@property (weak, nonatomic) UIButton *smsButton;
@property (weak, nonatomic) NSTimer *countdownTimer;
@end

@implementation NWSMSPaymentALert

+ (instancetype)alert
{
    return [[NWSMSPaymentALert alloc] initWithFrame:CGRectMake(0, 0, 324, 296)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"w_cancel"] forState:UIControlStateNormal];
        [button sizeToFit];
        [button addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(16, 15, 28, 28);
        [self addSubview:button];
        
        UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.frame) - 30, 52)];
        titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        titleLabel.textColor = [UIColor colorWithHex:0x333333];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.center = CGPointMake(CGRectGetWidth(self.frame)*0.5, CGRectGetMidY(button.frame));
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        /// 金额
        UILabel *moneyLabel = [UILabel.alloc initWithFrame:CGRectMake(10, 52, self.width - 20, 47)];
        moneyLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        moneyLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:moneyLabel];
        self.moneyLabel = moneyLabel;
        
        /// 支付方式
        {
            UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(20, moneyLabel.bottom, 60, 42)];
            label.text = @"支付方式";
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithHexString:@"#666666"];
            label.textAlignment = NSTextAlignmentLeft;
            [self addSubview:label];
            
            UIButton *otherBank = [UIButton buttonWithType:UIButtonTypeCustom];
            otherBank.viewSize = CGSizeMake(200, 20);
            otherBank.right = self.width - 20;
            otherBank.centerY = label.centerY;
            otherBank.acceptEventInterval = 0.5;
            [otherBank setTitle:@"选择付款方式" forState:UIControlStateNormal];
            [otherBank setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
            [otherBank.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [otherBank setImage:[UIImage imageNamed:@"w_addbank_right"] forState:UIControlStateNormal];
            [otherBank verticalLayoutWithInsetsStyle:ButtonStyleRight Spacing:2];
            otherBank.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [otherBank addTarget:self action:@selector(otherBank:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:otherBank];
            self.otherBank = otherBank;
        }
        
        /// 分割线
        UIView *line = [UIView.alloc initWithFrame:CGRectMake(20, moneyLabel.bottom+42, self.width - 40, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#F1F1F1"];
        [self addSubview:line];
        
        UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(20, line.bottom, self.width - 40, 37)];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"#666666"];
        label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:label];
        self.subLabel2 = label;
        
        UITextField *textfield = [UITextField.alloc initWithFrame:CGRectMake(20, label.bottom, self.width - 40, 38)];
        textfield.layer.cornerRadius = 4;
        textfield.layer.masksToBounds = YES;
        textfield.backgroundColor = [UIColor colorWithHexString:@"#F6F6F6"];
        textfield.font = [UIFont systemFontOfSize:14];
        textfield.attributedPlaceholder = [NSAttributedString.alloc initWithString:@"请输入验证码" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#CCCCCC"]}];
        textfield.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 8, textfield.height)];
        textfield.leftViewMode = UITextFieldViewModeAlways;
        textfield.rightViewMode = UITextFieldViewModeAlways;
        textfield.rightView = ({
            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 90, textfield.height)];
            UIView *line = [UIView.alloc initWithFrame:CGRectMake(0, 6, 1, view.height - 12)];
            line.backgroundColor = [UIColor colorWithHexString:@"#E5E5E5"];
            [view addSubview:line];
            
            // 获取验证码按钮
            UIButton *smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            smsButton.frame = CGRectMake(1, 0, view.width - 1, view.height);
            [smsButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [smsButton setTitleColor:[UIColor colorWithHex:0x4C94FF] forState:UIControlStateNormal];
            [smsButton setTitleColor:[UIColor colorWithHex:0xBBBBBB] forState:UIControlStateDisabled];
            smsButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
            [smsButton addTarget:self action:@selector(SMSButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:smsButton];
            self.smsButton = smsButton;
            
            view;
        });
        [self addSubview:textfield];
        self.tf = textfield;
        
        UIButton *payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        payButton.viewSize = CGSizeMake(110, 40);
        payButton.centerX = self.middleX;
        payButton.bottom = self.height - 20;
        payButton.layer.cornerRadius = 4;
        payButton.layer.masksToBounds = YES;
        payButton.backgroundColor = [UIColor colorWithHexString:@"#4C94FF"];
        [payButton setTitle:@"确定" forState:UIControlStateNormal];
        [payButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [payButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [payButton addTarget:self action:@selector(payClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:payButton];
    }
    
    return self;
}

- (void)setMoney:(NSString *)money
{
    _money = money;
    
    self.moneyLabel.attributedText = ({
        NSMutableAttributedString *attributedString = [NSMutableAttributedString.alloc initWithString:@"¥" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}];
        [attributedString appendAttributedString:[NSAttributedString.alloc initWithString:money attributes:@{NSFontAttributeName:[UIFont fontWithName:@"DINAlternate-Bold" size:38], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        
        attributedString;
    });
}

- (void)setPhone:(NSString *)phone
{
    if (phone.length >= 9) {
        phone = [phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    self.subLabel2.text = [NSString stringWithFormat:@"短信验证码将发送至：%@",phone];
}

- (void)setPaymentName:(NSString *)paymentName
{
    [self.otherBank setTitle:paymentName forState:UIControlStateNormal];
    [self.otherBank verticalLayoutWithInsetsStyle:ButtonStyleRight Spacing:2];
    self.otherBank.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

- (void)showOnView:(UIView *)onView
{
    self.onView = onView;
    self.maskView = [UIView.alloc initWithFrame:onView.bounds];
    self.maskView.backgroundColor = UIColor.clearColor;
    [onView addSubview:self.maskView];
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    }];
    
    [onView addSubview:self];
    self.center = onView.middlePoint;
    self.centerY -= 100;
    [self gp_showPopup];
    
    
    [self.tf becomeFirstResponder];
}

- (void)cancelClicked:(id)sender
{
    if (self.wasFetchSMS) {
        CBWeakSelf
        self.cancelHandler(YES, self, ^(BOOL dismiss) {
            CBStrongSelfElseReturn
            if (dismiss) {
                [self dismiss];
            }
        });
    } else {
        [self dismiss];
    }
}

- (void)dismiss
{
    [self endEditing:YES];
    [self gp_dismissPopup:^{
        [UIView animateWithDuration:0.2 animations:^{
            self.maskView.backgroundColor = UIColor.clearColor;
        } completion:^(BOOL finished) {
            [self.maskView removeFromSuperview];
        }];
    }];
}

#pragma mark - actions

- (void)otherBank:(id)sender
{
    [self.tf resignFirstResponder];
    
    if (self.otherPaymentCompleted) {
        self.otherPaymentCompleted(self, ^(BOOL dismiss) {
            if (dismiss) {
                [self dismiss];
            }
        });
    }
}

- (void)payClicked:(id)sender
{
    if (self.completeHandler) {
        if (self.tf.text) {
            self.completeHandler(self, self.tf.text, ^(BOOL dismiss) {
                if (dismiss) {
                    [self dismiss];
                }
            });
        }
    }
}

#pragma mark - 倒计时

- (void)SMSButtonDidClicked:(UIButton *)button
{
    /// 下单成功     开始倒计时
    if (self.fetchSMSHandler) {
        CBWeakSelf
        self.fetchSMSHandler(self, ^(BOOL startCounter) {
            CBStrongSelfElseReturn
            if (startCounter) {
                self.wasFetchSMS = YES;
                [self startCountdownTimerIfNecessary];
            }
        });
    }
}

- (void)startCountdownTimerIfNecessary
{
    if (self.countdownTimer) {
        return;
    }
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdownTimerDidFire:) userInfo:nil repeats:YES];
    self.smsButton.enabled = NO;
    self.smsButton.tag = 60;
    [self.smsButton setTitle:@"获取验证码" forState:UIControlStateDisabled];
    self.countdownTimer = timer;
}

- (void)countdownTimerDidFire:(NSTimer *)sender
{
    NSInteger seconds = self.smsButton.tag - 1;
    [self.smsButton setTitle:[NSString stringWithFormat:@"已发送(%@s)",@(seconds)] forState:UIControlStateDisabled];
    self.smsButton.tag = seconds;
    if (self.smsButton.tag == 0) {
        self.smsButton.enabled = YES;
        [self cancelCountdownTimer];
    }
}

- (void)cancelCountdownTimer
{
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    self.smsButton.enabled = YES;
}


@end
