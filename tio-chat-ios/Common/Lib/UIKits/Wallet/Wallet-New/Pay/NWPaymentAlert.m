//
//  NWPaymentAlert.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWPaymentAlert.h"
#import "FrameAccessor.h"
#import "UIView+Popup.h"

@interface NWPaymentAlert() <LYPaymentFieldDelegate>
@property (strong,  nonatomic) UIView *maskView;
@property (weak,    nonatomic) UIView *onView;
@end

@implementation NWPaymentAlert

+ (instancetype)alert
{
    return [[NWPaymentAlert alloc] initWithFrame:CGRectMake(0, 0, 324, 246)];
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
        [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
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
        
        UILabel *subLabel = [UILabel.alloc initWithFrame:CGRectMake(20, moneyLabel.bottom, self.width - 40, 42)];
        [self addSubview:subLabel];
        self.subLabel = subLabel;
        
        /// 分割线
        UIView *line = [UIView.alloc initWithFrame:CGRectMake(20, subLabel.bottom, self.width - 40, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#F1F1F1"];
        [self addSubview:line];
        
        UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(20, line.bottom, 150, 37)];
        label.text = @"请输入支付密码";
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"#666666"];
        label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:label];
        
        /// 密码框
        LYSecurityField *field = [LYSecurityField.alloc initWithNumberOfCharacters:6 securityCharacterType:SecurityCharacterTypeSecurityDot borderType:BorderTypeHaveRoundedCorner];
        field.tintColor = [UIColor colorWithHex:0xD8D8D8];
        field.frame = CGRectMake(15, titleLabel.bottom + 30, 288, 49);
        field.centerX = self.width * 0.5;
        field.bottom = self.height - 22;
        field.widthOfBox = 48;
        field.delegate = self;
        CBWeakSelf
        field.completion = ^(LYSecurityField * _Nonnull field, NSString * _Nonnull text) {
            // 输入满格时被触发
            CBStrongSelfElseReturn
        };
        [self addSubview:field];
        self.securityField = field;
        
        
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

- (void)lYPaymentFieldDidFinishedEditing:(LYSecurityField *)paymentField
{
    if (self.inputPasswordCompleted) {
        self.inputPasswordCompleted(@{@"result" : paymentField.text}, self, paymentField.text);
    }
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
    self.centerY -= 50;
    [self gp_showPopup];
}

- (void)dismiss:(id)sender
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

@end
