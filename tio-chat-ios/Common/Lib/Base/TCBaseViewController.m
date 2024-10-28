//
//  TCBaseViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/31.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

@interface TCBaseViewController ()

@end

@implementation TCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHex:0xF8F9FB];
    self.navigationBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.navigationBar.layer.shadowOpacity = 0;
    self.navigationBar.layer.shadowRadius = 0;
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
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self.navigationController
                                                                                    action:@selector(popViewControllerAnimated:)];
            
        }
    }
}

@end
