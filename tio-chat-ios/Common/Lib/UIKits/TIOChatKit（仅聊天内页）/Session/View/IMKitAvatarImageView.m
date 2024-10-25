//
//  IMAvatarImageView.m
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import "IMKitAvatarImageView.h"
#import "UIImageView+Web.h"

@interface IMKitAvatarImageView ()

@property (strong, nonatomic) UIImageView *avatarView;

@end

@implementation IMKitAvatarImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.avatarView = [UIImageView.alloc initWithFrame:CGRectZero];
        [self addSubview:self.avatarView];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image
{
    self.avatarView.image = image;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatarView.frame = self.bounds;
}

- (UIImage*)imageAddCorner:(UIImage *)image radius:(CGFloat)radius andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPathRef path = self.path;
    CGContextAddPath(ctx,path);
    CGContextClip(ctx);
    [image drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (CGPathRef)path
{
    return [[UIBezierPath bezierPathWithRoundedRect:self.bounds
                                       cornerRadius:self.cornerRadius] CGPath];
}

- (void)im_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder
{
    if (!url) {
        return;
    }
    
    [_avatarView tio_imageUrl:url placeHolderImageName:@"avatar_placeholder" radius:6];
    
//    __weak typeof(self) weakSelf = self;
//    UIImage *fixedPlaceholderImage  = [self imageAddCorner:placeholder
//                                                    radius:_cornerRadius
//                                                   andSize:self.bounds.size];
//    [_avatarView sd_setImageWithURL:url
//                  placeholderImage:fixedPlaceholderImage
//                           options:SDWebImageAvoidAutoSetImage|SDWebImageDelayPlaceholder
//                         completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                             if (image) {
//                                 weakSelf.image = image;
//                             }
//
//    }];
}

@end
