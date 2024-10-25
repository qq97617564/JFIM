//
//  TSearchTeamCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSearchTeamCell : UITableViewCell

- (void)refreshAvatar:(NSString *)avatar nick:(NSString *)nick remark:(NSString *)remark key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
