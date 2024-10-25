//
//  TAddPopupView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/15.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TAddPopupView.h"

@interface TAddPopupCell : UITableViewCell
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation TAddPopupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [UIView.alloc init];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
        
        self.icon = [UIImageView.alloc init];
        self.icon.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.icon];
        
        self.titleLabel = [UILabel.alloc init];
        self.titleLabel.textColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:62/255.0 alpha:1.0];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.selectedBackgroundView.frame = self.bounds;
    
    self.icon.frame = CGRectMake(7, (CGRectGetHeight(self.contentView.frame) - 24)*0.5, 24, 24);
    
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.icon.frame) + 4, 0, CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(self.icon.frame) - 14, CGRectGetHeight(self.contentView.frame));
}

@end




@interface TAddPopupView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *indirector; // 三角形指示
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGPoint indirectorOrigin;
@property (nonatomic, copy) TAddPopupViewHandler handler;
@property (nonatomic, strong) NSArray *itemTitles;
@property (nonatomic, strong) NSArray *itemImages;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, assign) CGSize measureMaxSize;
@property (nonatomic, assign) CGFloat minLeftMargin;
@property (nonatomic, assign) CGFloat minRightMargin;
@property (nonatomic, assign) CGFloat minTopMargin;
@property (nonatomic, assign) CGFloat minBottomMargin;
@property (nonatomic, assign) CGFloat minMarginIndirectorToBorder; // Indirector到边框的最小值
@end

@implementation TAddPopupView

+ (instancetype)menuWithItemTitles:(NSArray *)itemTitles itemImages:(NSArray *)itemImages itemHandler:(TAddPopupViewHandler)hander
{
    TAddPopupView *view = [TAddPopupView.alloc init];
    view.itemTitles = itemTitles;
    view.itemImages = itemImages;
    view.handler = hander;
    [view setupUI];
    
    return view;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.rowHeight = 46;
        self.headerHeight = 0;
        self.footerHeight = 0;
        self.cornerRadius = 4;
        self.minLeftMargin = 16;
        self.minRightMargin = 16;
        self.minTopMargin = 88;
        self.minMarginIndirectorToBorder = 5;
        self.minBottomMargin = safeBottomHeight;
        self.backgroundColor = UIColor.clearColor;
    }
    
    return self;
}

- (void)setupUI
{
    self.indirector = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"popupIndiractor"]];
    self.indirector.bounds = CGRectMake(0, 0, 15, 11);
    [self addSubview:self.indirector];
    
    self.tableView = [UITableView.alloc initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.rowHeight = self.rowHeight;
    self.tableView.sectionHeaderHeight = self.headerHeight;
    self.tableView.sectionFooterHeight = self.footerHeight;
    self.tableView.scrollEnabled = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.layer.cornerRadius = 4;
    self.tableView.layer.masksToBounds = YES;
    [self.tableView registerClass:[TAddPopupCell class] forCellReuseIdentifier:NSStringFromClass(TAddPopupCell.class)];
    [self addSubview:self.tableView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.origin.y = 11;
    frame.size.height -= frame.origin.y;
    self.tableView.frame = frame;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TAddPopupCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TAddPopupCell.class) forIndexPath:indexPath];
    cell.icon.image = [UIImage imageNamed:self.itemImages[indexPath.row]];
    cell.titleLabel.text = self.itemTitles[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemTitles.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return self.footerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc init];
    view.backgroundColor = UIColor.whiteColor;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView.alloc init];
    view.backgroundColor = UIColor.whiteColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.handler(self, indexPath.row, self.itemTitles[indexPath.row]);
    
    [self hide];
}

- (void)show
{
    // 半透明蒙版层动画
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 0.2;
    } completion:^(BOOL finished) {
        
    }];
    
    // 计算内容自适应后应该有的尺寸
    self.bounds = CGRectMake(0, 0, self.measureMaxSize.width, self.measureMaxSize.height);
    
    // 计算弹出后的frame
    
    CGRect frame = self.frame;
    frame.origin = CGPointMake(self.anchorPoint.x - self.bounds.size.width, self.anchorPoint.y);
    
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    
    // 处理水平方向坐标 假设indirector居中
    if (self.anchorPoint.x + self.bounds.size.width*0.5 > screenSize.width) {
        //  popup超出屏幕右边
        //  处理：使弹窗最右边与屏幕右侧保持最小边距
        frame.origin.x = (self.anchorPoint.x + 7.5 + self.minMarginIndirectorToBorder) - frame.size.width;
        // 计算indirector的frame
        CGRect indirectorFrame = self.indirector.frame;
        indirectorFrame.origin.y = 0;
        indirectorFrame.origin.x = frame.size.width - indirectorFrame.size.width - self.minMarginIndirectorToBorder;
        self.indirector.frame = indirectorFrame;
    } else if (self.anchorPoint.x - self.bounds.size.width*0.5 < 0) {
        // popup超出屏幕左边
        // 处理：使弹窗最左边与屏幕左侧保持最小边距
        frame.origin.x = 7.5 + self.minMarginIndirectorToBorder;
        // 计算indirector的frame
        CGRect indirectorFrame = self.indirector.frame;
        indirectorFrame.origin = CGPointMake(7.5+self.minMarginIndirectorToBorder, 0);
        self.indirector.frame = indirectorFrame;
    } else {
        // 正常居中
        frame.origin.x = self.anchorPoint.x - frame.size.width*0.5;
        // 计算indirector的frame
        CGRect indirectorFrame = self.indirector.frame;
        indirectorFrame.origin.x = frame.size.width*0.5 - 7.5;
        indirectorFrame.origin.y = 0;
        self.indirector.frame = indirectorFrame;
    }
    
    // 处理竖直方向坐标 假设向下弹出
//    if (self.anchorPoint.y + self.bounds.size.height > screenSize.height) {
//        // popup超出屏幕底边
//        // 应该向上弹
//    } else {
//        // 正常向下弹
//    }
    
    
    // 更改锚点
    self.layer.anchorPoint = CGPointMake(0.95, 0);
    // 设置frame
    self.frame = frame;
    // 先缩小
    self.transform = CGAffineTransformMakeScale(0.001, 0.001);
    // 添加到父视图
    [[self fatherView] addSubview:self];
    // 开始放大动画
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // 放大回原frame
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
//    [UIView animateWithDuration:0.2 animations:^{
//        // 放大回原frame
//        self.transform = CGAffineTransformIdentity;
//    } completion:^(BOOL finished) {
//
//    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(0.3, 0.3);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
}

- (UIView *)maskView
{
    if (!_maskView) {
        
        UIView *window = [self fatherView];
        
        _maskView = [UIView.alloc initWithFrame:window.bounds];
        _maskView.backgroundColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:62/255.0 alpha:1.0];
        _maskView.alpha = 0;
        
        [_maskView addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(tap:)]];
        
        [window addSubview:_maskView];
    }
    return _maskView;
}

- (UIView *)fatherView
{
    UIWindow *window = nil;
//    if (@available(iOS 13.0, *)) {
//        for (UIWindowScene * sence in UIApplication.sharedApplication.connectedScenes) {
//            if (sence.activationState == UISceneActivationStateForegroundActive)
//            {
//                window = sence.windows[1];
//                break;
//            }
//        }
//    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        window = UIApplication.sharedApplication.keyWindow;
        #pragma clang diagnostic push
//    }
    
    return window;
}

- (CGSize)measureMaxSize
{
    CGFloat maxTitleWidth = 0;
    
    for (NSString *title in self.itemTitles) {
        CGFloat titleWidth = [title boundingRectWithSize:CGSizeMake(100, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:16] } context:nil].size.width;
        
        if (titleWidth > maxTitleWidth) {
            maxTitleWidth = titleWidth;
        }
    }
    
    return CGSizeMake(7 + self.rowHeight - 9*2 + 4 + maxTitleWidth + 10,
                      self.rowHeight * self.itemTitles.count + self.headerHeight + self.footerHeight + 11);
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    self.handler(self, -1, @"");
    [self hide];
}

@end
