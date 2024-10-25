//
//  PDCameraScanViewController.h
//  DiErZhouKaoShi
//
//  Created by 裴铎 on 2018/7/16.
//  Copyright © 2018年 裴铎. All rights reserved.
//

#import "TCBaseViewController.h"

@protocol TScanQRCodeViewControllerDelegate <NSObject>
- (void)scanQRCodeViewController:(UIViewController *)viewController stringValue:(NSString *)stringValue;
@end

@interface PDCameraScanViewController : TCBaseViewController
@property (assign,  nonatomic) id<TScanQRCodeViewControllerDelegate> delegate;
/// 默认yes
@property (assign,  nonatomic) BOOL autoIdentify;
@end
