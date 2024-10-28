//
//  NWAddCreditCardVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/8.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWBindNewCardVC.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"
#import <AFNetworking-umbrella.h>
#import "CBMobileValidator.h"
#import "MBProgressHUD+NJ.h"
#import "ImportSDK.h"
#import "CBIDCardValidator.h"

/// 表单的cell
@interface NWBankFormCell : UITextField
@property (assign,  nonatomic) BOOL hasLine;
@property (strong,  nonatomic) UIView *line;
@property (weak,    nonatomic) UILabel *titleLabel;
@property (copy,    nonatomic) NSString *title;


@end
@implementation NWBankFormCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:16];
        self.backgroundColor = UIColor.whiteColor;
        
        UIView *leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 110, CGRectGetHeight(frame))];
        UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectMake(16, 0, leftView.width - 16, leftView.height)];
        titleLabel.textColor = [UIColor colorWithHex:0x666666];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [leftView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        self.leftViewMode = UITextFieldViewModeAlways;
        self.leftView = leftView;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setHasLine:(BOOL)hasLine
{
    _hasLine = hasLine;
    if (hasLine && !_line) {
        _line = [UIView.alloc init];
        _line.backgroundColor = [UIColor colorWithHex:0xF5F5F5];
        [self addSubview:_line];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_hasLine) _line.frame = CGRectMake(17, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame) - 20, 1);
}

@end

@interface NWBindNewCardVC () <UITextFieldDelegate>
@property (weak,    nonatomic) UIScrollView *scrollView;

@property (strong,  nonatomic) NSMutableArray *forms;

@property (weak,    nonatomic) NWBankFormCell *cardNoCell;
@property (weak,    nonatomic) NWBankFormCell *dateCell;
@property (weak,    nonatomic) NWBankFormCell *backNumberCell;
@property (weak,    nonatomic) NWBankFormCell *nameCell;
@property (weak,    nonatomic) NWBankFormCell *identifierCell;
@property (weak,    nonatomic) NWBankFormCell *phoneCell;
@property (weak,    nonatomic) NWBankFormCell *smsCell;

@property (assign,  nonatomic) BOOL validated;
/// 第一步发起订单返回的参数
@property (strong,  nonatomic) NSDictionary *firstParams;

@property (weak, nonatomic) UIButton *smsButton;
@property (weak, nonatomic) NSTimer *countdownTimer;

@end

@implementation NWBindNewCardVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"添加银行卡";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cardType = NWPaymentTypeDepositCard;
    [self setupCreditCard];
}

- (void)setupCreditCard
{
    UIScrollView *scrollView    = [UIScrollView.alloc initWithFrame:CGRectMake(0, Height_NavBar, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - Height_NavBar)];
    scrollView.backgroundColor  = [UIColor colorWithHex:0xF8F8F8];
    scrollView.contentSize      = scrollView.bounds.size;
    [self.view addSubview:scrollView];
    self.scrollView             = scrollView;
    
    /// 请绑定持卡人本人的银行卡
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectMake(16, 0, 180, 34)];
    titleLabel.text     = @"请绑定持卡人本人的银行卡";
    titleLabel.textColor= [UIColor colorWithHex:0x999999];
    titleLabel.font     = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [scrollView addSubview:titleLabel];
    
    CGFloat y = titleLabel.bottom;
    
    self.forms = [NSMutableArray array];
    
    /// 卡号
    {
        NWBankFormCell *textField = [NWBankFormCell.alloc initWithFrame:CGRectMake(0, y, scrollView.width, 60)];
        textField.hasLine = YES;
        textField.title = @"卡号";
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [textField addTarget:self action:@selector(textfieldEditing:) forControlEvents:UIControlEventEditingChanged];
        textField.placeholder = @"输入本人的银行卡号";
        [scrollView addSubview:textField];
        
        self.cardNoCell = textField;
        [self.forms addObject:textField];
        y = textField.bottom;
    }
    
    /// 持卡人
    {
        NWBankFormCell *textField = [NWBankFormCell.alloc initWithFrame:CGRectMake(0, y, scrollView.width, 60)];
        textField.hasLine = YES;
        textField.delegate = self;
        textField.title = @"持卡人";
        textField.placeholder = @"请输入本人的真实姓名";
        [scrollView addSubview:textField];
        
        self.nameCell = textField;
        [self.forms addObject:textField];
        y = textField.bottom;
    }
    
    /// 身份证号
    {
        NWBankFormCell *textField = [NWBankFormCell.alloc initWithFrame:CGRectMake(0, y, scrollView.width, 60)];
        textField.hasLine = YES;
        textField.delegate = self;
        textField.title = @"身份证号";
        textField.placeholder = @"本人真实身份证号";
        [scrollView addSubview:textField];
        
        self.identifierCell = textField;
        [self.forms addObject:textField];
        y = textField.bottom;
    }
    /// 预留手机号
    {
        NWBankFormCell *textField = [NWBankFormCell.alloc initWithFrame:CGRectMake(0, y, scrollView.width, 60)];
        textField.hasLine = YES;
        textField.delegate = self;
        textField.title = @"预留手机号";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"银行预留的手机号";
        [scrollView addSubview:textField];
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.rightView = ({
            UIView *view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 106, textField.height)];
            view;
        });
        [textField.rightView addSubview:({
            // 获取验证码按钮
            UIButton *smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            smsButton.frame = CGRectMake(0, 0, 90, 34);
            smsButton.centerY = textField.rightView.middleY;
            [smsButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [smsButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            smsButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
            [smsButton setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHexString:@"#4C94FF"]] imageWithCornerRadius:4 size:smsButton.viewSize] forState:UIControlStateNormal];
            [smsButton addTarget:self action:@selector(SMSButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.smsButton = smsButton;
            
            smsButton;
        })];
        
        self.phoneCell = textField;
        [self.forms addObject:textField];
        y = textField.bottom;
    }
    /// 短信验证码
    {
        NWBankFormCell *textField = [NWBankFormCell.alloc initWithFrame:CGRectMake(0, y, scrollView.width, 60)];
        textField.hasLine = NO;
        textField.delegate = self;
        textField.title = @"短信验证码";
        [scrollView addSubview:textField];
        
        self.smsCell = textField;
        [self.forms addObject:textField];
        y = textField.bottom;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.viewSize = CGSizeMake(200, 40);
    button.centerX = self.view.middleX;
    button.top = y + 30;
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithHex:0x4C94FF]] imageWithCornerRadius:4 size:button.viewSize] forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:button];
    [self.forms addObject:button];
}

- (void)layout
{
    BOOL needAnimated = NO;
    
    if (self.cardType == NWPaymentTypeCreditCard && self.forms.count == 6) {
        needAnimated = YES;
        /// 有效期
        {
            NWBankFormCell *textField = [NWBankFormCell.alloc initWithFrame:CGRectMake(0, 34+60, self.scrollView.width, 60)];
            textField.hasLine = YES;
            textField.delegate = self;
            textField.title = @"有效期";
            textField.placeholder = @"如：0824";
            [self.scrollView addSubview:textField];
            
            self.dateCell = textField;
            [self.forms insertObject:textField atIndex:1];
        }
        
        /// 背后三位
        {
            NWBankFormCell *textField = [NWBankFormCell.alloc initWithFrame:CGRectMake(0, 34+60+60, self.scrollView.width, 60)];
            textField.hasLine = YES;
            textField.delegate = self;
            textField.title = @"背后三位";
            textField.placeholder = @"如：824";
            [self.scrollView addSubview:textField];
            
            self.backNumberCell = textField;
            [self.forms insertObject:textField atIndex:2];
        }
        
    } else if (self.cardType == NWPaymentTypeDepositCard && self.forms.count == 8) {
        needAnimated = YES;
        [self.forms[1] removeFromSuperview];
        [self.forms[2] removeFromSuperview];
        [self.forms removeObjectsInRange:NSMakeRange(1, 2)];
    }
    
    if (needAnimated) {
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat y = 34;
            
            for (UIView *subView in self.forms) {
                if ([subView isKindOfClass:NWBankFormCell.class]) {
                    subView.top = y;
                    y = subView.bottom;
                } else {
                    subView.top = y + 30;
                }
            }
        }];
    }
}

- (void)buttonClicked:(id)sender
{   
    if (!self.firstParams) {
        [MBProgressHUD showError:@"没有获取验证码" toView:self.view];
        return;
    }
    
    if (self.smsCell.text.length == 0) {
        [MBProgressHUD showError:@"验证码未填写" toView:self.view];
        return;
    }
    
    if (self.completion) {
        
        /**
         data =     {
             cardno = "621799*********6";
             id = 1;
             merid = 300977;
             merorderid = 2021039767;
             phone = 1818553;
             reqid = "R007_37886_202103152";
             status = 2;
             uid = 2222;
             username = "";
             walletid = ;
         };
         */
        NSString *cardid = self.firstParams[@"id"];
        NSString *merorderid = self.firstParams[@"merorderid"];
        
        [MBProgressHUD showLoading:@"" toView:self.view];
        [TIOChat.shareSDK.walletManager finishBindBankCard:cardid merorderid:merorderid smscode:self.smsCell.text completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:self.view];
            } else {
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                self.completion(@{@"result" : @(YES)});
            }
        }];
    }
}

- (void)textfieldEditing:(UITextField *)textfield
{
    if (self.cardNoCell == textfield) {
        if (textfield.text.length >= 15 && textfield.text.length <= 19) {
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            
            NSString *url = [@"https://ccdcapi.alipay.com/validateAndCacheCardInfo.json?_input_charset=utf-8&cardBinCheck=true&cardNo=" stringByAppendingString:textfield.text];
            
            [manager GET:url parameters:nil headers:manager.requestSerializer.HTTPRequestHeaders progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                BOOL validated = [responseObject[@"validated"] boolValue];
                self.validated = validated;
                if (validated) {
                    NSString *cardType = responseObject[@"cardType"];
                    if ([cardType isEqualToString:@"DC"]) {
                        /// 储蓄卡
                        self.cardType = NWPaymentTypeDepositCard;
                    } else {
                        /// 信用卡
                        self.cardType = NWPaymentTypeCreditCard;
                    }
                    [self layout];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"验证银行卡号 %@",error);
            }];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - 倒计时

- (void)SMSButtonDidClicked:(UIButton *)button
{
    // 校验是否是手机号
    NSError *error = nil;
    [CBMobileValidator validateText:self.phoneCell.text error:&error];
    if (error) {
        [MBProgressHUD showError:error.localizedDescription toView:self.view];
        return;
    }
    
    if (!self.validated) {
        [MBProgressHUD showError:@"无效的银行卡" toView:self.view];
        return;
    }
    
    if (self.nameCell.text.length == 0) {
        [MBProgressHUD showError:@"姓名不能为空" toView:self.view];
        return;
    }
    
    if (self.identifierCell.text.length == 0) {
        [MBProgressHUD showError:@"身份证号不能为空" toView:self.view];
        return;
    }
    
    
    CBWeakSelf
    /// SDK 发起绑卡
    
    [MBProgressHUD showLoading:@"" toView:self.view];
    
    [TIOChat.shareSDK.walletManager beginBindBankCard:self.cardNoCell.text idCard:self.identifierCell.text mobile:self.phoneCell.text name:self.nameCell.text availabledate:nil cvv2:nil completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:self.view];
        } else {
            self.firstParams = responObject[@"data"];
        }
        
    }];
    
    
    [self startCountdownTimerIfNecessary];
}

- (void)startCountdownTimerIfNecessary
{
    if (self.countdownTimer) {
        return;
    }
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdownTimerDidFire:) userInfo:nil repeats:YES];
    self.smsButton.enabled = NO;
    self.smsButton.tag = 10;
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
