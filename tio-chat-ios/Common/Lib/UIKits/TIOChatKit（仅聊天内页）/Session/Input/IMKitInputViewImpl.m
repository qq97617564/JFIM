//
//  IMKitInputView.m
//  CawBar
//
//  Created by admin on 2019/11/18.
//

#import "IMKitInputViewImpl.h"
#import "IMKitInputBar.h"
#import "IMKitEmotionContainer.h"
#import "IMKitMoreContainer.h"
#import "IMKitKeyInfo.h"
#import "NSAttributedString+PPAddition.h"
#import "FrameAccessor.h"
#import "IMInputAtCache.h"
#import "TAudioRecordHUD.h"

@interface IMKitInputViewImpl ()<IMKitInputBarDelegate, IMKitEmotionDelegate>
@property (strong, nonatomic) NSArray *barActionArray;
@property (strong, nonatomic) IMInputAtCache *atCache;
@property (assign, nonatomic) BOOL recordIsDragOut;
@property (strong, nonatomic) TAudioRecordHUD *audiorecordHUD;

@end

@implementation IMKitInputViewImpl

@synthesize delegate = _delegate;
@synthesize config = _config;
@synthesize actionDelegate = _actionDelegate;
@synthesize status = _status;
@synthesize recording = _recording;
@synthesize recordStatus = _recordStatus;
@synthesize recordTime = _recordTime;

- (instancetype)initWithFrame:(CGRect)frame config:(nonnull id<IMKitInputViewConfig>)config
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _config = config;
        _atCache = [IMInputAtCache.alloc init];
        _recording = NO;
    }
    
    return self;
}

- (void)didMoveToWindow
{
    if (!_bar) {
        _bar = [IMKitInputBar.alloc initWithFrame:CGRectMake(0, 0, self.width, 0) delegate:self];
        [_bar.voiceButton addTarget:self action:@selector(voiceButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_bar.emojiButton addTarget:self action:@selector(emojiButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_bar.moreButton addTarget:self action:@selector(moreButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 按下开始录音
        [_bar.recordVoiceButton addTarget:self action:@selector(pressToRecord:)
                         forControlEvents:UIControlEventTouchDown];
          
          // 手指滑到按钮外面
        [_bar.recordVoiceButton addTarget:self action:@selector(dragToOut:)
                         forControlEvents:UIControlEventTouchDragOutside];
          
          // 手指又回到按钮上
        [_bar.recordVoiceButton addTarget:self action:@selector(dragToReturnButton:)
                         forControlEvents:UIControlEventTouchDragEnter];
          
          // 手指从按钮上松开
        [_bar.recordVoiceButton addTarget:self action:@selector(finishRecording:)
                         forControlEvents:UIControlEventTouchUpInside];
          
          // 手指从按钮外面松开
        [_bar.recordVoiceButton addTarget:self action:@selector(cancelRecording:)
                         forControlEvents:UIControlEventTouchUpOutside];
    }
    [self addSubview:_bar];
    [_bar sizeToFit];
    
    [self sizeToFit];
}

- (void)checkEmotionContainer
{
    if (!_emojiContainer) {
        _emojiContainer = [IMKitEmotionContainer.alloc initWithFrame:CGRectMake(0, 0, self.width, 0)];
        _emojiContainer.viewSize = [_emojiContainer sizeThatFits:CGSizeMake(self.width, CGFLOAT_MAX)];
        _emojiContainer.hidden = YES;
        _emojiContainer.textView = _bar.inputTextView;
        _emojiContainer.delegate = self;
        [self addSubview:_emojiContainer];
    }
}

- (void)checkMoreContainer
{
    if (!_moreCcontainer) {
        _moreCcontainer = [IMKitMoreContainer.alloc initWithFrame:CGRectMake(0, 0, self.width, 220) config:_config];
        _moreCcontainer.delegate = self.actionDelegate;
        _moreCcontainer.hidden = YES;
        [self addSubview:_moreCcontainer];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bar.viewOrigin = CGPointZero;
    self.emojiContainer.top = self.bar.bottom;
    self.moreCcontainer.top = self.bar.bottom;
}

- (TAudioRecordHUD *)audiorecordHUD
{
    if (!_audiorecordHUD) {
        _audiorecordHUD = [TAudioRecordHUD.alloc initWithFrame:CGRectZero];
    }
    return _audiorecordHUD;
}

#pragma mark - InputBar Actions

- (void)voiceButtonDidClicked:(UIButton *)button
{
    if (self.status != IMInputStatusAudio) {
        /// 判断麦克风权限
        // TODO: 判断麦克风权限
        [self refreshStatus:IMInputStatusAudio];
        _bar.showKeyboard = NO;
        [self sizeToFit];
    } else {
        [self refreshStatus:IMInputStatusText];
        _bar.showKeyboard = YES;
    }
}

- (void)emojiButtonDidClicked:(UIButton *)button
{
    button.selected = YES;
    _bar.moreButton.selected = NO;
    if (self.status != IMInputStatusEmoticon) {
        if ([self.actionDelegate respondsToSelector:@selector(onTapEmoticonBtn:)]) {
            [self.actionDelegate onTapEmoticonBtn:button];
        }
        [self checkEmotionContainer];
        [self bringSubviewToFront:self.emojiContainer];
        [self.emojiContainer setHidden:NO];
        [self refreshStatus:IMInputStatusEmoticon];
        [self sizeToFit];
        
        if (!_moreCcontainer) {
            _moreCcontainer.hidden = YES;
        }
        
        if (self.bar.showKeyboard)
        {
            self.bar.showKeyboard = NO;
        }
    } else {
        self.bar.showKeyboard = NO;
    }
}

- (void)moreButtonDidClicked:(UIButton *)button
{
    button.selected = YES;
    _bar.emojiButton.selected = NO;
    if (self.status != IMInputStatusMore) {
        if ([self.actionDelegate respondsToSelector:@selector(onTapMoreBtn:)]) {
            [self.actionDelegate onTapMoreBtn:button];
        }
        [self checkMoreContainer];
        [self bringSubviewToFront:self.moreCcontainer];
        [self.moreCcontainer setHidden:NO];
        [self refreshStatus:IMInputStatusMore];
        [self sizeToFit];
        
        if (!_emojiContainer) {
            _emojiContainer.hidden = YES;
        }
        
        if (self.bar.showKeyboard)
        {
            self.bar.showKeyboard = NO;
        }
    } else {
        self.bar.showKeyboard = NO;
    }
}

/// 按住说话
- (void)pressToRecord:(UIButton *)button
{
    self.recordStatus = AudioRecordStatusBegin;
}

/// 拖拽到外面
- (void)dragToOut:(UIButton *)button
{
    if (self.recordIsDragOut) {
        return;
    }
    
    self.recordStatus = AudioRecordStatusCancelling;
}

/// 拖拽回按钮
- (void)dragToReturnButton:(UIButton *)button
{
    self.recordStatus = AudioRecordStatusRecording;
}

/// 结束录音
- (void)finishRecording:(UIButton *)button
{
    self.recordStatus = AudioRecordStatusEnd;
    
    if (@protocol(IMKitInputViewActionDelegate) && [_actionDelegate respondsToSelector:@selector(recordFinishInButton)]) {
        [_actionDelegate recordFinishInButton];
    }
}
    
/// 取消录音
- (void)cancelRecording:(UIButton *)button
{
    self.recordStatus = AudioRecordStatusEnd;
    
    if (@protocol(IMKitInputViewActionDelegate) && [_actionDelegate respondsToSelector:@selector(recordFinishOutButton)]) {
        [_actionDelegate recordFinishOutButton];
    }
}

#pragma mark - IMKitInputBarConfig

- (CGSize)sizeThatFits:(CGSize)size
{
    //这里不做.语法 get 操作，会提前初始化组件导致卡顿
    CGFloat toolBarHeight = _bar.height;
    CGFloat containerHeight = 0;
    switch (self.status)
    {
        case IMInputStatusEmoticon:
            containerHeight = _emojiContainer.height;
            break;
        case IMInputStatusMore:
            containerHeight = _moreCcontainer.height;
            break;
        default:
        {
            UIEdgeInsets safeArea = UIEdgeInsetsZero;
            if (@available(iOS 11.0, *))
            {
                safeArea = self.superview.safeAreaInsets;
            }
            //键盘是从最底下弹起的，需要减去安全区域底部的高度
            CGFloat keyboardDelta = IMKitKeyInfo.instance.keyboardHeight - safeArea.bottom;
            
            //如果键盘还没有安全区域高，容器的初始值为0；否则则为键盘和安全区域的高度差值，这样可以保证 toolBar 始终在键盘上面
            containerHeight = keyboardDelta>0 ? keyboardDelta : 0;
        }
            break;
    }
    CGFloat height = toolBarHeight + containerHeight;
    CGFloat width = self.superview? self.superview.width : self.width;
    return CGSizeMake(width, height);
}

- (BOOL)textViewShouldBeginEditing
{
    [self refreshStatus:IMInputStatusText];
    return YES;
}

- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self didPressSend:nil];;
        return NO;
    }
    
    if ([text isEqualToString:@""] && range.length == 1)
    {
        //非选择删除
        return [self onTextDelete];
    }
    
    if ([self shouldAt]) {
        [self checkAt:text];
    }
    
    // 限制一次消息发送中的最大字数
    NSInteger maxCount = 1000; // 默认一次输入或粘贴最多1000个字符
    
    if ([self.config respondsToSelector:@selector(maxInputCharCount)]) maxCount = [self.config maxInputCharCount];
    
    NSString *str = [self.bar.contentText stringByAppendingString:text];
    
    if (str.length > maxCount)
    {
        self.bar.contentText = [str substringToIndex:maxCount];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange
{
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onTextChanged:)])
    {
        [self.actionDelegate onTextChanged:self];
    }
}

- (void)textViewDidEndEditing
{
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onTextChanged:)])
    {
        [self.actionDelegate onTextChanged:self];
    }
}


- (void)toolBarWillChangeHeight:(CGFloat)height
{
    [self sizeToFit];
}

- (void)toolBarDidChangeHeight:(CGFloat)height
{
    [self sizeToFit];
}

- (void)sendText:(nonnull NSString *)text {
    
}

- (BOOL)onTextDelete
{
    NSRange range = NSMakeRange([self.bar selectedRange].location - 1, 1);
    if (range.length == 1)
    {
        //删的不是表情，可能是@
        IMInputAtObject *item = [self delRangeForAt];
        if (item) {
            range = item.range;
            [self.atCache removeName:item.nick];
        }
    }
    if (range.length == 1) {
        //自动删除
        return YES;
    }
    [self.bar deleteText:range];
    return NO;
}

- (IMInputAtObject *)delRangeForAt
{
    NSString *text = self.bar.contentText;
    NSRange range = [self rangeForPrefix:InputAtStartChar suffix:InputAtEndChar];
    NSRange selectedRange = [self.bar selectedRange];
    IMInputAtObject *item = nil;
    if (range.length > 1)
    {
        NSString *name = [text substringWithRange:range];
        NSString *set = [InputAtStartChar stringByAppendingString:InputAtEndChar];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:set]];
        item = [self.atCache item:name];
        range = item? range : NSMakeRange(selectedRange.location - 1, 1);
    }
    item.range = range;
    return item;
}

/// 根据匹配的起始和结束字符匹配范围
/// @param prefix 起始字符
/// @param suffix 结束字符
- (NSRange)rangeForPrefix:(NSString *)prefix suffix:(NSString *)suffix
{
    NSString *text = self.bar.contentText;
    NSRange range = [self.bar selectedRange];
    NSString *selectedText = range.length ? [text substringWithRange:range] : text;
    NSInteger endLocation = range.location;
    if (endLocation <= 0)
    {
        return NSMakeRange(NSNotFound, 0);
    }
    NSInteger index = -1;
    if ([selectedText hasSuffix:suffix]) {
        //往前搜最多20个字符，一般来讲是够了...
        NSInteger p = 20;
        for (NSInteger i = endLocation; i >= endLocation - p && i-1 >= 0 ; i--)
        {
            NSRange subRange = NSMakeRange(i - 1, 1);
            NSString *subString = [text substringWithRange:subRange];
            if ([subString compare:prefix] == NSOrderedSame)
            {
                index = i - 1;
                break;
            }
        }
    }
    return index == -1? NSMakeRange(endLocation - 1, 1) : NSMakeRange(index, endLocation - index);
}

/// 是否开启AT
- (BOOL)shouldAt
{
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(shouldAt)]) {
        return [self shouldAt];
    }
    return YES;
}

- (void)checkAt:(NSString *)text
{
    if ([text isEqualToString:InputAtStartChar]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(beginAt:)]) {
            [self.delegate beginAt:self];
        }
    }
}

#pragma mark - IMKitInputView

- (UIView *)view
{
    return self;
}

- (UIView *)toolBar
{
    return self;
}

- (BOOL)keyboardIsVisiable
{
    return [IMKitKeyInfo.instance isVisiable];
}

- (void)forbidSpeaking:(BOOL)isForbidSpeaking
{
    
}

- (BOOL)endEditing:(BOOL)force
{
    BOOL endEditing = [super endEditing:force];
    if (!self.bar.showKeyboard) {
        UIViewAnimationCurve curve = UIViewAnimationCurveEaseInOut;
        void(^animations)(void) = ^{
            [self refreshStatus:IMInputStatusText];
            [self sizeToFit];
        };
        NSTimeInterval duration = 0.25;
        [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
    }
    
    return endEditing;
}

- (void)beginEditing
{
    self.bar.showKeyboard = YES;
}

- (void)refreshStatus:(IMInputStatus)status
{
    self.status = status;
    [_bar refreshStatus:status];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.emojiContainer.hidden = status != IMInputStatusEmoticon;
        self.moreCcontainer.hidden = status != IMInputStatusMore;
    });
}

- (void)insertText:(NSString *)text
{
    [self.bar insertText:text];
}

- (void)insertAtUser:(NSString *)nick uid:(NSString *)uid hasAtChar:(BOOL)hasAtChar
{
    IMInputAtObject *atUser = [IMInputAtObject.alloc init];
    atUser.nick = nick;
    atUser.uid = uid;
    [self.atCache addItem:atUser];
    
    if (hasAtChar) {
        [self insertText:[NSString stringWithFormat:@"@%@%@",nick,InputAtEndChar]];
    } else {
        [self insertText:[nick stringByAppendingString:InputAtEndChar]];
    }
}

- (void)setRecording:(BOOL)recording
{
    if (recording) {
        self.audiorecordHUD.center = self.superview.middlePoint;
        [self.superview addSubview:self.audiorecordHUD];
    } else {
        [self.audiorecordHUD removeFromSuperview];
    }
}

- (void)setRecordStatus:(TAudioRecordStatus)recordStatus
{
    switch (recordStatus) {
        case AudioRecordStatusBegin:
        {
            self.recordIsDragOut = NO;
            self.recording = YES;
            self.audiorecordHUD.status = AudioRecordStatusRecording;
            
            // 改变录音按钮
            [_bar.recordVoiceButton setTitle:@"松手发送" forState:UIControlStateNormal];
            _bar.recordVoiceButton.backgroundColor = [UIColor colorWithHex:0xE7E8EB];
            [_bar.recordVoiceButton setTitleColor:[UIColor colorWithHex:0x666666] forState:UIControlStateNormal];
            
            if ([_actionDelegate respondsToSelector:@selector(recordBeginTouch)] && @protocol(IMKitInputViewActionDelegate)) {
                [_actionDelegate recordBeginTouch];
            }
        }
            break;
        case AudioRecordStatusRecording:
        {
            self.recordIsDragOut = NO;
            self.recording = YES;
            self.audiorecordHUD.status = AudioRecordStatusRecording;
            
            [_bar.recordVoiceButton setTitle:@"松手发送" forState:UIControlStateNormal];
            _bar.recordVoiceButton.backgroundColor = [UIColor colorWithHex:0xE7E8EB];
            [_bar.recordVoiceButton setTitleColor:[UIColor colorWithHex:0x666666] forState:UIControlStateNormal];
            
            if (@protocol(IMKitInputViewActionDelegate) && [_actionDelegate respondsToSelector:@selector(recordDragBackToButton)]) {
                [_actionDelegate recordDragBackToButton];
            }
        }
            break;
        case AudioRecordStatusCancelling:
        {
            self.recordIsDragOut = YES;
            self.audiorecordHUD.status = AudioRecordStatusCancelling;
            
            [_bar.recordVoiceButton setTitle:@"取消发送" forState:UIControlStateNormal];
            _bar.recordVoiceButton.backgroundColor = [UIColor colorWithHex:0xE7E8EB];
            [_bar.recordVoiceButton setTitleColor:[UIColor colorWithHex:0x666666] forState:UIControlStateNormal];
            
            if (@protocol(IMKitInputViewActionDelegate) && [_actionDelegate respondsToSelector:@selector(recordDragToOut)]) {
                [_actionDelegate recordDragToOut];
            }
        }
            break;
        case AudioRecordStatusEnd:
        {
            self.recording = NO;
            self.recordIsDragOut = NO;
            
            [_bar.recordVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
            _bar.recordVoiceButton.backgroundColor = [UIColor colorWithHex:0xF9F9F9];
            [_bar.recordVoiceButton setTitleColor:[UIColor colorWithHex:0x666666] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

- (void)setRecordTime:(NSTimeInterval)recordTime
{
    self.audiorecordHUD.recordTime = recordTime;
}

#pragma mark - IMKitEmotionDelegate

- (void)imkit_stickerKeyboardDidClickSendButton
{
    [self didPressSend:nil];
}

#pragma mark - Actions

- (void)didPressSend:(id)sender{
    NSString *str = [self.bar.inputTextView.attributedText pp_plainTextForRange:NSMakeRange(0, self.bar.inputTextView.attributedText.length)];
    if ([self.actionDelegate respondsToSelector:@selector(onSendText:atUsers:)] && [str length] > 0) {
        NSString *sendText = str;
        
        NSMutableArray *allAtUids = [NSMutableArray arrayWithCapacity:self.atCache.allAtObject.count];
        [[self.atCache allAtObject] enumerateObjectsUsingBlock:^(IMInputAtObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [allAtUids addObject:obj.uid];
        }];
        
        [self.actionDelegate onSendText:sendText atUsers:allAtUids];
        [self.atCache clean];
        self.bar.contentText = @"";
        [self.bar layoutIfNeeded];
    }
}

- (void)setFrame:(CGRect)frame
{
    CGFloat height = self.frame.size.height;
    [super setFrame:frame];
    if (frame.size.height != height)
    {
        [self callDidChangeHeight];
    }
}

- (void)callDidChangeHeight
{
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeInputHeight:)])
    {
        if (self.status == IMInputStatusMore || self.status == IMInputStatusEmoticon || self.status == IMInputStatusAudio)
        {
            //这个时候需要一个动画来模拟键盘
            [UIView animateWithDuration:0.25 delay:0 options:7 animations:^{
                [self->_delegate didChangeInputHeight:self.height];
            } completion:nil];
        }
        else
        {
            [_delegate didChangeInputHeight:self.height];
        }
    }
}



@end
