//
//  TPhotoPreviewModel.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TPhotoPreviewModel.h"
#import "ImportSDK.h"

@implementation TPhotoPreviewModel

+ (TPhotoPreviewModel *)customAssetModelWithMessage:(TIOMessage *)message
{
    TPhotoPreviewModel *model = nil;
    TIOMessageAttachmnet *attachment = message.attachmentObjects.firstObject;
    
    if (!attachment) {
        return model;
    }
    
    if (message.messageType == TIOMessageTypeImage)
    {
        model = [TPhotoPreviewModel.alloc init];
        
        HXCustomAssetModel *asset = [HXCustomAssetModel assetWithNetworkImageURL:[NSURL URLWithString:attachment.url] networkThumbURL:[NSURL URLWithString:attachment.coverurl] selected:YES];
        model.assetModel = asset;
        model.timestamp = message.timestamp;
    }
    else if (message.messageType == TIOMessageTypeVideo)
    {
        model = [TPhotoPreviewModel.alloc init];
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:attachment.url] options:nil];
        
        NSTimeInterval duration = asset.duration.value/asset.duration.timescale;
        HXCustomAssetModel *assetModel = [HXCustomAssetModel assetWithNetworkVideoURL:[NSURL URLWithString:attachment.url] videoCoverURL:[NSURL URLWithString:attachment.coverurl] videoDuration:duration selected:YES];
        model.assetModel = assetModel;
        model.timestamp = message.timestamp;
    }
    
    return model;
}

@end
