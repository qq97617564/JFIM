//
//  TCardToSessionCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCardToSessionCell : UITableViewCell

/// 头像
@property (nonatomic, weak, readonly) UIImageView *avaterView;

/// 群名/昵称
@property (nonatomic, weak, readonly) UILabel *nickLabel;

/// 群成员数量
@property (nonatomic, weak, readonly) UILabel *countLabel;

- (void)setAvatarUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
