//
//  CBVersionManager.m
//  CawBar
//
//  Created by admin on 2018/12/22.
//

#import "CBVersionManager.h"
#import "APPHTTPManager.h"
#import <UIKit/UIKit.h>

@interface CBVersionManager ()

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (assign, nonatomic) CBUpdateType type;
@property (assign, nonatomic) BOOL allowAlert;

@property (weak, nonatomic) UIAlertController *alert;

@end

@implementation CBVersionManager

+ (instancetype)shareInstance
{
    static CBVersionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (void)dealloc
{
    [self stopManager];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allowAlert = YES;
    }
    return self;
}

- (void)starManager
{
    [self observerUpdateAlert:nil];
//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(observerUpdateAlert:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)stopManager
{
    self.allowAlert = NO;
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)observerUpdateAlert:(NSNotification *)notification
{
    // 向服务端获取更新状态,标题,文案...
    CBWeakSelf
    [APPHTTPManager t_POST:@"/sys/version" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        CBStrongSelfElseReturn
        // 1:要更新 2:不要更新
        NSInteger updateflag = [responseObject[@"data"][@"updateflag"] integerValue];
        // 1:强制更新 2:不强制更新
        NSInteger forceflag = [responseObject[@"data"][@"forceflag"] integerValue];
        
        NSString *content = responseObject[@"data"][@"content"];
        
        CBUpdateType type = CBUpdateTypeNone;
        if (updateflag == 1) {
            if (forceflag == 1) {
                type = CBUpdateTypeForced;
            } else if (forceflag == 2) {
                type = CBUpdateTypeOptional;
            } else {
                type = CBUpdateTypeOptional;
            }
        } else if (updateflag == 2) {
            type = CBUpdateTypeNone;
        } else {
            type = CBUpdateTypeNone;
        }
        // 显示
        [self showMessageWithTitle:@"" content:content type:type];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CBStrongSelfElseReturn
        self.allowAlert = YES;
    } retryCount:1];
}

- (void)showMessageWithTitle:(NSString *)title content:(NSString *)content type:(CBUpdateType)type
{
    self.title = @"有新版本发布";
    self.content = content?:@"";
    self.type = type;
    
    switch (self.type) {
        case CBUpdateTypeNone:
        {
            [self stopManager];
        }
            break;
        case CBUpdateTypeOptional:
        {
            // 生命周期内，用户若关闭可升级弹窗，不会再一次提醒
            if (!self.allowAlert) {
                return;
            }
            
            // 建议更新
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title message:self.content preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:({
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"暂不更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self stopManager];
                }];
                action;
            })];
            [alert addAction:({
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"立即前往AppStore更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 跳转至AppStore
                    [self stopManager];
                    
                    NSString *urlStr = @"https://apps.apple.com/cn/app/%E8%B0%AD%E8%81%8A/id1535131768";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                }];
                action;
            })];
            [alert addAction:({
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self stopManager];
                }];
                action;
            })];
            
            [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            
            // 存储当前的alert 防止重复弹出
            self.alert = alert;
        }
            break;
        case CBUpdateTypeForced:
        {
            // 若更新弹窗已存在，不弹出
            if (self.alert) {
                return;
            }
            
            // 强梗
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title message:self.content preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:({
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"立即前往AppStore更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 跳转至AppStore
                    NSString *urlStr = @"https://apps.apple.com/cn/app/%E8%B0%AD%E8%81%8A/id1535131768";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                }];
                action;
            })];
            [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            
            // 存储当前的alert 防止重复弹出
            self.alert = alert;
        }
            break;
        default:
            break;
    }
}

@end
