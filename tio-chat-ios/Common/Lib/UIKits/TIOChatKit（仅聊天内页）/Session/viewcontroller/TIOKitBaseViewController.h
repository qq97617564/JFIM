//
//  IMBaseSessionViewController.h
//  CawBar
//
//  Created by admin on 2019/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 会话页基类
/// 替换系统导航条，每个页面拥有独立导航条，可跟随页面拖动
/// 导航条属于UINavigationBar子类，添加UIButtonItem等操作与系统一致
@interface TIOKitBaseViewController : UIViewController<UIGestureRecognizerDelegate>

/**
 导航条
 */
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (copy, nonatomic) NSString *leftBarButtonText;

/**
 生命周期方法，覆盖需加super
 */
- (void)viewDidLoad NS_REQUIRES_SUPER;
- (void)viewWillAppear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewWillDisappear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewDidAppear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewDidDisappear:(BOOL)animated NS_REQUIRES_SUPER;
- (void)viewWillLayoutSubviews NS_REQUIRES_SUPER;
- (void)viewDidLayoutSubviews NS_REQUIRES_SUPER;
- (void)willMoveToParentViewController:(nullable UIViewController *)parent NS_REQUIRES_SUPER;
- (void)didMoveToParentViewController:(nullable UIViewController *)parent NS_REQUIRES_SUPER;

/// navigationController返回，可重写
- (void)goBack;

/**
 触发刷新的方法
 
 @param sender 进行刷新的header
 */
- (void)beginRefreshing:(nullable id)sender;

/**
 触发加载更多的方法
 
 @param sender 进行刷加载的footer
 */
- (void)beginLoadingMore:(nullable id)sender;

- (void)startSideBack;
- (void)cancelSideBack;

@end

NS_ASSUME_NONNULL_END
