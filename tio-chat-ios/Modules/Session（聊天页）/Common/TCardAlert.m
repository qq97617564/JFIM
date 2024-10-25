//
//  TCardAlert.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/4/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCardAlert.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

@interface TCardAlert ()
@property (weak,    nonatomic) UIImageView *imageView;
@property (weak,    nonatomic) UILabel *label;

@property (copy,    nonatomic) NSString *avatar;
@property (copy,    nonatomic) NSString *nick;

@end

@implementation TCardAlert

+ (TCardAlert *)alertWithAvatar:(NSString *)imageUrl nick:(NSString *)nick title:(nonnull NSString *)title
{
    
    return [[self alloc] initWithCustomView:({
        UIView *containerView = [UIView.alloc initWithFrame:CGRectMake(24, 0, 222, 140)];
        
        UILabel *titlelabel = [UILabel.alloc initWithFrame:CGRectMake(0, 32, 1, 1)];
        titlelabel.text = title?:@"邀请";
        titlelabel.textColor = UIColor.blackColor;
        titlelabel.font = [UIFont systemFontOfSize:14];
        [titlelabel sizeToFit];
        [containerView addSubview:titlelabel];
        
        UIView *grayView = [UIView.alloc initWithFrame:CGRectMake(0, 72, containerView.width, 80)];
        grayView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
        [containerView addSubview:grayView];
        
        UIImageView *imageView = [UIImageView.alloc initWithFrame:CGRectMake(12, 0, 50, 50)];
        imageView.layer.cornerRadius = 25;
        imageView.layer.masksToBounds = YES;
        imageView.centerY = grayView.middleY;
        [imageView tio_imageUrl:imageUrl placeHolderImageName:@"avatar_placeholder" radius:0];
        [grayView addSubview:imageView];
        
        UILabel *label = [UILabel.alloc initWithFrame:CGRectMake(78, 0, 132, 22)];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.textColor = UIColor.blackColor;
        label.text = nick;
        label.numberOfLines = 2;
        [label sizeToFit];
        label.left = 78;
        if (label.width > grayView.width - 78 - 12) {
            label.width = grayView.width - 78 - 12;
            label.height = label.height * 2;
        }
        label.centerY = grayView.middleY;
        [grayView addSubview:label];
        
        containerView;
    })];
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(270, 248);
}

@end
