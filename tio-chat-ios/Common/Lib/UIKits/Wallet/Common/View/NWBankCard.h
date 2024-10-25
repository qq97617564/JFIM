//
//  NWBankCard.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/3.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWBankCard : UICollectionViewCell

@property (weak,    nonatomic) UIImageView *bg;
@property (weak,    nonatomic) UIImageView *icon;
@property (weak,    nonatomic) UIImageView *watermark;
@property (weak,    nonatomic) UILabel *nameLabel;
@property (weak,    nonatomic) UILabel *cardNoLabel;

@end

NS_ASSUME_NONNULL_END
