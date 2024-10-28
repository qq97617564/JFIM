//
//  GFWalletOrderListCell.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFWalletOrderListCell.h"
@interface GFWalletOrderListCell()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *typeL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *statusL;
@property (weak, nonatomic) IBOutlet UILabel *moneyL;

@end
@implementation GFWalletOrderListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setType:(NSInteger)type money:(NSString *)money time:(NSString *)time status:(NSInteger)status{
    if (type == 1) {
        self.icon.image = [UIImage imageNamed:@"Group 1321315553"];
        self.typeL.text = @"账户充值";
        self.moneyL.text = [NSString stringWithFormat:@"+%@",money];
    }else if(type == 2){
        self.icon.image = [UIImage imageNamed:@"Group 1321315554"];
        self.typeL.text = @"账户提现";
        self.moneyL.text = [NSString stringWithFormat:@"-%@",money];
    }else{
        self.icon.image = [UIImage imageNamed:@"Group 1321315554"];
        self.typeL.text = @"";
        self.moneyL.text = [NSString stringWithFormat:@"%@",money];
    }
    self.timeL.text = time;
    switch (status) {
        case 0:
            self.statusL.text = @"待审核";
            break;
        case 1:
            self.statusL.text = @"已完成";
            break;
        case 2:
            self.statusL.text = @"未通过";
            break;
        default:
            self.statusL.text = @"";
            break;
    }
}
@end
