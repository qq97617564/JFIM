//
//  TReviewInvitedUserHeader.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/2/8.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TReviewInvitationHeader : UICollectionReusableView

@property (weak,    nonatomic) UIImageView *imageView;
@property (weak,    nonatomic) UILabel *nickLabel;
@property (weak,    nonatomic) UILabel *countLabel;
@property (weak,    nonatomic) UILabel *applyMsgLabel;

@end

NS_ASSUME_NONNULL_END
