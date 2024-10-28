//
//  GFLogOffVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/27.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFLogOffVC.h"

@interface GFLogOffVC ()
@property (weak, nonatomic) IBOutlet UIButton *logoffBtn;

@end

@implementation GFLogOffVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注销账号";
    self.logoffBtn.layer.cornerRadius = 6;
}
- (IBAction)logOffAction:(UIButton *)sender {
    
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
