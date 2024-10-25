//
//  TPhotoPicker.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HXPhotoModel;
@class TIOSession;

@interface TPhotoPicker : NSObject

- (instancetype)initWithSession:(TIOSession *)session controller:(UIViewController *)vc;

@property (strong, nonatomic) TIOSession *session;
@property (weak,   nonatomic) UIViewController *controller;

- (void)fetchPhotosAndVideosWithView:(UIView *)view;

- (void)fetchCameraWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
