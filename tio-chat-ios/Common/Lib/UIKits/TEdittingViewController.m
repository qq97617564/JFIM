//
//  TEdittingViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TEdittingViewController.h"
#import "FrameAccessor.h"
#import "MBProgressHUD+NJ.h"

@interface TEdittingViewController () <UITextViewDelegate>
/// 初始内容回显
@property (copy,    nonatomic) NSString *text;

/// 输入框类型
@property (assign,  nonatomic) TEdittingInputType inputType;

@property (strong,  nonatomic) UITextField  *inputField;

@property (strong,  nonatomic) UITextView   *inputView;

/// 字数统计
@property (strong,  nonatomic) UILabel *textCountLabel;

@end

@implementation TEdittingViewController

- (instancetype)initWithTitle:(NSString *)title text:(nonnull NSString *)text inputType:(TEdittingInputType)inputType
{
    self = [super init];
    
    if (self) {
        self.text = text;
        self.inputType = inputType;
        self.leftBarButtonText = title;
        if (inputType == TEdittingInputTypeField) {
            self.inpuHeight = 60;
        } else {
            self.inpuHeight = 200;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    
    [self setupNav];
    
    if (self.inputType == TEdittingInputTypeField) {
        [self setupField];
    } else {
        [self setupTextView];
    }
    [self setupCountLabel];
}

- (void)setupField
{
    self.inputField = [UITextField.alloc initWithFrame:CGRectMake(0, Height_NavBar+20, self.view.width, self.inpuHeight)];
    self.inputField.text = self.text;
    self.inputField.backgroundColor = UIColor.whiteColor;
    self.inputField.font = [UIFont systemFontOfSize:16];
    self.inputField.textColor = UIColor.blackColor;
    self.inputField.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 16, self.inpuHeight)];
    self.inputField.leftViewMode = UITextFieldViewModeAlways;
    [self.inputField addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.inputField];
}

- (void)setupTextView
{
    self.inputView = [UITextView.alloc initWithFrame:CGRectMake(0, Height_NavBar+20, self.view.width, self.inpuHeight)];
    self.inputView.backgroundColor = [UIColor whiteColor];
    self.inputView.text = self.text;
    self.inputView.backgroundColor = UIColor.whiteColor;
    self.inputView.font = [UIFont systemFontOfSize:16];
    self.inputView.textColor = UIColor.blackColor;
    self.inputView.textContainerInset = UIEdgeInsetsMake(10, 16, 0, 10);
    self.inputView.delegate = self;
    [self.view addSubview:self.inputView];
}

- (void)setupNav
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor colorWithHex:0x4C94E8]];
        [button setTitle:@"提交" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.viewSize = CGSizeMake(60, 28);
        button.layer.cornerRadius = 14;
        button.layer.masksToBounds = YES;
        
        [button addTarget:self action:@selector(didClickDone:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    })];
}

- (void)setupCountLabel
{
    /// 当前的输入框
    UIView *inputView = self.inputField?:self.inputView;
    
    self.textCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 16 - 60, inputView.bottom + 16, 60, 20)];
    self.textCountLabel.font = [UIFont systemFontOfSize:14.f];
    self.textCountLabel.textColor = [UIColor colorWithHex:0x909090];
    self.textCountLabel.textAlignment = NSTextAlignmentRight;
    self.textCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)self.text.length,(long)self.maxNumber];
    [self.view addSubview:self.textCountLabel];
}

- (void)didClickDone:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(t_edittingViewController:didFinishedText:handler:)]) {
        
        [self.delegate t_edittingViewController:self didFinishedText:self.text handler:^(BOOL flag, NSString * _Nullable msg) {
            if (flag)
            {
                if (msg) {
                    [MBProgressHUD showSuccess:msg toView:self.view];
                }
            }
            else
            {
                if (msg) {
                    [MBProgressHUD showError:msg toView:self.view];
                }
            }
                
        }];
    }
}

- (void)textFieldEditing:(UITextField *)textField
{
    self.text = textField.text;
    
    NSString *lang = [[[UITextInputMode activeInputModes] firstObject] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"])  {
        UITextRange *range = [textField markedTextRange];
        UITextPosition *start = range.start;
        UITextPosition*end = range.end;
        NSInteger selectLength = [textField offsetFromPosition:start toPosition:end];
        NSInteger contentLength = textField.text.length - selectLength;
        
        if (contentLength > self.maxNumber) {
            textField.text = [textField.text substringToIndex:self.maxNumber];
            return;
        }
        if (contentLength < self.maxNumber) {
            self.textCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)contentLength,(long)self.maxNumber];
        } else {
            self.textCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.maxNumber,(long)self.maxNumber];
        }
    } else {
        if (textField.text.length > self.maxNumber) {
            textField.text = [textField.text substringToIndex:self.maxNumber];
            return;
        }
        if (textField.text.length < self.maxNumber) {
            self.textCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)textField.text.length,(long)self.maxNumber];
        } else {
            self.textCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.maxNumber,(long)self.maxNumber];
        }
    }
}


/** 限制字符输入，过滤正在拼写时的字母 */
- (void)textViewDidChange:(UITextView *)textView
{
    self.text = textView.text;
    
    NSString *lang = [[[UITextInputMode activeInputModes] firstObject] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"])  {
        UITextRange *range = [textView markedTextRange];
        UITextPosition *start = range.start;
        UITextPosition*end = range.end;
        NSInteger selectLength = [textView offsetFromPosition:start toPosition:end];
        NSInteger contentLength = textView.text.length - selectLength;
        
        if (contentLength > self.maxNumber) {
            textView.text = [textView.text substringToIndex:self.maxNumber];
            return;
        }
        if (contentLength < self.maxNumber) {
            self.textCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)contentLength,(long)self.maxNumber];
        } else {
            self.textCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.maxNumber,(long)self.maxNumber];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

@end
