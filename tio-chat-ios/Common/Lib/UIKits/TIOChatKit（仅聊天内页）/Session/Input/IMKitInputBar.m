//
//  IMKitInputBar.m
//  CawBar
//
//  Created by admin on 2019/11/15.
//

#import "IMKitInputBar.h"
#import "IMKitAction.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"

@interface IMKitInputBar ()<NIMGrowingTextViewDelegate>

@property (strong, nonatomic) NSMutableArray *barViews;
@property (assign, nonatomic) IMInputStatus status;

@end

@implementation IMKitInputBar

- (instancetype)initWithFrame:(CGRect)frame delegate:(nonnull id<IMKitInputBarDelegate>)delegate
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.delegate = delegate;
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    self.backgroundColor = UIColor.whiteColor;
    // 切换录音按钮
    UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceButton.frame = CGRectMake(16, 8, 28, 28);
    [voiceButton setImage:[UIImage imageNamed:@"microphone"] forState:UIControlStateNormal];
    [voiceButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateSelected];
    [self addSubview:voiceButton];
    _voiceButton = voiceButton;
    
    _inputTextView = [[NIMGrowingTextView alloc] initWithFrame:CGRectMake(51, 8, self.width - 99 - 51, 40)];
    _inputTextView.layer.cornerRadius = 20;
    _inputTextView.layer.masksToBounds = YES;
    _inputTextView.font = [UIFont systemFontOfSize:16.0f];
    _inputTextView.textContainerInset = UIEdgeInsetsMake(8, 15, 4, 15);
    _inputTextView.maxNumberOfLines = 4;
    _inputTextView.minNumberOfLines = 1;
    _inputTextView.textColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
    _inputTextView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    _inputTextView.textViewDelegate = self;
    _inputTextView.returnKeyType = UIReturnKeySend;
    [self addSubview:_inputTextView];
    
    voiceButton.centerY = _inputTextView.centerY;
    
    // 更多按钮
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.viewSize = CGSizeMake(28, 28);
    moreButton.right = self.width - 16;
    moreButton.centerY = _inputTextView.centerY;
    [moreButton setImage:[UIImage imageNamed:@"moreFunction"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"moreFunction_selected"] forState:UIControlStateSelected];
    [self addSubview:moreButton];
    _moreButton = moreButton;
    
    UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    emojiButton.frame = CGRectMake(0, 0, 28, 28);
    emojiButton.right = moreButton.left - 10;
    emojiButton.centerY = moreButton.centerY;
    [emojiButton setImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
    [emojiButton setImage:[UIImage imageNamed:@"emoji_selected"] forState:UIControlStateSelected];
    [self addSubview:emojiButton];
    self.emojiButton = emojiButton;
    
    UIButton *recordVoiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordVoiceButton.frame = _inputTextView.frame;
    recordVoiceButton.layer.cornerRadius = 20;
    recordVoiceButton.layer.masksToBounds = YES;
    recordVoiceButton.backgroundColor = [UIColor colorWithHex:0xF9F9F9];
    [recordVoiceButton setTitle:@"按住说话"
                       forState:UIControlStateNormal];
    [recordVoiceButton setTitleColor:[UIColor colorWithHex:0x666666]
                            forState:UIControlStateNormal];
    
    recordVoiceButton.titleLabel.font = [UIFont systemFontOfSize:16];
    recordVoiceButton.hidden = YES;
    [self addSubview:recordVoiceButton];
    self.recordVoiceButton = recordVoiceButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _emojiButton.centerY = _inputTextView.centerY;
    
    self.moreButton.centerY = _inputTextView.centerY;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(self.width, 56);
}

- (BOOL)showKeyboard
{
    return self.inputTextView.isFirstResponder;
}

- (void)setShowKeyboard:(BOOL)showKeyboard
{
    if (showKeyboard) {
        [self.inputTextView becomeFirstResponder];
    } else {
        [self.inputTextView resignFirstResponder];
    }
}

- (void)setContentText:(NSString *)contentText
{
    self.inputTextView.text = contentText;
    self.inputTextView.plainText = contentText;
}

- (NSString *)contentText
{
    return self.inputTextView.text;
}

#pragma mark - 公开

- (void)refreshStatus:(IMInputStatus)status
{
    self.status = status;
    [self sizeToFit];
    
    if (status == IMInputStatusText || status == IMInputStatusMore)
    {
        self.recordVoiceButton.hidden = YES;
        self.inputTextView.hidden = NO;
        self.voiceButton.selected = NO;
        
        if (status == IMInputStatusText) {
            _moreButton.selected = NO;
            _emojiButton.selected = NO;
        } else {
            _moreButton.selected = YES;
            _emojiButton.selected = NO;
        }
    }
    else if(status == IMInputStatusAudio)
    {
        self.recordVoiceButton.hidden = NO;
        self.inputTextView.hidden = YES;
        self.voiceButton.selected = YES;
        _moreButton.selected = NO;
        _emojiButton.selected = NO;
    }
    else
    {
        self.recordVoiceButton.hidden = YES;
        self.inputTextView.hidden = NO;
        self.voiceButton.selected = NO;
        
        _moreButton.selected = NO;
        _emojiButton.selected = YES;
    }
}

#pragma mark - NIMGrowingTextViewDelegate
- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    BOOL should = YES;
    if ([self.delegate respondsToSelector:@selector(shouldChangeTextInRange:replacementText:)]) {
        should = [self.delegate shouldChangeTextInRange:range replacementText:replacementText];
    }
    return should;
}


- (BOOL)textViewShouldBeginEditing:(NIMGrowingTextView *)growingTextView
{
    BOOL should = YES;
    if ([self.delegate respondsToSelector:@selector(textViewShouldBeginEditing)]) {
        should = [self.delegate textViewShouldBeginEditing];
    }
    return should;
}

- (void)textViewDidEndEditing:(NIMGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(textViewDidEndEditing)]) {
        [self.delegate textViewDidEndEditing];
    }
}


- (void)textViewDidChange:(NIMGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(textViewDidChange)]) {
        [self.delegate textViewDidChange];
    }
}

- (void)willChangeHeight:(CGFloat)height
{
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 16, 8, 16);
    CGFloat toolBarHeight = height + insets.top + insets.bottom;
    
    if ([self.delegate respondsToSelector:@selector(toolBarWillChangeHeight:)]) {
        [self.delegate toolBarWillChangeHeight:toolBarHeight];
    }
}

- (void)didChangeHeight:(CGFloat)height
{
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 16, 8, 16);
    self.height = height + insets.top + insets.bottom;
    if ([self.delegate respondsToSelector:@selector(toolBarDidChangeHeight:)]) {
        [self.delegate toolBarDidChangeHeight:self.height];
    }
}

- (void)insertText:(NSString *)text
{
    NSRange range = self.inputTextView.selectedRange;
    NSString *replaceText = [self.inputTextView.text stringByReplacingCharactersInRange:range withString:text];
    range = NSMakeRange(range.location + text.length, 0);
    self.inputTextView.text = replaceText;
    self.inputTextView.selectedRange = range;
}

- (void)deleteText:(NSRange)range
{
    NSString *text = self.contentText;
    if (range.location + range.length <= [text length]
        && range.location != NSNotFound && range.length != 0)
    {
        NSString *newText = [text stringByReplacingCharactersInRange:range withString:@""];
        NSRange newSelectRange = NSMakeRange(range.location, 0);
        [self.inputTextView setText:newText];
        self.inputTextView.selectedRange = newSelectRange;
    }
}

- (NSRange)selectedRange
{
    return self.inputTextView.selectedRange;
}

@end
