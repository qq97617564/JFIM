//
//  GFWalletOrderListCell.h
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GFWalletOrderListCell : UITableViewCell
-(void)setType:(NSInteger)type money:(NSString *)money time:(NSString *)time status:(NSInteger)status;
@end

NS_ASSUME_NONNULL_END
