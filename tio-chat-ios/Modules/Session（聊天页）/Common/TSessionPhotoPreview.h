//
//  TSessionPhotoManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPhotoPreviewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOSession;

@interface TSessionPhotoPreview : NSObject

- (instancetype)initWithSession:(TIOSession *)session onVC:(UIViewController *)onVC;

@property (strong,  nonatomic) NSMutableArray<TPhotoPreviewModel *> *mediaModels;
- (void)addModel:(TPhotoPreviewModel *)model;
- (void)cleanModels;

- (void)alertWithCurrentMediaModel:(TPhotoPreviewModel *)currentMediaModel;

@end

NS_ASSUME_NONNULL_END
