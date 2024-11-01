//
//  TSearchFriendCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSearchFriendCell : UITableViewCell

- (void)refreshAvatar:(NSString *)avatar nick:(NSString *)nick remark:(NSString *)remark key:(NSString *)key;
@property(nonatomic, strong)UIImageView *flag;
@end

NS_ASSUME_NONNULL_END
