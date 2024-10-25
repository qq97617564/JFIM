//
//  IMAvatarImageView.h
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMKitAvatarImageView : UIControl

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGFloat cornerRadius;

- (void)im_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder;

@end

NS_ASSUME_NONNULL_END
