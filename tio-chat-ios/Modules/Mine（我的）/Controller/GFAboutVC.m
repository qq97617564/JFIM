//
//  GFAboutVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/27.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFAboutVC.h"
#import "WKWebViewController.h"
#import "TIOChat.h"
#import "TIOMacros.h"
#import "GFNewVersionVC.h"
@interface GFAboutVC ()

@end

@implementation GFAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.version.text =  [NSString stringWithFormat:@"v %@",NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];
    // Do any additional setup after loading the view from its nib.

}
- (IBAction)versionAction:(id)sender {
    //需上线
    GFNewVersionVC *vc = [[GFNewVersionVC alloc]init];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentModalViewController:vc animated:false];
}
- (IBAction)xyAction:(id)sender {
    NSString *url = [TIOChat.shareSDK.config.httpsAddress stringByAppendingString:@"/appinsert/useragreement.html"];
    WKWebViewController *web = [WKWebViewController.alloc init];
    web.urlString = url;
    [self.navigationController pushViewController:web animated:YES];
}
- (IBAction)ysAction:(id)sender {
    NSString *url = [TIOChat.shareSDK.config.httpsAddress stringByAppendingString:@"/appinsert/privacy.html"];
    WKWebViewController *web = [WKWebViewController.alloc init];
    web.urlString = url;
    [self.navigationController pushViewController:web animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
