//
//  TCommonCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCommonCell : UITableViewCell
@property (nonatomic, assign) BOOL hasIndiractor;
@property (nonatomic, strong) UIView *detailView;
@end

NS_ASSUME_NONNULL_END
