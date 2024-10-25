//
//  IMKitMoreContainer.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/22.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMoreContainer.h"
#import "UIImage+TColor.h"
#import "TIOKitDependency.h"


@interface IMKitMoreCell : UIView
@property (strong, nonatomic) UIButton  *button;
@property (strong, nonatomic) UILabel   *titleLabel;
@property (strong, nonatomic) UIImage   *normalImage;
@property (strong, nonatomic) UIImage   *selectedImage;
@property (copy  , nonatomic) void(^onTapCallback)(void);
@end

@implementation IMKitMoreCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(0, 0, self.width, self.width);
        [self.button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]] imageWithCornerRadius:8 size:self.button.viewSize] forState:UIControlStateNormal];
        [self.button setBackgroundImage:[[UIImage imageWithColor:[UIColor colorWithRed:62/255.0 green:73/255.0 blue:88/255.0 alpha:0.2f]] imageWithCornerRadius:8 size:self.button.viewSize] forState:UIControlStateHighlighted];
        self.button.showsTouchWhenHighlighted = YES;
        [self.button addTarget:self action:@selector(onTapButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(0, self.width, self.width, self.height - self.width)];
        label.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        self.titleLabel = label;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX = self.middleX;
    self.titleLabel.bottom = self.height;
}

- (void)onTapButton:(UIButton *)button
{
    if (self.onTapCallback) {
        self.onTapCallback();
    }
}

- (void)setNormalImage:(UIImage *)normalImage
{
    [self.button setImage:normalImage forState:UIControlStateNormal];
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    [self.button setImage:selectedImage forState:UIControlStateSelected];
}

@end



@interface IMKitMoreContainer ()

@property (strong, nonatomic) UIPageControl *pageControll;
@property (assign, nonatomic) id<IMKitInputViewConfig> config;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray<IMKitInputMoreItem *> *dataArray;

@property (strong, nonatomic) NSMutableArray<UIView *> *pageViews;
@property (assign, nonatomic) UIEdgeInsets contentInsets;
@property (assign, nonatomic) NSInteger minLineSpacing; // 最小行间距
@property (assign, nonatomic) NSInteger minColumnSpacing; //最小 列间距
@property (assign, nonatomic) CGSize    itemSize;   // 每个item大小

@end

@implementation IMKitMoreContainer

- (instancetype)initWithFrame:(CGRect)frame config:(nonnull id<IMKitInputViewConfig>)config
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _config = config;
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.minLineSpacing = 20;
    self.minColumnSpacing = 20;
    self.itemSize = [_config respondsToSelector:@selector(moreItemSize)]?[_config moreItemSize]:CGSizeMake(56, 80);
    self.contentInsets = [_config respondsToSelector:@selector(moreContainerContentInsets)]?[_config moreContainerContentInsets]:UIEdgeInsetsMake(15, 40, 15, 40);
    
    self.backgroundColor = UIColor.whiteColor;
    self.scrollView = [UIScrollView.alloc initWithFrame:self.bounds];
    self.scrollView.pagingEnabled = YES;
    [self addSubview:self.scrollView];
    [self setupView:[self numberOfPages]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(size.width, 220);
}

- (NSArray<IMKitInputMoreItem *> *)dataArray
{
    return [self.config moreItems];
}

#pragma mark - 以下为分页计算

/// 创建
- (void)setupView:(NSInteger)pages
{
    for (int i = 0; i < pages; i++) {
        UIView *view = [UIView.alloc initWithFrame:CGRectMake(i*self.scrollView.width, 0, self.scrollView.width, self.scrollView.height)];
        [self setupPageView:view index:i];
        [self.scrollView addSubview:view];
        [self.pageViews addObject:view];
        self.scrollView.contentSizeWidth = view.width * (i+1);
    }
}

/// 分页数量
- (NSInteger)numberOfPages
{
    NSInteger preItemsNumber = [self columnNumber] * [self lineNumber];
    
    return self.dataArray.count / preItemsNumber + 1;
}

/// 每一页的列数 （每一行的数量）
- (NSInteger)columnNumber
{
    CGFloat floatNumber = (self.scrollView.width - self.contentInsets.left - self.contentInsets.right) / (self.itemSize.width + self.minColumnSpacing);
    
    NSInteger number = floorf(floatNumber);
    CGFloat dotVlaue = floatNumber - number;
    
    if (dotVlaue * (self.itemSize.width + self.minColumnSpacing) >= self.itemSize.width) {
        return number + 1;
    }
    
    return number;
}

/// 每一页的行数 （每一列的数量）
- (NSInteger)lineNumber
{
    CGFloat floatNumber = (self.scrollView.height - self.contentInsets.top - self.contentInsets.bottom) / (self.itemSize.height + self.minLineSpacing);
    NSInteger number = floorf(floatNumber);
    CGFloat dotVlaue = floatNumber - number;
    
    if (dotVlaue * (self.itemSize.height + self.minLineSpacing) >= self.itemSize.height) {
        return number + 1;
    }
    
    return number;
}

/// 为第index个子分页创建UI
- (void)setupPageView:(UIView *)view index:(NSInteger)index
{
    NSArray<IMKitInputMoreItem *> *datas = [self datasOfViewAtIndex:index];
    
    NSInteger lineNumber = [self lineNumber];
    
    CGFloat lineSpacing = 0;
    
    if (lineNumber == 1) {
        lineSpacing = view.height - self.contentInsets.top - self.contentInsets.bottom - self.itemSize.height * lineNumber;
    } else {
        lineSpacing = (view.height - self.contentInsets.top - self.contentInsets.bottom - self.itemSize.height * lineNumber) / (lineNumber - 1);
    }
    
    NSInteger columnNumber = [self columnNumber];
    
    CGFloat columnSpacing = (view.width - self.contentInsets.left - self.contentInsets.right - self.itemSize.width * columnNumber) / (columnNumber - 1);
    
    for (int i = 0; i < datas.count; i++) {
        IMKitMoreCell *cell = [IMKitMoreCell.alloc initWithFrame:CGRectMake(self.contentInsets.left + (i % columnNumber) * (columnSpacing + self.itemSize.width),
                                                                            self.contentInsets.top + (i / columnNumber) * (self.itemSize.height + lineSpacing),
                                                                            self.itemSize.width,
                                                                            self.itemSize.height)];
        cell.normalImage = datas[i].normalImage;
        cell.selectedImage = datas[i].selectedImage;
        cell.titleLabel.text = datas[i].title;
        CBWeakSelf
        cell.onTapCallback = ^{
            CBStrongSelfElseReturn;
            IMKitInputMoreItem *itemData = datas[i];
            if ([self.delegate respondsToSelector:@selector(onTapMoreItem:)]) {
                [self.delegate onTapMoreItem:itemData];
            }
        };
        
        [view addSubview:cell];
    }
}

/// 第index页的数据
- (NSArray *)datasOfViewAtIndex:(NSInteger)index
{
    NSInteger length = [self columnNumber] * [self lineNumber];
    
    if (index < [self numberOfPages] - 1) {
        
        return [self.dataArray subarrayWithRange:NSMakeRange(index * length, length)];
    }
    
    return [self.dataArray subarrayWithRange:NSMakeRange(index * length, self.dataArray.count - index*length)];
}


@end
