//
//  GFAddressListCell.h
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/27.
//  Copyright © 2024 wgf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GFAddressListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UIView *redDot;
@property (weak, nonatomic) IBOutlet UILabel *numL;
@property(nonatomic, assign)NSInteger num;
@end

NS_ASSUME_NONNULL_END
