//
//  GFAddressListCell.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/27.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFAddressListCell.h"

@implementation GFAddressListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.redDot.layer.cornerRadius = 8.5;
    // Initialization code
//    self.icon.layer.cornerRadius
}
-(void)setNum:(NSInteger)num{
    _num = num;
    if (num>0) {
        self.redDot.hidden = false;
        self.numL.text = [NSString stringWithFormat:@"%ld",num];
        if (num>99) {
            self.numL.text = @"99+";
        }
        
    }else{
        self.redDot.hidden = true;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
