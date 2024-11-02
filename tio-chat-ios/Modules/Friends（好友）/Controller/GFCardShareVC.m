//
//  GFCardShareVC.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/31.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFCardShareVC.h"
#import "UIImageView+Web.h"

@interface GFCardShareVC ()

@end

@implementation GFCardShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backView.layer.cornerRadius = 8;
    self.avatar.layer.cornerRadius = 6;
    self.cardView.layer.cornerRadius = 2;
    self.cancelBtn.layer.cornerRadius = 6;
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4000];
}
-(void)setAvatar:(NSString *)imageUrl nick:(NSString *)nick title:(nonnull NSString *)title toSelected:(BOOL)toSelected{
//    NSString *titleStr = toSelected ? @"发送给:" : @"好友推荐";
    self.titleL.text = title;
    [self.avatar tio_imageUrl:imageUrl placeHolderImageName:@"avatar_placeholder" radius:0];
    self.nameL.text = nick;
    self.cardType.text = @"[个人名片]";
    self.cardNameL.text = nick;
}

- (IBAction)cancelAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:false completion:nil];
}

- (IBAction)sendAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:false completion:nil];
    if (self.sendCallback) {
        self.sendCallback();
    }
    
}


@end
