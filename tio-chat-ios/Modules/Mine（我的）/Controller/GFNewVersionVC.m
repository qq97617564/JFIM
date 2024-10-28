//
//  GFNewVersionVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/27.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFNewVersionVC.h"

@interface GFNewVersionVC ()
@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet UITextView *textV;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;

@end

@implementation GFNewVersionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.updateBtn.layer.cornerRadius = 6;
//    self.view.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)updateAction:(UIButton *)sender {
    
}
- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:false completion:nil];
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
