//
//  WKWebViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/9/22.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIOKitBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewController : TIOKitBaseViewController

@property (copy,    nonatomic) NSString *urlString;
/// 是否开启自动适配补全url
/// 默认开启
@property (assign,  nonatomic) BOOL autoUrl;

@end

NS_ASSUME_NONNULL_END
