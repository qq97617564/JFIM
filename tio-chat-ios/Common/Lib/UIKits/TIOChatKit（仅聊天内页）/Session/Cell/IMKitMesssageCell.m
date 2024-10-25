//
//  IMMesssageCell.m
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import "IMKitMesssageCell.h"
#import "TIOChatKit.h"
#import "UIImage+TColor.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@interface IMKitMesssageCell () <IMKitMessageContentViewDelegate>

@property (strong, nonatomic) IMKitMessageModel *messageModel;

@end

@implementation IMKitMesssageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
//        static UIImage *IMRetryButtonImage;
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            IMRetryButtonImage = [UIImage imageNamed:@""];
//        });
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = YES;
        self.contentView.userInteractionEnabled = YES;
        
        // 消息发送中的转圈按钮
        _traningActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,20,20)];
        [self.contentView addSubview:_traningActivityIndicator];
        
        // 消息重发按钮
//        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_retryButton setImage:IMRetryButtonImage forState:UIControlStateNormal];
//        [_retryButton setImage:IMRetryButtonImage forState:UIControlStateHighlighted];
//        [_retryButton setFrame:CGRectMake(0, 0, 20, 20)];
//        [_retryButton addTarget:self action:@selector(onRetryMessage:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_retryButton];
        
        // 头像
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//        _avatarView.image = [UIImage imageNamed:@"placeholder_head"];
//        _avatarView.cornerRadius = TIOChatKit.shareSDK.config.cornerRadius;
//        [_avatarView addTarget:self action:@selector(onTapAvatar:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_avatarView];
        _avatarView.userInteractionEnabled = YES;
        [_avatarView addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onTapAvatar:)]];
        [self.contentView addSubview:_avatarView];
        
        // 名字
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font   = TIOChatKit.shareSDK.config.nickFont;
        _nameLabel.textColor = TIOChatKit.shareSDK.config.nickColor;
        [self.contentView addSubview:_nameLabel];
        
        // 时间
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font   = TIOChatKit.shareSDK.config.timeFont;
        _timeLabel.textColor = TIOChatKit.shareSDK.config.timeColor;
        [self.contentView addSubview:_timeLabel];
        
        _readStatusLabel = [UILabel.alloc init];
        _readStatusLabel.textColor = TIOChatKit.shareSDK.config.msgUnReadColor;
        _readStatusLabel.font = TIOChatKit.shareSDK.config.msgReadFont;
        _retryButton.hidden = YES;
        [self.contentView addSubview:_readStatusLabel];
        
        UILongPressGestureRecognizer *longGesture = [UILongPressGestureRecognizer.alloc initWithTarget:self action:@selector(longPress:)];
        longGesture.delegate = self;
        [self addGestureRecognizer:longGesture];
        
//        UILongPressGestureRecognizer *longAvatarGesture = [UILongPressGestureRecognizer.alloc initWithTarget:self action:@selector(longPressAvatar:)];
//        longAvatarGesture.delegate = self;
//        [_avatarView addGestureRecognizer:longAvatarGesture];
        
//        UITapGestureRecognizer *tap = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(longPress:)];
//        tap.delegate = self;
//        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    self.messageModel = messageModel;
    if ([self checkData])
    {
        [self refresh];
    }
}

- (BOOL)checkData
{
    return [self.messageModel isKindOfClass:[IMKitMessageModel class]];
}

- (void)refresh
{
    [self addContentViewIfNotExist];
    
    self.backgroundColor = UIColor.clearColor;
    
    [_bubbleView refreshData:self.messageModel];
    [_bubbleView setNeedsLayout];
    
    _nameLabel.text = self.messageModel.message.from;
    
    BOOL isActivityIndicatorHidden = [self activityIndicatorHidden];
    if (isActivityIndicatorHidden)
    {
        [_traningActivityIndicator stopAnimating];
    }
    else
    {
        [_traningActivityIndicator startAnimating];
    }
    [_traningActivityIndicator setHidden:isActivityIndicatorHidden];
    [_retryButton setHidden:[self retryButtonHidden]];
    
    _timeLabel.text = [TIOKitTool showTime:self.messageModel.message.timestamp showDetail:YES];
    [_avatarView tio_imageUrl:self.messageModel.message.avatar placeHolderImageName:@"" radius:TIOChatKit.shareSDK.config.cornerRadius];
//    [_avatarView im_setImageWithURL:self.messageModel.message.avatar placeholderImage:[UIImage imageWithColor:UIColor.whiteColor]];
    
    _readStatusLabel.hidden = ![TIOChatKit.shareSDK.cellConfig shouldShowUnread:self.messageModel];
    
    [self setNeedsLayout];
}

- (BOOL)activityIndicatorHidden
{
    if (!self.messageModel.message.isReceivedMsg)
    {
        return self.messageModel.message.deliveryState != TIOMessageDeliveryStateDelivering;
    }
    return NO;
}

- (BOOL)retryButtonHidden
{
    id<IMCellLayoutConfig> layoutConfig = TIOChatKit.shareSDK.cellConfig;
    BOOL disable = NO;
    if ([layoutConfig respondsToSelector:@selector(disableRetryButton:)])
    {
        disable = [layoutConfig disableRetryButton:self.messageModel];
    }
    return disable;
}

- (void)addContentViewIfNotExist
{
    if (_bubbleView == nil)
    {
        id<IMCellLayoutConfig> layoutConfig = TIOChatKit.shareSDK.cellConfig;
        NSString *contentStr = [layoutConfig cellContent:self.messageModel];
        NSAssert([contentStr length] > 0, @"should offer cell content class name");
        Class clazz = NSClassFromString(contentStr);
        IMKitMessageContentView *contentView =  [[clazz alloc] init];
        NSAssert(contentView, @"can not init content view");
        _bubbleView = contentView;
        _bubbleView.delegate = self;
        [self.contentView addSubview:_bubbleView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutAvatar];
    [self layoutNameLabel];
    [self layoutBubbleView];
    [self layoutRetryButton];
    [self layoutActivityIndicator];
    [self layoutTimeLabel];
    [self layoutReadStatusLabel];
}

- (void)layoutAvatar
{
    if (self.messageModel.shouldShowAvatar)
    {
        _avatarView.hidden = NO;
        _avatarView.frame = [self avatarViewRect];
    }
    else
    {
        _avatarView.hidden = YES;
    }
}

- (void)layoutNameLabel
{
    if (![TIOChatKit.shareSDK.cellConfig shouldShowNick:self.messageModel]) {
        _nameLabel.hidden = YES;
        return;
    }
    _nameLabel.hidden = NO;
    
    CGPoint point = [TIOChatKit.shareSDK.cellConfig nickNameMargin:self.messageModel];
    [_nameLabel sizeToFit];
    if (_nameLabel.width > self.contentView.width * 0.4) {
        _nameLabel.width = self.contentView.width * 0.4;
    }
//    [_timeLabel sizeToFit];
    if (!self.messageModel.shouldShowLeft) {
        point = CGPointMake(self.width - _nameLabel.width - point.x, point.y);
    }
    _nameLabel.viewOrigin = point;
//    _timeLabel.centerY = _nameLabel.centerY;
//    _timeLabel.left = _nameLabel.right + 4;
}

- (void)layoutTimeLabel
{
    if (!self.messageModel.shouldShowTime)
    {
        _timeLabel.hidden = YES;
    }
    else
    {
        _timeLabel.hidden = NO;
        
        [_timeLabel sizeToFit];
        
        if (self.messageModel.shouldShowLeft) {
            // 左边的消息
//            CGPoint point = CGPointMake(self.messageModel.bubbleViewInsets.left, _bubbleView.bottom);
//            _readStatusLabel.hidden = YES;
//            _timeLabel.viewOrigin = point;
            if (![TIOChatKit.shareSDK.cellConfig shouldShowNick:self.messageModel]) {
                // 没有昵称
                CGPoint point = [TIOChatKit.shareSDK.cellConfig nickNameMargin:self.messageModel];
                _timeLabel.left = point.x;
                _timeLabel.top = _avatarView.top;
            } else {
                // 有昵称
                _timeLabel.left = _nameLabel.right + 10;
                _timeLabel.centerY = _nameLabel.centerY;
            }
        } else {
            // 自己发的消息
//            CGPoint point = CGPointMake(self.width - self.messageModel.bubbleViewInsets.left - _timeLabel.width, _bubbleView.bottom);
//            _readStatusLabel.hidden = NO;
//            _timeLabel.viewOrigin = point;
//            [_readStatusLabel sizeToFit];
//            _readStatusLabel.right = point.x - 10;
//            _readStatusLabel.centerY = _timeLabel.centerY;
            CGPoint point = [TIOChatKit.shareSDK.cellConfig nickNameMargin:self.messageModel];
            _timeLabel.right = self.width - point.x;
            _timeLabel.top = _avatarView.top;
        }
    }
}

- (void)layoutBubbleView
{
    // size 内容文本、图片、视频等的尺寸
    CGSize size  = [self.messageModel contentSize:self.width];
    // insets 上述内容距离气泡的四边距
    UIEdgeInsets insets = self.messageModel.contentViewInsets;
    size.width  = size.width + insets.left + insets.right;
    size.height = size.height + insets.top + insets.bottom;
    // 气泡尺寸 = 内容尺寸 + 四边距
    _bubbleView.viewSize = size;
    
    UIEdgeInsets contentInsets = self.messageModel.bubbleViewInsets;
    if (!self.messageModel.shouldShowLeft)
    {
        CGFloat protraitRightToBubble = 10.f;
        CGFloat right = self.messageModel.shouldShowAvatar? CGRectGetMinX(self.avatarView.frame)  - protraitRightToBubble : self.width;
        contentInsets.left = right - CGRectGetWidth(self.bubbleView.bounds);
    }
    _bubbleView.left = contentInsets.left;
    _bubbleView.top  = contentInsets.top;
}

- (void)layoutActivityIndicator
{
    if (_traningActivityIndicator.isAnimating) {
        CGFloat centerX = 0;
        if (!self.messageModel.shouldShowLeft)
        {
            centerX = CGRectGetMinX(_bubbleView.frame) - [self retryButtonBubblePadding] - CGRectGetWidth(_traningActivityIndicator.bounds)/2;;
        }
        else
        {
            centerX = CGRectGetMaxX(_bubbleView.frame) + [self retryButtonBubblePadding] +  CGRectGetWidth(_traningActivityIndicator.bounds)/2;
        }
        self.traningActivityIndicator.center = CGPointMake(centerX,
                                                           _bubbleView.center.y);
    }
}

- (void)layoutReadStatusLabel
{
    if (!_readStatusLabel.hidden) {
        if (self.messageModel.message.isReaded) {
            _readStatusLabel.text = @"已读";
            _readStatusLabel.textColor = TIOChatKit.shareSDK.config.msgReadColor;
        } else {
            _readStatusLabel.text = @"未读";
            _readStatusLabel.textColor = TIOChatKit.shareSDK.config.msgUnReadColor;
        }
        
        [_readStatusLabel sizeToFit];
        
        if (self.messageModel.message.isOutgoingMsg) {
            _readStatusLabel.right = _bubbleView.left - 6;
        } else {
            _readStatusLabel.left = _bubbleView.right + 6;
        }
        _readStatusLabel.bottom = _bubbleView.bottom;
    }
}

- (void)layoutRetryButton
{
    if (!_retryButton.isHidden) {
        CGFloat centerX = 0;
        if (self.messageModel.shouldShowLeft)
        {
            centerX = CGRectGetMaxX(_bubbleView.frame) + [self retryButtonBubblePadding] +CGRectGetWidth(_retryButton.bounds)/2;
        }
        else
        {
            centerX = CGRectGetMinX(_bubbleView.frame) - [self retryButtonBubblePadding] - CGRectGetWidth(_retryButton.bounds)/2;
        }
        
        _retryButton.center = CGPointMake(centerX, _bubbleView.center.y);
    }
}

#pragma mark - Private
- (CGRect)avatarViewRect
{
    CGFloat cellWidth = self.bounds.size.width;
    CGFloat protraitImageWidth = [self avatarSize].width;
    CGFloat protraitImageHeight = [self avatarSize].height;
    CGFloat selfProtraitOriginX   = (cellWidth - self.cellPaddingToAvatar.x - protraitImageWidth);
    return self.messageModel.shouldShowLeft ? CGRectMake(self.cellPaddingToAvatar.x,self.cellPaddingToAvatar.y,protraitImageWidth, protraitImageHeight) :  CGRectMake(selfProtraitOriginX, self.cellPaddingToAvatar.y,protraitImageWidth,protraitImageHeight);
}

- (CGPoint)cellPaddingToAvatar
{
    return self.messageModel.avatarMargin;
}

- (CGPoint)cellPaddingToNick
{
    return self.messageModel.nickNameMargin;
}

- (CGFloat)retryButtonBubblePadding {
    BOOL isFromMe = !self.messageModel.shouldShowLeft;
    return isFromMe ? 8 : 10;
}

- (CGSize)avatarSize
{
    return self.messageModel.avatarSize;
}

#pragma mark - IMKitMessageContentViewDelegate

- (void)onLongTap:(TIOMessage *)message
{
    if ([self.delegate respondsToSelector:@selector(onLongPressCell:inView:)]) {
        [self.delegate onLongPressCell:message inView:_bubbleView];
    }
}

- (void)onTap:(nonnull IMKitEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(onTapCell:)]) {
        [self.delegate onTapCell:event];
    }
}

#pragma mark - actions

- (void)onTapAvatar:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onTapAvatar:)])
    {
        [self.delegate onTapAvatar:self.messageModel.message];
    }
}

- (void)onRetryMessage:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRetryMessage:)]) {
        [self.delegate onRetryMessage:self.messageModel.message];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(onLongPressCell:inView:)]) {
            // 根据触摸点所在view分别触发回调：点击了头像、点击了气泡、点击了空白区域
            if ([self location:gesture onView:_bubbleView]) {
                [self.delegate onLongPressCell:self.messageModel.message inView:_bubbleView];
            } else if ([self location:gesture onView:_avatarView]) {
                [self.delegate onLongPressAvatar:self.messageModel.message];
            } else {
                //
            }
        }
    }
}

- (void)longPressAvatar:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(onLongPressAvatar:)]) {
            [self.delegate onLongPressAvatar:self.messageModel.message];
        }
    }
}

/// 检测手势位置是否在某个view
/// @param gesture 手势
/// @param view 要检测的view
- (BOOL)location:(UIGestureRecognizer *)gesture onView:(UIView *)view
{
    CGPoint point = [gesture locationInView:view];
    
    if (point.x < 0 || point.y < 0) return NO;
    
    if (point.x > CGRectGetWidth(view.frame) || point.y > CGRectGetHeight(view.frame)) return NO;
    
    return YES;
}

@end
