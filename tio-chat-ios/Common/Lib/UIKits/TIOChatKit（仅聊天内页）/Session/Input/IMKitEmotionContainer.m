//
//  IMKitContainer.m
//  CawBar
//
//  Created by admin on 2019/11/18.
//

#import "IMKitEmotionContainer.h"
#import "PPStickerKeyboard.h"
#import "PPUtil.h"
#import "PPStickerDataManager.h"
#import "NIMGrowingTextView.h"

@interface IMKitEmotionContainer () <PPStickerKeyboardDelegate>
@property (nonatomic, strong) PPStickerKeyboard *stickerKeyboard;
@end

@implementation IMKitEmotionContainer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    [self addSubview:self.stickerKeyboard];
}

- (PPStickerKeyboard *)stickerKeyboard
{
    if (!_stickerKeyboard) {
        _stickerKeyboard = [[PPStickerKeyboard alloc] init];
        _stickerKeyboard.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), [_stickerKeyboard heightThatFits]);
        _stickerKeyboard.delegate = self;
    }
    return _stickerKeyboard;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(size.width, [_stickerKeyboard heightThatFits]);
}

#pragma mark - PPStickerKeyboardDelegate

- (void)stickerKeyboard:(PPStickerKeyboard *)stickerKeyboard didClickEmoji:(PPEmoji *)emoji
{
    if (!emoji) {
        return;
    }

    UIImage *emojiImage = [UIImage imageNamed:[@"Sticker.bundle" stringByAppendingPathComponent:emoji.imageName]];
    if (!emojiImage) {
        return;
    }

    NSRange selectedRange = self.textView.selectedRange;
    NSString *emojiString = emoji.emojiDescription;
    NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithString:emojiString];
    [emojiAttributedString pp_setTextBackedString:[PPTextBackedString stringWithString:emojiString] range:emojiAttributedString.pp_rangeOfAll];

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [attributedText replaceCharactersInRange:selectedRange withAttributedString:emojiAttributedString];
    [attributedText addAttribute:NSFontAttributeName value:self.textView.font range:NSMakeRange(0, attributedText.length)];
    self.textView.attributedText = attributedText;
    self.textView.selectedRange = NSMakeRange(selectedRange.location + emojiAttributedString.length, 0);
    
    [self refreshTextUI];
}

- (void)stickerKeyboardDidClickDeleteButton:(PPStickerKeyboard *)stickerKeyboard
{
    NSRange selectedRange = self.textView.selectedRange;
    if (selectedRange.location == 0 && selectedRange.length == 0) {
        return;
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    if (selectedRange.length > 0) {
        [attributedText deleteCharactersInRange:selectedRange];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location, 0);
    } else {
        [attributedText deleteCharactersInRange:NSMakeRange(selectedRange.location - 1, 1)];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location - 1, 0);
    }

}

- (void)stickerKeyboardDidClickSendButton:(PPStickerKeyboard *)stickerKeyboard
{
    if ([self.delegate respondsToSelector:@selector(imkit_stickerKeyboardDidClickSendButton)]) {
        [self.delegate imkit_stickerKeyboardDidClickSendButton];
    }
}

#pragma mark - 解析表情

- (void)refreshTextUI
{
    if (!self.textView.text.length) {
        return;
    }
    
    UITextRange *markedTextRange = [self.textView markedTextRange];
    UITextPosition *position = [self.textView positionFromPosition:markedTextRange.start offset:0];
    if (position) {
        return;     // 正处于输入拼音还未点确定的中间状态
    }
    // 在输入框中存储为明文，用于网络传输纯字符串
    self.textView.plainText = [self plainText];
    
    NSRange selectedRange = self.textView.selectedRange;

    NSMutableAttributedString *attributedComment = [[NSMutableAttributedString alloc] initWithString:[self plainText] attributes:@{ NSFontAttributeName: self.textView.font, NSForegroundColorAttributeName: [UIColor pp_colorWithRGBString:@"#3B3B3B"] }];

    // 匹配表情
    [PPStickerDataManager.sharedInstance replaceEmojiForAttributedString:attributedComment font:self.textView.font];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1;
    [attributedComment addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attributedComment.pp_rangeOfAll];
    [attributedComment addAttribute:NSFontAttributeName value:self.textView.font range:NSMakeRange(0, attributedComment.length)];

    NSUInteger offset = self.textView.attributedText.length - attributedComment.length;
    self.textView.attributedText = attributedComment;
    self.textView.selectedRange = NSMakeRange(selectedRange.location - offset, 0);
}

- (NSString *)plainText
{
    return [self.textView.attributedText pp_plainTextForRange:NSMakeRange(0, self.textView.attributedText.length)];
}

@end
