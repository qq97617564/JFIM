//
//  TAlertController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TAlertController.h"
#import "TAlertTrasitioning.h"
#import "FrameAccessor.h"
#import "UIImage+TColor.h"

@interface TAlertAction ()
@property (nonatomic, assign) TAlertActionStyle style;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) TAlertActionHandler handler;
@end

@implementation TAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(TAlertActionStyle)style handler:(TAlertActionHandler)handler
{
    return [self.alloc initWithTitle:title style:style handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(TAlertActionStyle)style handler:(TAlertActionHandler)handler
{
    self = [super init];
    
    if (self) {
        self.title = title;
        self.style = style;
        self.handler = handler;
    }
    
    return self;
}

@end


static TAlertTheme *__theme = nil;
static TAlertLayout *__layout = nil;
static TAlertLayout *__actionSheetLayout = nil;

@interface TAlertController () <UIViewControllerTransitioningDelegate>
@property (copy, nonatomic) NSString *message;
@property (strong, nonatomic) NSMutableArray<TAlertAction *> *actions;
@property (nonatomic, nullable) NSArray<UIButton *> *actionButtons;

@property (strong, nonatomic) TAlertTrasitioning *transitioning;
@property (assign, nonatomic) TAlertControllerStyle preferredStyle;

/// 仅仅计算文本高度用 不做显示
@property (nonatomic, strong) UILabel *sizeLabel;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) TAlertTheme *theme;
@property (strong, nonatomic) TAlertLayout *layout;

@end

@implementation TAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(TAlertControllerStyle)preferredStyle
{
    if (preferredStyle == TAlertControllerStyleActionSheet) {
        return [self.alloc initSheet];
    }
    
    return [self.alloc initWithTitle:title message:message];
}

// TAlertControllerStyleAlert
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        self.maxActionCountOfOneLine = 2;
        self.preferredStyle = TAlertControllerStyleAlert;
        [self commonInit];
    }
    return self;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title customView:(UIView *)customView preferredStyle:(TAlertControllerStyle)preferredStyle
{
    return [self.alloc initWithTitle:title contentView:customView];
}

- (instancetype)initWithTitle:(NSString *)title contentView:(UIView *)contentView
{
    self = [super init];
    if (self) {
        self.title = title;
        self.maxActionCountOfOneLine = 2;
        self.preferredStyle = TAlertControllerStyleAlert;
        self.contentView = contentView;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCustomView:(UIView *)customView
{
    self = [super init];
    
    if (self) {
        self.maxActionCountOfOneLine = 2;
        self.preferredStyle = TAlertControllerStyleAlert;
        self.contentView = customView;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithHeaderView:(UIView *)headerView
{
    self = [super init];
    if (self) {
        self.headerView = headerView;
        self.preferredStyle = TAlertControllerStyleActionSheet;
        [self commonInit];
        self.transitioning.presentingStyle = AlertPresentStyleBottom;
        self.transitioning.dismissStyle = AlertPresentStyleBottomToCenterSpring;
    }
    return self;
}

// TAlertControllerStyleActionSheet

- (instancetype)initSheet
{
    self = [super init];
    if (self) {
        self.preferredStyle = TAlertControllerStyleActionSheet;
        [self commonInit];
        self.transitioning.presentingStyle = AlertPresentStyleBottom;
        self.transitioning.dismissStyle = AlertPresentStyleBottomToCenterSpring;
    }
    return self;
}

- (void)commonInit
{
    self.actions = [NSMutableArray array];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.transitioning = [[TAlertTrasitioning alloc] init];
    self.transitioningDelegate = self;
}

- (void)loadView
{
    CGSize contentSize = self.preferredContentSize;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    view.backgroundColor = UIColor.whiteColor;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = __layout.cornerRadius;
    self.view = view;
    // 内容区
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    containerView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:containerView];
    self.containerView = containerView;
    
//    self.view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2].CGColor;
//    self.view.layer.shadowOffset = CGSizeMake(0,0);
//    self.view.layer.shadowOpacity = 1;
//    self.view.layer.shadowRadius = 9;
    
    if (self.preferredStyle == TAlertControllerStyleActionSheet) {
        [self setupActionSheet];
    } else {
        if (self.contentView) {
            if (self.title) {
                [self setupAlertContentView];
            } else {
                [self setupCutomView];
            }
        } else {
            [self setupAlertContentView];
        }
    }
    
    
    [self updateTheme];
}

- (void)setupActionSheet
{
    CGSize contentSize = self.preferredContentSize;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(__actionSheetLayout.cornerRadius, __actionSheetLayout.cornerRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.containerView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.containerView.layer.mask = maskLayer;
    
    self.containerView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    
    CGFloat actionStartY = 0;
    
    if (self.headerView) {
        self.headerView.frame = CGRectMake(0, 0, contentSize.width, self.headerView.height);
        [self.headerView addSubview:({
            UIView *line = [UIView.alloc initWithFrame:CGRectMake(0, self.headerView.height - 0.5, self.headerView.width, self.headerView.height)];
            line.backgroundColor = [UIColor colorWithHex:0xF5F5F5];
            line;
        })];
        [self.containerView addSubview:self.headerView];
        
        actionStartY = self.headerView.height;
    }
    
    // 按钮
    NSMutableArray<UIButton *> *array = [NSMutableArray array];
    [self.actions enumerateObjectsUsingBlock:^(TAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = UIColor.whiteColor;
        [button setTitle:obj.title forState:UIControlStateNormal];
        if (idx == self.actions.count - 1) {
            button.frame = CGRectMake(0, contentSize.height - __actionSheetLayout.actionHeight - safeBottomHeight, contentSize.width, __actionSheetLayout.actionHeight + safeBottomHeight);
        } else {
            button.frame = CGRectMake(0, actionStartY + (__actionSheetLayout.actionHeight+1) * idx, contentSize.width, __actionSheetLayout.actionHeight);
        }
        [button addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:button];
        [array addObject:button];
    }];
    _actionButtons = array.copy;
}

- (void)setupAlertContentView
{
    CGSize contentSize = self.preferredContentSize;
    
//    self.containerView.layer.masksToBounds = YES;
//    self.containerView.layer.cornerRadius = __layout.cornerRadius;
    
    // 标题区
    if (self.title.length) {
        // 文字
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(__layout.contentInset.left, __layout.contentInset.top, contentSize.width - __layout.contentInset.left - __layout.contentInset.right, 0)];
        titleLabel.textAlignment = __layout.titleAligment;
        titleLabel.textColor = __theme.titleTextAttributes[NSForegroundColorAttributeName];
        titleLabel.font = __theme.titleTextAttributes[NSFontAttributeName];
        titleLabel.text = self.title;
        titleLabel.numberOfLines = 0;
        [titleLabel sizeToFit];
        titleLabel.width = contentSize.width - __layout.contentInset.left - __layout.contentInset.right;
        titleLabel.height += 4;
        [self.containerView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    // 内容区
    if (self.message.length) {
        CGFloat messageHeight = ({
            CGFloat height = [self.message boundingRectWithSize:CGSizeMake(contentSize.width-__layout.contentInset.left - __layout.contentInset.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:__theme.messageTextAttributes context:nil].size.height;
            height = MIN(height, 250);
            height;
        });
        CGFloat originY = self.title.length ? CGRectGetMaxY(self.titleLabel.frame) + 16 : __layout.contentInset.top;
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(__layout.contentInset.left, originY, contentSize.width-__layout.contentInset.left - __layout.contentInset.right, messageHeight)];
        messageLabel.font = __theme.messageTextAttributes[NSFontAttributeName];
        messageLabel.textColor = __theme.messageTextAttributes[NSForegroundColorAttributeName];
        messageLabel.numberOfLines = 0;
        messageLabel.text = self.message;
        messageLabel.textAlignment = __layout.messageAligment;
        //([messageLabel sizeThatFits:messageLabel.frame.size].height/messageLabel.font.lineHeight >= 2.0) ? NSTextAlignmentJustified : NSTextAlignmentCenter;
        [self.containerView addSubview:messageLabel];
        _messageLabel = messageLabel;
    } else if (self.contentView) {
        self.contentView.frame = CGRectMake(24, CGRectGetMaxY(self.titleLabel.frame) + 16, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        [self.containerView addSubview:self.contentView];
    }
    // 按钮
    NSMutableArray<UIButton *> *array = [NSMutableArray array];
    [self.actions enumerateObjectsUsingBlock:^(TAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:obj.title forState:UIControlStateNormal];
        button.frame = [self actionButtonFrameAtIndex:idx];
        [button addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:button];
        [array addObject:button];
    }];
    _actionButtons = array.copy;

}

- (void)setupCutomView
{
    self.contentView.frame = CGRectMake(20, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
    [self.containerView addSubview:self.contentView];
    
    // 按钮
    NSMutableArray<UIButton *> *array = [NSMutableArray array];
    [self.actions enumerateObjectsUsingBlock:^(TAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:obj.title forState:UIControlStateNormal];
        button.frame = [self actionButtonFrameAtIndex:idx];
        button.layer.cornerRadius = 4;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:button];
        [array addObject:button];
    }];
    _actionButtons = array.copy;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateTheme];
}

- (CGSize)preferredContentSize
{
    if (self.preferredStyle == TAlertControllerStyleAlert) {
        CGFloat preferredWidth = self.contentView ? CGRectGetWidth(self.contentView.frame) + 48 : CB_SCREEN_WIDTH * 0.72;
        CGFloat preferredHeight = ({
            CGFloat height = __layout.contentInset.top;
            if (self.title.length) {
                self.sizeLabel.font = __theme.titleTextAttributes[NSFontAttributeName];
                self.sizeLabel.text = self.title;
                [self.sizeLabel sizeToFit];
                CGFloat titleHeight = CGRectGetHeight(self.sizeLabel.frame) + 4;
                height += titleHeight;
            }
            if (self.message.length) {
                CGFloat messageHeight = ({
                    CGFloat height = [self.message boundingRectWithSize:CGSizeMake(preferredWidth-__layout.contentInset.left-__layout.contentInset.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:__theme.messageTextAttributes context:nil].size.height;
                    height = MIN(height, 250);
                    height;
                });
                height += MIN(messageHeight, 250);
            } else if (self.contentView) {
                
                if (self.title.length) {
                    height += CGRectGetHeight(self.contentView.frame) + 16;
                } else {
                    height += CGRectGetHeight(self.contentView.frame);
                }
            }
    //        height += 20;
            if (self.actions.count) {
                NSInteger totalRow = [self totalActionsRow];
                height += (__layout.actionHeight * totalRow + (totalRow-1)*__layout.actionsVerticalSpace + 32);
            }
            
            height += __layout.contentInset.bottom;
            
            height;
        });
        return CGSizeMake(preferredWidth, preferredHeight);
    }
   
    CGFloat preferredWidth = CB_SCREEN_WIDTH;
    CGFloat preferredHeight = (self.actions.count) * __actionSheetLayout.actionHeight + 10 + safeBottomHeight + (self.actions.count-1);
    if (self.headerView) {
        preferredHeight = preferredHeight + self.headerView.height;
    }
    return CGSizeMake(preferredWidth, preferredHeight);
}

- (void)addAction:(TAlertAction *)action
{
    [self.actions addObject:action];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.transitioning;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.transitioning;
}

#pragma mark - Target actions

- (void)actionButtonClicked:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.actionButtons containsObject:sender]) {
        NSInteger buttonIndex = [self.actionButtons indexOfObject:sender];
        TAlertAction *action = self.actions[buttonIndex];
        action.handler(action);
    }
}

#pragma mark - 私有方法

- (CGRect)actionButtonFrameAtIndex:(NSInteger)index
{
    
    CGFloat width = (self.preferredContentSize.width - (self.maxActionCountOfOneLine+1) * 24) / self.maxActionCountOfOneLine;
    CGFloat height = __layout.actionHeight;
    
    NSInteger totalRow = [self totalActionsRow];
    
    CGFloat x = __layout.contentInset.left + (width + __layout.actionsHorizontalSpace) * (index % self.maxActionCountOfOneLine);
    
    CGFloat originY = self.preferredContentSize.height - height * totalRow - (totalRow-1)*__layout.actionsVerticalSpace - __layout.contentInset.bottom;
    
    CGFloat y = originY + index / self.maxActionCountOfOneLine * (height + __layout.actionsVerticalSpace);
    
    return CGRectMake(x, y, width, height);
}

- (NSInteger)totalActionsRow
{
    return (self.actions.count-1) / self.maxActionCountOfOneLine + 1;
}

- (void)updateTheme
{
    TAlertTheme *theme = __theme ?: [[TAlertTheme alloc] init];
    self.titleLabel.font = theme.titleTextAttributes[NSFontAttributeName];
    self.titleLabel.textColor = theme.titleTextAttributes[NSForegroundColorAttributeName];
    
    if (self.preferredStyle == TAlertControllerStyleAlert) {
        self.containerView.backgroundColor = theme.contentBackgroundColor;
    }
    
    [self.actionButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        TAlertAction *action = self.actions[idx];
        [@[@(UIControlStateNormal),@(UIControlStateDisabled)] enumerateObjectsUsingBlock:^(NSNumber *_Nonnull state, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSDictionary<NSString *, id> *titleAttributes = [theme actionTitleAttributesForState:state.integerValue forActionStyle:action.style];
            NSDictionary<NSString *, id> *attributes = [theme actionAttributesForActionStyle:action.style];
            
            [button setTitleColor:titleAttributes[NSForegroundColorAttributeName] forState:state.integerValue];
            button.titleLabel.font = titleAttributes[NSFontAttributeName];
            [button setBackgroundImage:[[UIImage imageWithColor:attributes[TAlertActionBackgroundColorKey]] imageWithCornerRadius:__layout.cornerRadius size:button.viewSize] forState:UIControlStateNormal];
            [button setBackgroundImage:[[UIImage imageWithColor:attributes[TAlertActionHlightBackgroundColorKey]] imageWithCornerRadius:__layout.cornerRadius size:button.viewSize] forState:UIControlStateHighlighted];
        }];
    }];
}

+ (void)registerDefaultTheme:(TAlertTheme *)theme
{
    __theme = theme;
}
 
+ (void)registerDefaultLayout:(TAlertLayout *)layout forStyle:(TAlertControllerStyle)style
{
    if (style == UIAlertControllerStyleAlert) {
        __layout = layout;
    } else {
        __actionSheetLayout = layout;
    }
}

- (UILabel *)sizeLabel
{
    if (!_sizeLabel) {
        _sizeLabel = [UILabel.alloc init];
        _sizeLabel.numberOfLines = 0;
    }
    return _sizeLabel;
}

@end

