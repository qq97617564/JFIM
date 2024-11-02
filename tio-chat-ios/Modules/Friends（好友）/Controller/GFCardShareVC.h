//
//  GFCardShareVC.h
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/31.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GFCardShareVC : TCBaseViewController
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *cardView;

@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *flag;
@property (weak, nonatomic) IBOutlet UILabel *cardType;
@property (weak, nonatomic) IBOutlet UILabel *cardNameL;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (nonatomic, copy) void (^sendCallback)(void);
-(void)setAvatar:(NSString *)imageUrl nick:(NSString *)nick title:(nonnull NSString *)title toSelected:(BOOL)toSelected;
@end

NS_ASSUME_NONNULL_END
