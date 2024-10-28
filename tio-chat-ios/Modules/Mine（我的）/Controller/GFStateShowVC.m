//
//  GFStateShowVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFStateShowVC.h"

@interface GFStateShowVC ()
{
    CGFloat kWidth;
    CGFloat kHeight;
    NSArray *titles;
    NSArray *icons;

}
@property(nonatomic, strong)UIImageView *statusIcon;
@property(nonatomic, strong)UILabel *statusL;
@property(nonatomic, strong)UIButton *backButton;
@end

@implementation GFStateShowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    kWidth = ScreenWidth();
    kHeight = ScreenHeight();
    titles = @[@"待审核",@"已通过",@"未通过"];
    icons = @[@"mine_result",@"mine_result",@"logoff"];
    [self.view addSubview:self.statusIcon];
    [self.view addSubview:self.statusL];
    [self.view addSubview:self.backButton];
    self.backButton.layer.cornerRadius = 6;
    self.backButton.layer.masksToBounds = true;
    
}
-(void)updateUI{
    self.statusL.text = titles[self.status];
    self.title = titles[self.status];
    self.statusIcon.image = icons[self.status];
}
-(UIImageView *)statusIcon{
    if (!_statusIcon) {
        _statusIcon = [[UIImageView alloc]initWithFrame:CGRectMake((kWidth-70)/2, Height_NavBar+60, 70, 70)];
    }
    return _statusIcon;
}
-(UILabel *)statusL{
    if (!_statusL) {
        _statusL = [UILabel.alloc initWithFrame:CGRectMake(0, Height_NavBar+139,kWidth, 25)];
        _statusL.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        _statusL.textAlignment = NSTextAlignmentCenter;
    }
    return _statusL;
}
-(UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        _backButton.backgroundColor = [UIColor colorWithHex:0x0087FC];
        [_backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
-(void)backClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:true];
}
@end
