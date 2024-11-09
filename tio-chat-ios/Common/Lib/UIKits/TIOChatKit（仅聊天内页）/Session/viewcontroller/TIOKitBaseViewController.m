//
//  IMBaseSessionViewController.m
//  CawBar
//
//  Created by admin on 2019/11/25.
//

#import "TIOKitBaseViewController.h"
#import "TIOKitNavigationBar.h"
#import "TIOGlobalMacro.h"
#import "FrameAccessor.h"
#import "UIButton+Enlarge.h"

void *IMKitKVOContext;

@interface TIOKitBaseViewController ()
@property(nonatomic, assign) BOOL  isCanUseSideBack;// 手势是否启动
@end

@implementation TIOKitBaseViewController

#pragma mark - 生命周期方法

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.navigationBar];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.automaticallyAdjustsScrollViewInsets = NO;
    #pragma clang diagnostic push
}
-(void)setTitle:(NSString *)title{
    [super setTitle:@""];
    self.navigationBar.titleL.text = title;
//    self.navigationController.title = title;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
//    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self startSideBack];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (self.navigationController.viewControllers.firstObject == self) {
        [self cancelSideBack];
    } else {
        [self startSideBack];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    self.view.frame = CGRectMake(0, 0, CB_SCREEN_WIDTH, CB_SCREEN_HEIGHT);
    if ([self.parentViewController isKindOfClass:UINavigationController.class]) {
        self.navigationBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), IM_Height_NavBar);
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    self.view.frame = CGRectMake(0, 0, CB_SCREEN_WIDTH, CB_SCREEN_HEIGHT);
    if ([self.parentViewController isKindOfClass:UINavigationController.class]) {
        self.navigationBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), IM_Height_NavBar);
    }
    [self.navigationBar setNeedsDisplay];
    [self.navigationBar setNeedsLayout];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    if (![parent isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationBar.items = @[self.navigationItem];
    if (self.navigationController.viewControllers.firstObject != self) {
        self.hidesBottomBarWhenPushed = YES;
        if (self.navigationItem.leftBarButtonItems.count == 0) {
            UIImage *backImage = [[UIImage imageNamed:@"Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:backImage
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(goBack)];
            self.navigationItem.leftBarButtonItems = @[back];
            
            if (self.leftBarButtonText) {
                UIBarButtonItem *barButtonItem = [UIBarButtonItem.alloc initWithCustomView:({
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.titleLabel.font = [UIFont systemFontOfSize:18];
                    [button setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
                    [button setTitle:self.leftBarButtonText forState:UIControlStateNormal];
                    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
                    [button verticalLayoutWithInsetsStyle:ButtonStyleLeft Spacing:-40];
                    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
                    
                    button;
                })];
                
                self.navigationItem.leftBarButtonItem = barButtonItem;
            }
            self.navigationItem.leftItemsSupplementBackButton = YES;
        }
    }
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == IMKitKVOContext) {
        if (!CGRectEqualToRect([change[NSKeyValueChangeOldKey] CGRectValue], [change[NSKeyValueChangeNewKey] CGRectValue])) {
            [self adjustScrollViewInsets];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    NSLog(@"-[%@ %s]", self.class, sel_getName(_cmd));
    [self.navigationBar removeObserver:self forKeyPath:@"frame"];
}

- (TIOKitNavigationBar *)navigationBar
{
    if (!_navigationBar) {
        TIOKitNavigationBar *navBar = [[TIOKitNavigationBar alloc] initWithFrame:CGRectZero];
        navBar.titleL.text = self.title;
        navBar.tintColor = UIColor.whiteColor;
        navBar.barTintColor = UIColor.whiteColor;
        navBar.backgroundColor = UIColor.whiteColor;
        navBar.titleTextAttributes = @{NSForegroundColorAttributeName:  [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0], NSFontAttributeName: [UIFont systemFontOfSize:18]};
        navBar.translucent = NO; // 关闭默认透明度效果
        [navBar setShadowImage:[UIImage new]];
        navBar.layer.shadowColor = IMKit_ColorRGBA(0, 0, 0, 0.03).CGColor;
        navBar.layer.shadowOffset = CGSizeMake(0, 1);
        navBar.layer.shadowOpacity = 1;
        navBar.layer.shadowRadius = 2;
        [navBar addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:IMKitKVOContext];
        _navigationBar = navBar;
    }
    return _navigationBar;
}

#pragma mark - 私有方法

- (void)adjustScrollViewInsets
{
    __block UIScrollView *scrollView = nil;
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UIScrollView.class]) {
            scrollView = (UIScrollView *)obj;
            if (CGRectIntersectsRect(obj.frame, self.navigationBar.frame)) {
                scrollView.contentInsetTop = (!self.automaticallyAdjustsScrollViewInsets || self.navigationBar.hidden) ? 0 : CGRectIntersection(scrollView.frame, self.navigationBar.frame).size.height;
                scrollView.contentOffsetY = -scrollView.contentInsetTop;
                scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollView.contentInsetTop, scrollView.scrollIndicatorInsets.left, scrollView.scrollIndicatorInsets.bottom, scrollView.scrollIndicatorInsets.right);
            }
            if ([self.tabBarController.viewControllers containsObject:self.navigationController] && self.navigationController.viewControllers.firstObject == self && CGRectIntersectsRect(obj.frame, self.tabBarController.tabBar.frame)) {
                CGFloat bottomInset = (!self.automaticallyAdjustsScrollViewInsets ? 0 : CGRectIntersection(scrollView.frame, self.tabBarController.tabBar.frame).size.height);
                scrollView.contentInsetBottom = bottomInset;
                scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollView.scrollIndicatorInsets.top, scrollView.scrollIndicatorInsets.left, bottomInset, scrollView.scrollIndicatorInsets.right);
            }
        }
    }];
}

- (void)beginRefreshing:(id)sender {}
- (void)beginLoadingMore:(id)sender {}


/**

* 关闭ios右滑返回

*/

- (void)cancelSideBack{
    self.isCanUseSideBack = NO;

    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

/*

开启ios右滑返回

*/

- (void)startSideBack
{
    self.isCanUseSideBack = YES;
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
    if (self.navigationController) {
        if (self.navigationController.viewControllers.firstObject == self) {
            return NO;
        }
    }
    return self.isCanUseSideBack;
}

@end
