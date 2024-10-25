//
//  TInfoCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TInfoCell : UITableViewCell

@property (nonatomic, assign) BOOL hasIndiractor;

- (void)setAvatar:(NSString *)avatar;

@end

NS_ASSUME_NONNULL_END
