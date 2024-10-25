//
//  TPhotoPreviewModel.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXPhotoPicker.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOMessage;

@interface TPhotoPreviewModel : NSObject

@property (strong, nonatomic) HXCustomAssetModel *assetModel;

/// 同消息
@property (assign, nonatomic) NSTimeInterval timestamp;

+ (TPhotoPreviewModel * __nullable)customAssetModelWithMessage:(TIOMessage *)message;

@end

NS_ASSUME_NONNULL_END
