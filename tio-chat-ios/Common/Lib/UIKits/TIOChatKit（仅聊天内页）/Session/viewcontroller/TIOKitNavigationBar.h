//
//  IMKitNavigationBar.h
//  CawBar
//
//  Created by admin on 2019/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOKitNavigationBar : UINavigationBar

@property (weak, nonatomic, readonly) UILabel *titleLabel;
@property (weak, nonatomic, readonly) UILabel *subTitleLabel;

@end

NS_ASSUME_NONNULL_END
